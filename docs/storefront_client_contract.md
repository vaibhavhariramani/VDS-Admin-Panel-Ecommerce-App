# Storefront Configuration — Client App Contract

This is the contract between the Admin App (which owns configuration) and
the Client App (which owns rendering). The Admin App never assumes how a
section is drawn; it only produces this structured JSON. Map `type` →
widget with a `switch`/lookup table — there is no other logic required.

## Where to read from

```
Shops/{shopId}/Storefront/published
```

**Always read `published`, never `draft`.** `draft` is the shop admin's
working copy and is only readable by that shop's own admin (or a platform
admin) — the Client App has no access to it and shouldn't need any. Once a
shop admin taps "Publish" in the Admin App, `published` is overwritten with
a snapshot of the current draft.

This document is publicly readable (no auth required) via `firestore.rules`:

```
match /Shops/{shopId}/Storefront/published {
  allow read: if true;
}
```

## Resolving a shop from its URL

Confirmed against the live Client App (local-bazaar-shop.web.app): a shop's
public URL is `https://local-bazaar-shop.web.app/#/store/{shopId}`, using
the shop's own Firestore doc id directly — e.g.
`.../#/store/4N6v2VdoJ4RmyWJ57ADG`. There's no code-to-shop lookup step:
`shopId` from the URL is exactly the id to read
`Shops/{shopId}/Storefront/published` with.

A `Shop.storeCode` field and a `StoreCodes/{code} → { shopId }` reservation
collection exist in the Admin App's schema, but are **not currently used**
for routing — they're groundwork for an optional future vanity-URL feature
(e.g. `/store/fashion-hub`), not live yet. Don't build against them.

## Document shape

```json
{
  "branding": {
    "storeName": "Fashion Hub",
    "tagline": "Style for everyone",
    "logoUrl": "https://...",
    "faviconUrl": "https://...",
    "coverImageUrl": "https://..."
  },
  "theme": {
    "primaryColor": "#111827",
    "secondaryColor": "#F59E0B",
    "accentColor": "#10B981",
    "backgroundColor": "#FFFFFF",
    "textColor": "#111827",
    "borderRadius": 10,
    "buttonStyle": "rounded",
    "fontFamily": "System Default"
  },
  "homepage": [
    { "id": "sec_123", "type": "hero", "order": 1, "enabled": true, "config": { "...": "..." } }
  ],
  "navigation": [
    { "label": "Men", "type": "category", "referenceId": "Electronics", "order": 1 }
  ],
  "pages": [
    { "slug": "about-us", "title": "About Us",
      "content": [ { "type": "heading", "value": "Who We Are" },
                    { "type": "paragraph", "value": "..." } ] }
  ],
  "banners": [
    { "id": "banner_1", "title": "Summer Sale", "subtitle": "Up to 50% off",
      "imageUrl": "https://...", "action": "products", "enabled": true }
  ],
  "storeDetails": {
    "location": "Downtown Mall, Unit 4", "address": "123 Main St, ...",
    "googleMapsUrl": "https://maps.google.com/...",
    "openingTime": "09:00 AM", "closingTime": "09:00 PM",
    "phoneNumber": "+1 555 0100"
  },
  "faqs": [
    { "id": "faq_delivery", "question": "When will my order arrive?", "answer": "..." }
  ],
  "updatedAt": "<Firestore Timestamp>",
  "updatedBy": "<uid>"
}
```

- `theme.buttonStyle` is one of `rounded` | `pill` | `square`.
- `theme.fontFamily` is one of `System Default` | `Poppins` | `Roboto` |
  `Inter` | `Lato` | `Montserrat`.
