# Admin Panel Design System

This replaces a previous version of this document that described a black/cream "Shopifi" marketing-site aesthetic (Neue Haas Grotesk Display, pill-only buttons, pricing tiers, cinematic hero sections) that had nothing to do with this app. This admin panel is a data-dense merchant dashboard, not a marketing site — the design goal is "feels like Shopify to use," not "looks like a Shopify ad."

## Foundation

- **Typography**: Google Fonts Poppins, applied via `AppTheme.globalTextTheme` (`lib/themes/app_theme.dart`).
- **Shell**: the third-party `flutter_dashboard` package provides the nav drawer / app bar chrome — this isn't a fully custom design system, and rebuilding that shell isn't in scope.
- **Brand color**: `#48BF91` (a muted green), set as `ThemeData.primaryColor` in `AppTheme.lightTheme`/`darkTheme`.

## Tokens (`lib/themes/tokens.dart`)

Added alongside this redesign — spacing, radius, and semantic color scales, so new screens stop hand-picking `EdgeInsets.all(23)`-style one-off values:

```dart
AppSpacing.xs/sm/md/lg/xl/xxl   // 4 / 8 / 12 / 16 / 24 / 32
AppRadius.sm/md/lg/pill         // 8 / 12 / 16 / 999
AppSemanticColors.info/success/warning/danger/neutral (+ *Bg variants)
```

Use these instead of introducing new hardcoded numbers. `AppColors` (`lib/themes/colors.dart`) holds brand-specific colors; `AppSemanticColors` holds status/meaning colors (a "danger" red should read as danger everywhere, regardless of which specific brand palette is active).

## Patterns established so far

- **Stat cards** (`lib/app/modules/home/views/widgets/stat_card.dart`): a tinted background card, big number, label, and a circular icon — used across all 5 dashboard role variants from one shared widget instead of each role duplicating its own card layout.
- **Status badges**: a solid-color pill (`AppSemanticColors.success`/`warning`/`neutral`/`danger` background, white text) — see `ProductListCard`'s Published/Scheduled/Draft badge.
- **List cards**: image (if any) at top with `AppRadius.md` corners, content padded at `AppSpacing.md`, actions row at the bottom rather than a popup menu where there are 3 or fewer actions (a menu hides available actions; a row of icons doesn't).
- **Forms**: sectioned with a plain bold label (`_SectionLabel` pattern in `ProductFormDialog`) rather than one undifferentiated list of fields — see the Product form for the current reference implementation (Basic info / Pricing & inventory / Availability & deal type).
- **Empty/loading states**: a centered icon + one-line message + (when relevant) a one-line explanation, not a bare spinner or blank screen.

## What's intentionally not redesigned yet

Applying these tokens/patterns everywhere is ongoing, not finished in one pass. Screens not yet touched still use ad hoc spacing and the app's older Material-default look. When you touch a screen, bring it in line with the patterns above rather than inventing a third style — but don't do a drive-by reskin of unrelated screens in the same change.

## Status: Planned

- A written color-contrast/accessibility check (current palette hasn't been audited against WCAG).
- Consolidating the remaining ad hoc spacing in `products_listing_view.dart` (the bulk-upload flow) onto the token scale — left alone in the products redesign pass specifically to avoid destabilizing a large, working file for a cosmetic change.
