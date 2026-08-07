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
