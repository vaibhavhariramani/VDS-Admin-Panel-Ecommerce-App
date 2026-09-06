const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

admin.initializeApp();

const EARTH_RADIUS_KM = 6371;
const DEFAULT_DELIVERY_RADIUS_KM = 50;

function toRadians(deg) {
  return (deg * Math.PI) / 180;
}

// Firestore security rules can't do trigonometry (no sin/cos/atan2), which
// is why the 50km delivery-radius rule is enforced here rather than in
// firestore.rules - see docs/architecture/DELIVERY_RADIUS.md in the master
// repo for the full reasoning.
function haversineKm(lat1, lon1, lat2, lon2) {
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_KM * c;
}

// Platform-wide default; PlatformConfig/delivery.radiusKm can override it
// without a redeploy. Not yet per-shop configurable - see the doc above.
async function getDeliveryRadiusKm(db) {
  const snap = await db.collection("PlatformConfig").doc("delivery").get();
  const radius = snap.exists ? snap.data().radiusKm : null;
  return typeof radius === "number" && radius > 0 ? radius : DEFAULT_DELIVERY_RADIUS_KM;
}

// Set these once per environment with:
//   firebase functions:secrets:set INVITE_WEBHOOK_TOKEN
//   firebase functions:secrets:set INVITE_WEBHOOK_SENDER
// They replace the `authorizationToken: 'abc123'` header and hardcoded
// sender email that used to be hardcoded directly in the Flutter client
// (lib/services/data_service.dart), which meant they shipped in plain text
// inside the compiled Flutter Web bundle for anyone to read.
const inviteWebhookToken = defineSecret("INVITE_WEBHOOK_TOKEN");
const inviteWebhookSender = defineSecret("INVITE_WEBHOOK_SENDER");

const INVITE_WEBHOOK_URL =
  "https://no01ccjb6e.execute-api.us-east-2.amazonaws.com/testing/invitation-mail";

// Mirrors lib/models/UserType.dart. Kept as plain strings here since this
// function doesn't share Dart types with the client — only these roles are
// allowed to send platform invitations.
const INVITER_ROLES = new Set(["ADMIN", "COUNTRY_HEAD", "MERCHANT"]);

/**
 * Callable replacement for the direct HTTP POST the Flutter client used to
 * make straight to the invite-mail webhook. The bearer token and sender
 * address now live only here (server-side, via Secret Manager), and the
 * caller's role is checked against Firestore before the webhook is used at
 * all, instead of trusting whatever the client claims.
 */
exports.sendInvitationEmail = onCall(
  { secrets: [inviteWebhookToken, inviteWebhookSender] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const recipient = request.data && request.data.recipient;
    if (typeof recipient !== "string" || !recipient.includes("@")) {
      throw new HttpsError(
        "invalid-argument",
        "A valid recipient email is required."
      );
    }

    const callerSnap = await admin
      .firestore()
      .collection("Users")
      .doc(request.auth.uid)
      .get();
    const callerType = callerSnap.exists ? callerSnap.data().userType : null;
    if (!INVITER_ROLES.has(callerType)) {
      throw new HttpsError(
        "permission-denied",
        "This account cannot send invitations."
      );
    }

    const response = await fetch(INVITE_WEBHOOK_URL, {
      method: "POST",
      headers: {
        authorizationToken: inviteWebhookToken.value(),
        "Content-Type": "text/plain",
      },
      body: JSON.stringify({
        sender: inviteWebhookSender.value(),
        recipient,
      }),
    });

    if (!response.ok) {
      throw new HttpsError(
        "internal",
        `Invitation email webhook returned ${response.status}`
      );
    }

    return { ok: true };
  }
);

