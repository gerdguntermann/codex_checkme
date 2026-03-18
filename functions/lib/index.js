"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOverdueNotification = exports.onOverdueTrigger = void 0;
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const resend_1 = require("resend");
admin.initializeApp();
const db = admin.firestore();
function getResend() {
    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey)
        throw new Error("RESEND_API_KEY not set in functions/.env");
    return new resend_1.Resend(apiKey);
}
// ─── Triggered by Firestore write to overdue_triggers/{docId} ───────────────
exports.onOverdueTrigger = functions.firestore
    .document("overdue_triggers/{docId}")
    .onCreate(async (snap) => {
    const data = snap.data();
    const userId = data.userId;
    if (!userId) {
        functions.logger.warn("overdue_triggers doc missing userId", { snap: snap.id });
        return;
    }
    await sendOverdueNotifications(userId);
    // Delete the trigger doc after processing
    await snap.ref.delete();
});
// ─── Callable function for manual triggering / testing ───────────────────────
exports.sendOverdueNotification = functions.https.onCall(async (data, context) => {
    var _a, _b;
    const userId = (_a = data.userId) !== null && _a !== void 0 ? _a : (_b = context.auth) === null || _b === void 0 ? void 0 : _b.uid;
    if (!userId) {
        throw new functions.https.HttpsError("unauthenticated", "User not authenticated");
    }
    await sendOverdueNotifications(userId);
    return { success: true };
});
// ─── Core notification logic ─────────────────────────────────────────────────
async function sendOverdueNotifications(userId) {
    var _a, _b;
    const userRef = db.collection("users").doc(userId);
    // Load config
    const configSnap = await userRef.collection("config").doc("user_config").get();
    if (!configSnap.exists) {
        functions.logger.info("No config for user", { userId });
        return;
    }
    const config = configSnap.data();
    if (!config.isActive)
        return;
    // Check maxNotifications guard – count notifications sent today
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const logsSnap = await userRef
        .collection("notification_logs")
        .where("sentAt", ">=", today.getTime())
        .get();
    if (logsSnap.size >= ((_a = config.maxNotifications) !== null && _a !== void 0 ? _a : 3)) {
        functions.logger.info("Max notifications reached for user", { userId, count: logsSnap.size });
        return;
    }
    // Load contacts
    const contactsSnap = await userRef.collection("contacts").get();
    if (contactsSnap.empty) {
        functions.logger.info("No contacts for user", { userId });
        return;
    }
    const contacts = contactsSnap.docs.map((doc) => doc.data());
    const recipientEmails = contacts.map((c) => c.email).filter(Boolean);
    if (recipientEmails.length === 0)
        return;
    // Send emails via Resend
    const resend = getResend();
    const fromAddress = (_b = process.env.RESEND_FROM) !== null && _b !== void 0 ? _b : "CheckMe <onboarding@resend.dev>";
    await resend.emails.send({
        from: fromAddress,
        to: recipientEmails,
        subject: "CheckMe: No recent check-in",
        html: `
      <h2>CheckMe Alert</h2>
      <p>The monitored person has not checked in within the expected time window.</p>
      <p>Please verify their well-being.</p>
      <hr>
      <small>This message was sent automatically by CheckMe.</small>
    `,
        text: "CheckMe Alert: The monitored person has not checked in within the expected time window. Please verify their well-being.",
    });
    functions.logger.info("Notification emails sent via Resend", { userId, recipients: recipientEmails });
    // Log the notification
    await userRef.collection("notification_logs").add({
        userId,
        sentAt: Date.now(),
        recipientEmails,
    });
}
//# sourceMappingURL=index.js.map