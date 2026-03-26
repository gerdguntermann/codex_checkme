#!/usr/bin/env node
/**
 * trigger-overdue.js
 *
 * Simuliert einen Overdue-Zustand im lokalen Firebase Emulator,
 * indem ein Dokument in `overdue_triggers` geschrieben wird.
 *
 * Voraussetzung: Emulator läuft (`firebase emulators:start`)
 *
 * Verwendung:
 *   node scripts/trigger-overdue.js [userId]
 *
 * Beispiel:
 *   node scripts/trigger-overdue.js test-user-123
 */

const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST ?? "127.0.0.1:8080";
const PROJECT_ID = process.env.GCLOUD_PROJECT ?? "checkme-app-a0e9e";

process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;

initializeApp({projectId: PROJECT_ID});
const db = getFirestore();

async function triggerOverdue(userId) {
  const docRef = db.collection("overdue_triggers").doc();
  await docRef.set({
    userId,
    triggeredAt: new Date(),
    source: "manual-trigger-script",
  });
  console.log(`[trigger-overdue] Dokument geschrieben: overdue_triggers/${docRef.id}`);
  console.log(`[trigger-overdue] userId: ${userId}`);
  console.log(`[trigger-overdue] Emulator: http://localhost:4000`);
  console.log("[trigger-overdue] Prüfe die Functions-Logs im Emulator-UI.");
}

const userId = process.argv[2] ?? "test-user-emulator";
triggerOverdue(userId).catch((err) => {
  console.error("[trigger-overdue] Fehler:", err.message);
  process.exit(1);
});