/**
 * One-time (but safe to re-run) backfill for the Phase 2 hierarchy
 * denormalization: stamps `regionId` + `Country` onto every `Shops` doc
 * referenced by a `Regions.ShopsList`, then propagates the same fields
 * onto every `Products`/`Bills` doc belonging to each of those shops.
 *
 * This is NOT wired into any deploy step and does not run on a schedule
 * or trigger — it only runs when explicitly called by a signed-in Super
 * Admin. Uses the Admin SDK (bypasses firestore.rules) since it's a
 * cross-shop bulk write no per-shop role could legitimately perform.
 *
 * Call with `dryRun: true` first to see counts without writing anything.
 */
exports.backfillShopHierarchy = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const callerSnap = await admin
    .firestore()
    .collection("Users")
    .doc(request.auth.uid)
    .get();
  if (!callerSnap.exists || callerSnap.data().userType !== "ADMIN") {
    throw new HttpsError("permission-denied", "Super Admin only.");
  }

  const dryRun = !!(request.data && request.data.dryRun);
  const db = admin.firestore();
  const summary = { regions: 0, shopsUpdated: 0, productsUpdated: 0, billsUpdated: 0, warnings: [] };

  const regionsSnap = await db.collection("Regions").get();
  summary.regions = regionsSnap.size;

  for (const regionDoc of regionsSnap.docs) {
    const region = regionDoc.data();
    const shopIds = Array.isArray(region.ShopsList) ? region.ShopsList : [];
    const country = region.Country || null;
    if (!country) {
      summary.warnings.push(`Region ${regionDoc.id} has no Country field — shops under it will get regionId but no Country.`);
    }

    for (const shopId of shopIds) {
      if (typeof shopId !== "string") continue;
      const shopRef = db.collection("Shops").doc(shopId);
      const shopSnap = await shopRef.get();
      if (!shopSnap.exists) {
        summary.warnings.push(`Region ${regionDoc.id} lists shop ${shopId}, which doesn't exist.`);
        continue;
      }

      if (!dryRun) {
        await shopRef.update({ regionId: regionDoc.id, Country: country });
      }
      summary.shopsUpdated += 1;

      // Batched in groups of 400 (under Firestore's 500-op batch limit,
      // leaving headroom) since a shop can have an arbitrary number of
      // products/bills.
      for (const [collectionName, counterKey] of [["Products", "productsUpdated"], ["Bills", "billsUpdated"]]) {
        const docsSnap = await db.collection(collectionName).where("shopId", "==", shopId).get();
        let batch = db.batch();
        let opsInBatch = 0;
        for (const doc of docsSnap.docs) {
          if (!dryRun) {
            batch.update(doc.ref, { regionId: regionDoc.id, Country: country });
          }
          summary[counterKey] += 1;
          opsInBatch += 1;
          if (opsInBatch >= 400) {
            if (!dryRun) await batch.commit();
            batch = db.batch();
            opsInBatch = 0;
          }
        }
        if (opsInBatch > 0 && !dryRun) {
          await batch.commit();
        }
      }
    }
  }

  return { dryRun, ...summary };
});

/**
 * Builds a starter `Storefront` config for a shop from whatever real data
 * it already has (name, logo, brand color, products) - mirrors
 * `StorefrontController._buildDefaultConfig` in the Flutter app 1:1 (same
 * section types/field names/ids), kept as a plain JS function here since
 * Cloud Functions don't share Dart types with the client.
 */
