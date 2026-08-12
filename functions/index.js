const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const WHATSAPP_ACCESS_TOKEN = defineSecret("WHATSAPP_ACCESS_TOKEN");
const WHATSAPP_PHONE_NUMBER_ID = defineSecret("WHATSAPP_PHONE_NUMBER_ID");

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
