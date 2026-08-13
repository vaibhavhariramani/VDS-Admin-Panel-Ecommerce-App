const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const WHATSAPP_ACCESS_TOKEN = defineSecret("WHATSAPP_ACCESS_TOKEN");
const WHATSAPP_PHONE_NUMBER_ID = defineSecret("WHATSAPP_PHONE_NUMBER_ID");

// Not a secret - OneSignal app ids are meant to be embedded client-side and
// only identify which app's notifications this is (same id already lived
// in the old client-side code this replaces). The REST API key below is
// the actual secret - it authorizes *sending* notifications, so unlike the
// app id it must never reach the client bundle.
const ONESIGNAL_APP_ID = "33203d1b-0c1a-4445-9698-a59d1e19a2da";
const ONESIGNAL_REST_API_KEY = defineSecret("ONESIGNAL_REST_API_KEY");

const TEMPLATE_NAME = "bill_ready";
const TEMPLATE_LANGUAGE = "en";

function normalizeIndianPhone(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.length === 10) return `91${digits}`;
  if (digits.length === 12 && digits.startsWith("91")) return digits;
  return digits;
}

const VALID_ROLES = ["superadmin", "employee", "none"];

/**
 * Grants or revokes admin-panel access for a staff account by email.
 * Super-admin only. Sets the `admin`/`staff` custom claim the Firestore
 * rules and this app's login gate both check, and mirrors the change into
 * a `Staff/{uid}` Firestore doc (written via the Admin SDK, so it bypasses
 * client rules) so the Manage Staff screen has something to list without
 * needing to enumerate the whole Firebase Auth user base.
 */
exports.setStaffRole = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "Only super admins can manage staff access."
    );
  }

  const { email, role } = request.data || {};
  if (!email || typeof email !== "string") {
    throw new HttpsError("invalid-argument", "email is required.");
  }
  if (!VALID_ROLES.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `role must be one of: ${VALID_ROLES.join(", ")}.`
    );
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (e) {
    throw new HttpsError(
      "not-found",
      `No account found for ${email}. They need to sign in at least ` +
        "once (e.g. via Google sign-in) before access can be granted."
    );
  }

  const claims =
    role === "superadmin"
      ? { admin: true }
      : role === "employee"
        ? { staff: true }
        : {};
  await admin.auth().setCustomUserClaims(userRecord.uid, claims);

  const staffDoc = admin.firestore().collection("Staff").doc(userRecord.uid);
  if (role === "none") {
    await staffDoc.delete();
  } else {
    await staffDoc.set({
      email: userRecord.email || email,
      displayName: userRecord.displayName || null,
      role,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: request.auth.uid,
    });
  }

  logger.info("Staff role updated", {
    email,
    uid: userRecord.uid,
    role,
    by: request.auth.uid,
  });
  return { uid: userRecord.uid, role };
});

/**
 * Sends a push notification via OneSignal, and separately records it in
 * Firestore for the customer-facing app's in-app bell/popup to read (see
 * CUSTOMER_NOTIFICATIONS.md for that contract - this repo doesn't own that
 * app's UI, only this data). Super-admin only. Runs server-side (unlike
 * the old client code this replaces) because the OneSignal REST API key
 * has to stay off the client - anyone who can read the Flutter web
 * bundle's source can read a client-embedded secret.
 *
 * request.data:
 *   title: string (required)
 *   message: string (required)
 *   playerIds: string[] (optional) - specific OneSignal subscription ids
 *     to push to ("Send Individual"); omitted/empty pushes to every
 *     subscribed device ("Send All").
 *   audienceUids: string[] (optional) - customer Firebase uids this
 *     notification is *for*, recorded on the Firestore doc so the
 *     customer app can query its own bell feed. Independent of playerIds
 *     (a customer can be targeted here with no push token on file yet,
 *     and should still see it next time they open the app).
 */