function buildDefaultStorefrontConfig(shop, products) {
  const storeName = shop.name && shop.name.length > 0 ? shop.name : "My Store";
  const logoUrl = shop.imgToken || "";
  const coverImageUrl =
    Array.isArray(shop.bannerUrls) && shop.bannerUrls.length > 0 ? shop.bannerUrls[0] : "";
  const primaryColor = shop.brandColor && shop.brandColor.length > 0 ? shop.brandColor : "#111827";
  const about =
    shop.about && shop.about.length > 0
      ? shop.about
      : "Quality products, delivered to your door.";

  const categories = Array.from(
    new Set(products.map((p) => p.category).filter((c) => typeof c === "string" && c.length > 0))
  ).sort();
  const productIds = products
    .slice(0, 8)
    .map((p, i) => (p.barcode && p.barcode.length > 0 ? p.barcode : p.id || p.name || `product_${i}`));

  return {
    branding: {
      storeName,
      tagline: "Quality products, delivered to your door",
      logoUrl,
      faviconUrl: "",
      coverImageUrl,
    },
    theme: {
      primaryColor,
      secondaryColor: "#F59E0B",
      accentColor: "#10B981",
      backgroundColor: "#FFFFFF",
      textColor: "#111827",
      borderRadius: 10,
      buttonStyle: "rounded",
      fontFamily: "System Default",
    },
    homepage: [
      {
        id: "sec_default_hero",
        type: "hero",
        order: 0,
        enabled: true,
        config: {
          title: `Welcome to ${storeName}`,
          subtitle: about,
          imageUrl: coverImageUrl,
          buttonText: "Shop Now",
          buttonAction: "products",
        },
      },
      {
        id: "sec_default_categories",
        type: "category_grid",
        order: 1,
        enabled: true,
        config: { title: "Shop by Category", categoryIds: categories.slice(0, 6) },
      },
      {
        id: "sec_default_featured",
        type: "featured_products",
        order: 2,
        enabled: true,
        config: { title: "Featured Products", productIds: productIds.slice(0, 4) },
      },
      {
        id: "sec_default_bestsellers",
        type: "best_sellers",
        order: 3,
        enabled: true,
        config: { title: "Best Sellers", limit: 8 },
      },
      {
        id: "sec_default_storeinfo",
        type: "store_information",
        order: 4,
        enabled: true,
        config: { showAddress: true, showPhone: true, showHours: true, customText: "" },
      },
      {
        id: "sec_default_newsletter",
        type: "newsletter",
        order: 5,
        enabled: true,
        config: { title: "Join our newsletter", subtitle: "", buttonText: "Subscribe" },
      },
    ],
    navigation: [
      { label: "Home", type: "home", referenceId: "", order: 0 },
      { label: "Banners", type: "banners", referenceId: "", order: 1 },
      { label: "Products", type: "products", referenceId: "", order: 2 },
      { label: "About Us", type: "page", referenceId: "about-us", order: 3 },
      { label: "Contact", type: "page", referenceId: "contact", order: 4 },
    ],
    banners: [
      {
        id: "banner_welcome",
        title: `Welcome to ${storeName}`,
        subtitle: about,
        imageUrl: coverImageUrl,
        action: "products",
        enabled: true,
      },
    ],
    storeDetails: {
      location: "",
      address: shop.address || "",
      googleMapsUrl: "",
      openingTime: "",
      closingTime: "",
      phoneNumber: shop.phone_number || "",
    },
    faqs: [
      {
        id: "faq_delivery",
        question: "When will my order arrive?",
        answer:
          "Delivery times are shown at checkout. We will keep you updated once your order is on its way.",
      },
      {
        id: "faq_returns",
        question: "What is your return policy?",
        answer:
          "Please contact the store with your order details and we will help you with an eligible return or exchange.",
      },
      {
        id: "faq_contact",
        question: "How can I contact the store?",
        answer:
          "Use the contact details on this storefront during opening hours and our team will be happy to help.",
      },
    ],
    pages: [
      {
        slug: "about-us",
        title: "About Us",
        content: [
          { type: "heading", value: "Who We Are" },
          { type: "paragraph", value: about },
        ],
      },
      {
        slug: "contact",
        title: "Contact",
        content: [
          { type: "heading", value: "Get in Touch" },
          {
            type: "paragraph",
            value: `Phone: ${shop.phone_number || "Add your phone number"}\nAddress: ${
              shop.address || "Add your address"
            }`,
          },
        ],
      },
      {
        slug: "faq",
        title: "FAQ",
        content: [
          { type: "heading", value: "Frequently Asked Questions" },
          { type: "paragraph", value: "Add your frequently asked questions here." },
        ],
      },
    ],
  };
}