- `homepage` may be empty or missing entirely — render nothing (or a "coming
  soon" state) rather than erroring.
- **Only render `homepage` entries where `enabled == true`, sorted by
  `order` ascending.** A disabled section still exists in the array (the
  merchant can re-enable it later) but must not appear on the storefront.
- An unrecognized `type` (e.g. a newer Admin App version added a 14th
  section type your Client App build predates) should be skipped silently,
  not crash the page.

## Homepage section types

Every entry in `homepage` has `id` (string), `type` (string, one of the 13
below), `order` (int), `enabled` (bool), and `config` (shape depends on
`type`). `productIds`/`categoryIds` are references only — resolve them
against your own `Products`/product-category data at render time; the
Admin App never embeds full product/category objects here.

| `type` | `config` shape |
|---|---|
| `hero` | `{ title, subtitle, imageUrl, buttonText, buttonAction }` — **if the document's top-level `banners` array is non-empty, render the enabled banners as a carousel here instead of this section's own single image/title.** The Admin App keeps `banners` as the source of truth for the hero once any exist (see "Banners" below); `hero.config` stays populated as a fallback for older configs / a single-slide case. |
| `announcement_bar` | `{ message, link }` |
| `category_grid` | `{ title, categoryIds: string[] }` |
| `featured_products` | `{ title, productIds: string[] }` |
| `product_grid` | `{ title, productIds: string[], columns: int }` |
| `product_carousel` | `{ title, productIds: string[] }` |
| `promotional_banner` | `{ title, subtitle, imageUrl, buttonText, buttonAction }` |
| `image_text` | `{ title, description, imageUrl, buttonText, buttonAction }` |
| `best_sellers` | `{ title, limit: int }` — query your own top-selling products, don't expect a product list here |
| `new_arrivals` | `{ title, limit: int }` — query your own most-recent products |
| `testimonials` | `{ title, items: [{ name, message, rating: int }] }` |
| `store_information` | `{ showAddress: bool, showPhone: bool, showHours: bool, customText }` — pull the actual address/hours/phone/maps link from this same document's top-level `storeDetails` object (see below), not the `Shops/{shopId}` doc; this section only controls what's *shown* |
| `newsletter` | `{ title, subtitle, buttonText }` — the Admin App doesn't collect emails; wire the button to your own signup flow |

All string fields default to `""` and all `productIds`/`categoryIds`
default to `[]` if omitted — treat a missing field the same as an empty
one.

## Navigation

Each item: `{ label, type, referenceId, order }`. `type` is one of:

- `home` — link to the storefront homepage, `referenceId` unused.
- `banners` — open the banner carousel/gallery (the same slides driving the
  hero — see "Banners" below), `referenceId` unused.
- `products` — link to the full product listing, `referenceId` unused.
- `category` — `referenceId` is a category string (matches `Products.category`
  in the existing catalog — there's no separate category ID system).
- `collection` — `referenceId` is whatever collection-grouping concept your
  Client App uses (not currently produced by the Admin App's UI, reserved
  for future use).
- `page` — `referenceId` is a `pages[].slug` from this same document.
- `external` — `referenceId` is a full URL to open outside the app/in a
  webview.

## Custom pages

Each entry in `pages`: `{ slug, title, content }`, where `content` is an
ordered list of blocks, each `{ type, value }` with `type` one of exactly
three values:

- `heading` — render `value` as a page heading.
- `paragraph` — render `value` as body text.
- `image` — `value` is an image URL.

This is intentionally the entire page-content model — there is no richer
markup or embedded HTML anywhere in this system.

## Banners

Top-level `banners: [{ id, title, subtitle, imageUrl, action, enabled }]`.
`action` is a free-text destination — for now the Admin App writes one of
the same values used for a Hero's `buttonAction` (e.g. `products`, a
category string, a page slug, or a full URL); treat it the same way you'd
resolve `buttonAction`. **Only render banners where `enabled == true`.**
These are the shop's managed promotional slides — the same list feeds the
Hero section (see the `hero` row above) and the `banners` navigation
destination, so there is exactly one place a merchant edits banner content
that shows up in two places on your end.

## Store Details

Top-level `storeDetails: { location, address, googleMapsUrl, openingTime,
closingTime, phoneNumber }` — all plain strings, all default to `""` if
unset. This is the actual contact/location data for the `store_information`
homepage section to display (per that section's `show*` flags) and is also
reasonable to surface elsewhere (e.g. a "Contact"/"Store Info" screen) —
it's shop-level data, not tied to being shown on the homepage specifically.

## FAQs

Top-level `faqs: [{ id, question, answer }]` — every shop gets a small set
of sensible defaults the first time its storefront is created, fully
editable by that shop's admin from then on. Render as a simple ordered
list (e.g. an expandable FAQ screen); there's no category/grouping concept.

## What the Admin App will never send

Per the platform's own design constraint, this config will never contain
arbitrary HTML, Dart/Flutter code, embedded scripts, or full product/
category documents. If a `type` or field shape shows up that isn't in this
document, treat it as a contract change to coordinate on, not something to
special-case defensively.
