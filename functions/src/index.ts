import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";

admin.initializeApp();
const db = admin.firestore();

// Configure email transport – set these in Firebase environment config:
// firebase functions:config:set email.host="smtp.example.com" email.port="587"
//   email.user="..." email.pass="..." email.from="checkme@example.com"
function createTransport() {
  const cfg = functions.config().email ?? {};
  return nodemailer.createTransport({
    host: cfg.host ?? "smtp.gmail.com",
    port: parseInt(cfg.port ?? "587"),
    secure: false,
    auth: {
      user: cfg.user,
      pass: cfg.pass,
    },
  });
}

// ─── Triggered by Firestore write to overdue_triggers/{docId} ───────────────
export const onOverdueTrigger = functions.firestore
  .document("overdue_triggers/{docId}")
  .onCreate(async (snap) => {
    const data = snap.data();
    const userId: string = data.userId;

    if (!userId) {
      functions.logger.warn("overdue_triggers doc missing userId", {snap: snap.id});
      return;
    }

    await sendOverdueNotifications(userId);

    // Delete the trigger doc after processing
    await snap.ref.delete();
  });

// ─── Callable function for manual triggering / testing ───────────────────────
export const sendOverdueNotification = functions.https.onCall(
  async (data, context) => {
    const userId: string = data.userId ?? context.auth?.uid;
    if (!userId) {
      throw new functions.https.HttpsError("unauthenticated", "User not authenticated");
    }
    await sendOverdueNotifications(userId);
    return {success: true};
  }
);

// ─── Core notification logic ─────────────────────────────────────────────────
async function sendOverdueNotifications(userId: string): Promise<void> {
  const userRef = db.collection("users").doc(userId);

  // Load config
  const configSnap = await userRef.collection("config").doc("user_config").get();
  if (!configSnap.exists) {
    functions.logger.info("No config for user", {userId});
    return;
  }
  const config = configSnap.data()!;
  if (!config.isActive) return;

  // Check maxNotifications guard – count notifications sent today
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const logsSnap = await userRef
    .collection("notification_logs")
    .where("sentAt", ">=", today.getTime())
    .get();

  if (logsSnap.size >= (config.maxNotifications ?? 3)) {
    functions.logger.info("Max notifications reached for user", {userId, count: logsSnap.size});
    return;
  }

  // Load contacts
  const contactsSnap = await userRef.collection("contacts").get();
  if (contactsSnap.empty) {
    functions.logger.info("No contacts for user", {userId});
    return;
  }

  const contacts = contactsSnap.docs.map((doc) => doc.data());
  const recipientEmails = contacts.map((c) => c.email as string).filter(Boolean);
  if (recipientEmails.length === 0) return;

  // Send emails
  const transport = createTransport();
  const cfg = functions.config().email ?? {};
  const fromAddress = cfg.from ?? cfg.user ?? "checkme@example.com";

  await transport.sendMail({
    from: `CheckMe <${fromAddress}>`,
    to: recipientEmails.join(", "),
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

  functions.logger.info("Notification emails sent", {userId, recipients: recipientEmails});

  // Log the notification
  await userRef.collection("notification_logs").add({
    userId,
    sentAt: Date.now(),
    recipientEmails,
  });
}