/**
 * One-time (but safe to re-run) rollout: gives every existing shop a live
 * default storefront, so a customer visiting `.../#/store/{shopId}` for any
 * shop in the database sees a real storefront immediately, before that
 * shop's admin has ever opened the Storefront section themselves.
 *
 * Skips any shop that already has a `Storefront/published` doc - never
 * overwrites a storefront a merchant has actually configured/published.
 * Not wired into any deploy step, trigger, or schedule - only runs when
 * explicitly called by a signed-in Super Admin. Uses the Admin SDK
 * (bypasses firestore.rules) since it writes across every shop, which no
 * per-shop role could legitimately do itself.
 *
 * Call with `dryRun: true` first to see counts without writing anything.
 */
exports.backfillDefaultStorefronts = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const callerSnap = await admin.firestore().collection("Users").doc(request.auth.uid).get();
  if (!callerSnap.exists || callerSnap.data().userType !== "ADMIN") {
    throw new HttpsError("permission-denied", "Super Admin only.");
  }

  const dryRun = !!(request.data && request.data.dryRun);
  const db = admin.firestore();
  const summary = { shopsSeen: 0, shopsSeeded: 0, shopsSkipped: 0, warnings: [] };

  const shopsSnap = await db.collection("Shops").get();
  summary.shopsSeen = shopsSnap.size;

  for (const shopDoc of shopsSnap.docs) {
    const shopId = shopDoc.id;
    const shop = shopDoc.data();
    const storefrontRef = db.collection("Shops").doc(shopId).collection("Storefront");
    const publishedRef = storefrontRef.doc("published");

    const publishedSnap = await publishedRef.get();
    if (publishedSnap.exists) {
      summary.shopsSkipped += 1;
      continue;
    }

    let products = [];
    try {
      const productsSnap = await db.collection("Products").where("shopId", "==", shopId).get();
      products = productsSnap.docs.map((d) => d.data());
    } catch (e) {
      summary.warnings.push(`Shop ${shopId}: failed to fetch products (${e.message}).`);
    }

    const config = buildDefaultStorefrontConfig(shop, products);
    const payload = {
      ...config,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: "backfillDefaultStorefronts",
    };

    if (!dryRun) {
      await storefrontRef.doc("draft").set(payload);
      await publishedRef.set(payload);
    }
    summary.shopsSeeded += 1;
  }

  return { dryRun, ...summary };
});

/**
 * The only path by which a delivery gets assigned to a rider who assigned
 * themself (staff can still assign directly from the admin panel's order
 * detail screen, which uses the Admin SDK-equivalent trust of `isStaff()`
 * in firestore.rules). Runs entirely server-side so a modified client can't
 * claim a delivery outside the configured radius or race another rider for
 * the same order - see docs/architecture/DELIVERY_RADIUS.md.
 *
 * firestore.rules deliberately does NOT allow a rider to set their own
 * `riderId` on an OnlineOrders doc (only status/pickup/delivery timestamp
 * fields, once already assigned) - this function is what performs that
 * assignment, using the Admin SDK to bypass rules after checking eligibility
 * itself.
 */