exports.sendPushNotification = onCall(
  { secrets: [ONESIGNAL_REST_API_KEY] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    if (request.auth.token.admin !== true) {
      throw new HttpsError(
        "permission-denied",
        "Only super admins can send notifications."
      );
    }

    const { title, message, playerIds, audienceUids } = request.data || {};
    if (!title || !message) {
      throw new HttpsError(
        "invalid-argument",
        "title and message are required."
      );
    }

    const payload = {
      app_id: ONESIGNAL_APP_ID,
      headings: { en: title },
      contents: { en: message },
    };
    if (Array.isArray(playerIds) && playerIds.length > 0) {
      payload.include_player_ids = playerIds;
    } else {
      payload.included_segments = ["All"];
    }

    const res = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // OneSignal's newer os_v2_app_... restricted API keys use the
        // "Key" auth scheme (legacy unprefixed REST keys used "Basic").
        Authorization: `Key ${ONESIGNAL_REST_API_KEY.value()}`,
      },
      body: JSON.stringify(payload),
    });
    const resJson = await res.json();
    if (!res.ok || (resJson.errors && resJson.errors.length > 0)) {
      logger.error("OneSignal send failed", resJson);
      throw new HttpsError(
        "internal",
        Array.isArray(resJson.errors)
          ? resJson.errors.join(", ")
          : "Failed to send notification."
      );
    }

    const hasAudience = Array.isArray(audienceUids) && audienceUids.length > 0;
    const notificationDoc = await admin.firestore().collection("Notifications").add({
      title,
      message,
      audience: hasAudience ? "individual" : "all",
      audienceUids: hasAudience ? audienceUids : [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      sentBy: request.auth.uid,
    });

    logger.info("Push notification sent", {
      id: resJson.id,
      recipients: resJson.recipients,
      notificationDocId: notificationDoc.id,
      by: request.auth.uid,
    });
    return {
      success: true,
      id: resJson.id,
      recipients: resJson.recipients,
      notificationDocId: notificationDoc.id,
    };
  }
);

exports.sendWhatsAppBill = onCall(
  { secrets: [WHATSAPP_ACCESS_TOKEN, WHATSAPP_PHONE_NUMBER_ID] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    const adminDoc = await admin
      .firestore()
      .collection("Admins")
      .doc(request.auth.uid)
      .get();
    if (!adminDoc.exists || adminDoc.data().isAdmin !== true) {
      throw new HttpsError("permission-denied", "Not authorized.");
    }

    const { phone, customerName, amount, pdfUrl } = request.data || {};
    if (!phone || !pdfUrl) {
      throw new HttpsError(
        "invalid-argument",
        "phone and pdfUrl are required."
      );
    }

    const toNumber = normalizeIndianPhone(phone);
    const name = (customerName && String(customerName).trim()) || "Customer";
    const amountText = amount !== undefined ? String(amount) : "0";

    const payload = {
      messaging_product: "whatsapp",
      to: toNumber,
      type: "template",
      template: {
        name: TEMPLATE_NAME,
        language: { code: TEMPLATE_LANGUAGE },
        components: [
          {
            type: "body",
            parameters: [
              { type: "text", text: name },
              { type: "text", text: amountText },
              { type: "text", text: pdfUrl },
            ],
          },
        ],
      },
    };

    const phoneNumberId = WHATSAPP_PHONE_NUMBER_ID.value();
    const accessToken = WHATSAPP_ACCESS_TOKEN.value();

    const res = await fetch(
      `https://graph.facebook.com/v21.0/${phoneNumberId}/messages`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      }
    );

    const resJson = await res.json();
    if (!res.ok) {
      logger.error("WhatsApp send failed", resJson);
      throw new HttpsError(
        "internal",
        resJson?.error?.message || "Failed to send WhatsApp message."
      );
    }

    logger.info("WhatsApp bill sent", { to: toNumber, id: resJson?.messages?.[0]?.id });
    return { success: true, messageId: resJson?.messages?.[0]?.id };
  }
);
