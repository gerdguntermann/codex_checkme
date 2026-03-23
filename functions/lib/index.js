"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOverdueNotification = exports.cleanupBackgroundLogs = exports.onOverdueTrigger = void 0;
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
// ─── Scheduled cleanup: delete background_logs older than 2 days ─────────────
exports.cleanupBackgroundLogs = functions.pubsub
    .schedule("0 3 * * *") // daily at 03:00
    .timeZone("Europe/Berlin")
    .onRun(async () => {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - 2);
    const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoff);
    const oldLogs = await db
        .collectionGroup("background_logs")
        .where("ranAt", "<", cutoffTimestamp)
        .get();
    if (oldLogs.empty) {
        functions.logger.info("cleanupBackgroundLogs: nothing to delete");
        return;
    }
    // Firestore batch limit is 500 operations
    const chunks = [];
    for (let i = 0; i < oldLogs.docs.length; i += 500) {
        chunks.push(oldLogs.docs.slice(i, i + 500));
    }
    for (const chunk of chunks) {
        const batch = db.batch();
        chunk.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
    }
    functions.logger.info(`cleanupBackgroundLogs: deleted ${oldLogs.docs.length} entries older than ${cutoff.toISOString()}`);
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
    const now = new Date().toLocaleString("de-DE", { timeZone: "Europe/Berlin" });
    await resend.emails.send({
        from: fromAddress,
        to: recipientEmails,
        subject: "⚠️ CheckMe: Kein Check-in erfolgt",
        html: `
      <!DOCTYPE html>
      <html lang="de">
      <head><meta charset="UTF-8"></head>
      <body style="font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px;">
        <div style="max-width: 480px; margin: 0 auto; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <div style="background: #d32f2f; padding: 24px; text-align: center;">
            <h1 style="color: #fff; margin: 0; font-size: 24px;">⚠️ CheckMe Alert</h1>
          </div>
          <div style="padding: 24px;">
            <p style="font-size: 16px; color: #333; margin-top: 0;">
              Die überwachte Person hat sich <strong>nicht innerhalb des erwarteten Zeitfensters</strong> eingecheckt.
            </p>
            <div style="background: #fff3e0; border-left: 4px solid #f57c00; padding: 12px 16px; margin: 16px 0; border-radius: 0 4px 4px 0;">
              <strong style="color: #e65100;">Bitte prüfe ihr Wohlbefinden.</strong>
            </div>
            <p style="color: #666; font-size: 14px;">Zeitpunkt der Benachrichtigung: ${now}</p>
          </div>
          <div style="background: #f5f5f5; padding: 16px; text-align: center; font-size: 12px; color: #999;">
            Diese Nachricht wurde automatisch von <strong>CheckMe</strong> gesendet.
          </div>
        </div>
      </body>
      </html>
    `,
        text: `CheckMe Alert: Die überwachte Person hat sich nicht innerhalb des erwarteten Zeitfensters eingecheckt. Bitte prüfe ihr Wohlbefinden. Zeitpunkt: ${now}`,
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