exports.acceptDelivery = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const riderId = request.auth.uid;
  const orderId = request.data && request.data.orderId;
  if (typeof orderId !== "string" || orderId.length === 0) {
    throw new HttpsError("invalid-argument", "orderId is required.");
  }

  const db = admin.firestore();

  const riderUserSnap = await db.collection("Users").doc(riderId).get();
  if (!riderUserSnap.exists || riderUserSnap.data().userType !== "RIDER") {
    throw new HttpsError("permission-denied", "Only rider accounts can accept deliveries.");
  }

  const riderOpsSnap = await db.collection("Riders").doc(riderId).get();
  const riderLocation = riderOpsSnap.exists ? riderOpsSnap.data().location : null;
  if (
    !riderLocation ||
    typeof riderLocation.latitude !== "number" ||
    typeof riderLocation.longitude !== "number"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Turn on location sharing before accepting a delivery."
    );
  }

  const orderRef = db.collection("OnlineOrders").doc(orderId);
  const orderSnap = await orderRef.get();
  if (!orderSnap.exists) {
    throw new HttpsError("not-found", "Order not found.");
  }
  const order = orderSnap.data();
  if (order.riderId) {
    throw new HttpsError("failed-precondition", "This order has already been claimed by another rider.");
  }
  if (order.status !== "ready_for_pickup") {
    throw new HttpsError("failed-precondition", "This order is not ready for pickup yet.");
  }

  const shopSnap = await db.collection("Shops").doc(order.shopId).get();
  if (!shopSnap.exists) {
    throw new HttpsError("failed-precondition", "This order's shop could not be found.");
  }
  const shop = shopSnap.data();
  const shopLat = parseFloat(shop.latitude);
  const shopLon = parseFloat(shop.longitude);
  if (Number.isNaN(shopLat) || Number.isNaN(shopLon)) {
    throw new HttpsError("failed-precondition", "This shop has no location on file.");
  }

  const radiusKm = await getDeliveryRadiusKm(db);
  const distanceKm = haversineKm(riderLocation.latitude, riderLocation.longitude, shopLat, shopLon);
  if (distanceKm > radiusKm) {
    throw new HttpsError(
      "failed-precondition",
      `This delivery is ${distanceKm.toFixed(1)} km away, outside your ${radiusKm} km delivery radius.`
    );
  }

  const riderData = riderUserSnap.data();
  const riderName = riderData.fullname || riderData.name || "";
  const riderPhone = riderData.phone || "";

  // Re-checks riderId is still null at write time - closes the race window
  // between the read above and this write, so two riders tapping "Accept"
  // within milliseconds of each other can't both win.
  await db.runTransaction(async (tx) => {
    const freshSnap = await tx.get(orderRef);
    if (freshSnap.data().riderId) {
      throw new HttpsError("failed-precondition", "This order has already been claimed by another rider.");
    }
    tx.update(orderRef, {
      riderId,
      riderName,
      riderPhone,
      status: "rider_assigned",
      riderAssignedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true, distanceKm };
});

/**
 * Real push delivery for "new order nearby" - the original Delivery app
 * shipped `firebase_messaging` as a dependency and a README claiming FCM
 * alerts worked, but no code anywhere ever sent one. This is what actually
 * sends it: triggers when an order's status changes to `ready_for_pickup`,
 * and notifies every online rider within the delivery radius who has a
 * saved FCM token.
 */
exports.notifyNearbyRidersOnReadyForPickup = onDocumentUpdated(
  "OnlineOrders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === after.status || after.status !== "ready_for_pickup") {
      return;
    }

    const db = admin.firestore();
    const shopSnap = await db.collection("Shops").doc(after.shopId).get();
    if (!shopSnap.exists) return;
    const shop = shopSnap.data();
    const shopLat = parseFloat(shop.latitude);
    const shopLon = parseFloat(shop.longitude);
    if (Number.isNaN(shopLat) || Number.isNaN(shopLon)) return;

    const radiusKm = await getDeliveryRadiusKm(db);

    // Capped at 200 online riders per notification burst - fine at current
    // scale; a geohash-scoped query is the eventual replacement if the
    // online-rider pool grows large enough for this to matter.
    const ridersSnap = await db.collection("Riders").where("isOnline", "==", true).limit(200).get();
    const tokens = [];
    ridersSnap.forEach((doc) => {
      const rider = doc.data();
      const loc = rider.location;
      if (!loc || typeof loc.latitude !== "number" || typeof loc.longitude !== "number") return;
      const distanceKm = haversineKm(loc.latitude, loc.longitude, shopLat, shopLon);
      if (distanceKm <= radiusKm && typeof rider.fcmToken === "string" && rider.fcmToken.length > 0) {
        tokens.push(rider.fcmToken);
      }
    });

    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "New delivery nearby",
        body: `A new order from ${shop.name || "a nearby shop"} is ready for pickup.`,
      },
      data: { orderId: event.params.orderId, type: "new_delivery" },
    });
  }
);
