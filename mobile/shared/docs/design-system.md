# SakAI Mobile Design System

> Unified UI tokens, semantic colors, and components for the SakAI passenger + driver Flutter apps. Owned by `sakai_shared`; consumed via `import 'package:sakai_shared/sakai_shared.dart';`.

## 1. Tokens (`SakaiDesignTokens`)

Access via `SakaiDesignTokens.of(context)`. Tokens are immutable per-theme and exposed through Material's `ThemeExtension`. Source: `mobile/shared/lib/theme/sakai_design_tokens.dart`.

### Spacing
| Token | Value | When to use |
|---|---|---|
| `spaceXs` | 4 | Tight inline gaps (icon ↔ text, badge inner padding) |
| `spaceSm` | 8 | Compact stack spacing, gaps between actions in a row |
| `spaceMd` | 16 | Default body padding, card insets, dialog content padding |
| `spaceLg` | 24 | Section separation, button horizontal padding |
| `spaceXl` | 32 | Major layout gutters, hero spacing |

### Radii
| Token | Value | When to use |
|---|---|---|
| `radiusSm` | 8 | Chips, badges, status pills (when not fully rounded) |
| `radiusMd` | 12 | Inputs, dialogs, secondary surfaces |
| `radiusLg` | 20 | Cards, FilledButton / OutlinedButton, bottom-sheet top corners |
| `radiusFull` | 999 | Pills, FABs, drag handles, avatars |

### Material elevation (dp)
| Token | Value | When to use |
|---|---|---|
| `elevationAppBar` | 0 | Default app bars (flat — `scrolledUnderElevation: 1` lifts on scroll) |
| `elevationModal` | 3 | Bottom sheets, transient surfaces, `SakaiAppBar.elevated()` |
| `elevationDialog` | 6 | `AlertDialog`, important modal overlays |

### Drop-shadow elevation (custom)
| Token | Value | When to use |
|---|---|---|
| `elevationSm` | 1-layer subtle shadow | Floating chips, hovered list items |
| `elevationMd` | 1-layer medium shadow | Surface cards lifted from the background |
| `elevationLg` | 1-layer prominent shadow | Hero / featured surfaces |

These are `List<BoxShadow>` lists for use with custom `Container(decoration: BoxDecoration(boxShadow: ...))`. Material widgets keep using the dp-based tokens above.

### Motion durations
| Token | Value | When to use |
|---|---|---|
| `durationMicro` | 80ms | Haptic-paired micro feedback (selection tints, badge pulses) |
| `durationFast` | 150ms | Hover/press state changes |
| `durationStandard` | 250ms | Most navigation + content transitions |
| `durationSlow` | 400ms | Large layout shifts, modal enter/leave |

### Motion curves
| Token | Value | When to use |
|---|---|---|
| `curveStandard` | `Curves.easeOutCubic` | Default for nav transitions and content shifts |
| `curveEmphasized` | `Curves.easeOutQuint` | Bottom sheet enter/leave, expressive motion |
| `curveDecelerate` | `Curves.easeOut` | Fade-in for incoming content |

### Interaction-state opacity (Material 3 aligned)
| Token | Value | When to use |
|---|---|---|
| `opacityDisabled` | 0.38 | Disabled controls (text, icons, button labels) |
| `opacityHover` | 0.08 | Hover state overlays |
| `opacityFocus` | 0.12 | Focused control overlays |
| `opacityPressed` | 0.16 | Pressed-state ink |
| `opacitySubtle` | 0.6 | De-emphasized helper / secondary text |

### Icon sizes
| Token | Value | When to use |
|---|---|---|
| `iconSm` | 16 | Inline icons next to text |
| `iconMd` | 24 | Default UI icons (toolbar, list leading) |
| `iconLg` | 32 | Header / hero icons |

### Borders + a11y
| Token | Value | When to use |
|---|---|---|
| `borderHairline` | 0.5 | Subtle dividers, top edge of `SakaiBottomActionBar` |
| `borderThin` | 1 | Form field outlines, card edges |
| `borderMedium` | 2 | Focus rings, selected outlines |
| `touchTargetMin` | 48 | Minimum tap-target height (a11y floor) |

## 2. Semantic Colors (`SakaiSemanticColors`)

Access via `SakaiSemanticColors.of(context)`. Colors are tone-aware and adapt to light/dark automatically. Source: `mobile/shared/lib/theme/sakai_semantic_colors.dart`.

| Token | Use |
|---|---|
| `success` | Confirmation chips, success states, "verified" markers |
| `successSubtle` | Tinted backgrounds behind success messages / alerts |
| `danger` | Error states, destructive actions, SOS, cancel-ride |
| `dangerSubtle` | Tinted background behind danger alerts and inline errors |
| `warning` | Caution chips, expiring states, soft warnings |
| `warningSubtle` | Tinted background behind warning alerts |
| `warningDark` | Dark-mode-only brighter amber (+8% lightness) for legibility |
| `accentBlue` | "On duty" / info chips, accent CTA when red is wrong |
| `neutral` | De-emphasized labels, hint text |
| `neutralVariant` | Disabled labels, tertiary text |
| `disabledSurface` | Background for disabled inputs / buttons |
| `disabledOnSurface` | Foreground (text/icon) on disabled surfaces |
| `darkBackground` | Explicit dark-mode page background (overrides M3 surface) |
| `darkSurface` | Explicit dark-mode card/sheet surface |
| `darkBorder` | Explicit dark-mode outline (overrides `outlineVariant`) |
| `glassTintLight` / `glassTintDark` | Used by `SakaiGlassCard` only |

**Never use** `Colors.red/blue/green/orange/amber/grey/yellow/purple` directly. Pick from `SakaiSemanticColors` or `Theme.of(context).colorScheme`.

## 3. Brand seed

Both apps use the same red brand seed `0xFFff4b4b` so users recognize SakAI across passenger and driver experiences:

| App | `primarySeed` | `secondarySeed` |
|---|---|---|
| Passenger (`SakaiThemeConfig.passenger()`) | `0xFFff4b4b` | `0xFFe04343` |
| Driver (`SakaiThemeConfig.driver()`) | `0xFFff4b4b` | `0xFFff4b4b` |

Role is signaled by app icon + copy, not by accent color. Drivers see the same brand — confidence + cross-app recognition wins over role-by-color. The driver config additionally pins explicit dark-mode background (`0xFF0D1117`), surface (`0xFF161B22`), and border (`0xFF30363D`) colors plus literal success/danger/warning values (`0xFF34A853`, `0xFFEA4335`, `0xFFFBBC04`) for a consistent dispatch-grade dark experience.

Typography for both apps is **Plus Jakarta Sans** via `google_fonts.plusJakartaSansTextTheme()`.

## 4. Component Catalog

Grouped by responsibility. Every entry is exported from `package:sakai_shared/sakai_shared.dart`.

### Chrome
- `SakaiAppBar` — themed app bar with auto back-button fallback and `surfaceTintColor` pinned to surface (suppresses M3 scroll-under purple shift). Factories: `.transparent()` (flat, transparent), `.elevated()` (modal-depth).
- `SakaiScreenScaffold` — opinionated screen wrapper. Takes `title: String`, `body`, optional `actions`, `bottom`, `fab`. Builds the app bar internally and pads `body` by `spaceMd`.
- `SakaiBottomActionBar` — sticky horizontal action surface with safe-area padding and a hairline top border. Mount inside the screen body (not `Scaffold.bottomNavigationBar`, which would double-pad).

### Buttons
- `SakaiPrimaryButton` — main brand CTA. Wraps `FilledButton`; expands to full width by default.
- `SakaiSecondaryButton` — alt CTA / lower-emphasis action. Wraps `OutlinedButton`; expands to full width by default.

### Forms + input
- `SakaiTextField` — themed text input aligned to shared `InputDecorationTheme` and spacing tokens.
- `SakaiFormField` — labeled wrapper around `SakaiTextField` with required marker (`*`), helper text, and error text rendered outside the field for stable layout.
- `SakaiOtpInput` — multi-cell OTP / PIN entry. Auto-advances on input, steps back on delete, calls `onCompleted` when full. Default length: 6.
- `SakaiValidators` — static helpers: `required`, `email`, `phone` (PH-friendly), `minLength`, `combine`. Returns `null` on success, error string on failure.

### Feedback
- `SakaiSnackBar` — static helpers `.success(ctx, msg)`, `.error(ctx, msg)`, `.warning(ctx, msg)`, `.info(ctx, msg)`. Always prefer over raw `ScaffoldMessenger.showSnackBar`.
- `SakaiErrorAlert` — inline error/warning banner with optional retry + dismiss. `severity: SakaiAlertSeverity.error | .warning`. Wrapped in `Semantics` as a live region for assistive tech.
- `SakaiLoadingOverlay` — full-screen blocking spinner backed by `OverlayEntry`. `show(ctx, message: ...)` / `hide()` / `isVisible`. Duplicate `show` calls are no-ops.
- `SakaiDialog.confirm(ctx, title, message, destructive: ...)` — themed confirmation dialog returning `Future<bool>`. `destructive: true` tints the confirm button with the danger token.

### Surfaces
- `SakaiGlassCard` — frosted (blur + semi-transparent) card. Use for hero surfaces over imagery or maps; do not stack glass cards.
- `SakaiSurfaceCard` — simple surface card with theme card shape, antialiased clip, and `InkWell` tap. Use for ordinary content tiles.
- `SakaiModalSheet.show(ctx, builder: ...)` — themed bottom-sheet wrapper (drag handle, top-rounded radius, viewInsets-safe). `maxHeightFactor: 0.9` by default.
- `SakaiDivider` — hairline divider with optional inset (`SakaiDividerInset.none | .sm | .md`).

### Layout pieces
- `SakaiListTile` — branded list row with min touch target, haptic on tap, subtle selection tint. Use over `ListTile` when surrounding screen is composed from SakAI primitives.
- `SakaiAvatar` — circular avatar with image / initials / icon fallback chain + optional badge. Sizes: `SakaiAvatarSize.sm` (24), `.md` (40), `.lg` (64).
- `SakaiSectionHeader` — section title with optional trailing label (e.g. "See all") + tap handler.

### Domain chips
- `SakaiStatusBadge` — compact pill for ride status, online/offline, payment status. Maps `SakaiStatus.neutral | info | success | warning | danger | pending` → color. Optional `icon`, `dense`.
- `SakaiFareChip` — prominent fare display: large amount + optional subtitle (e.g. "estimate") and leading widget.
- `SakaiRideTypeChip` — vehicle type label (motorcycle / tricycle / car). Exported from `sakai_fare_chip.dart`.
- `SakaiCountdownChip` — live countdown chip toward a `DateTime` deadline. Pulses scale and switches to the danger palette once `remaining <= dangerThreshold`. Calls `onExpired` at zero.

### State views
- `SakaiEmptyState` — full-bleed empty / no-results state: icon + title + optional message + up to two CTAs (primary + secondary).
- `SakaiErrorState` — error-styled preset over `SakaiEmptyState` with a retry CTA. Defaults title to "Something went wrong", icon to `Icons.error_outline`.
- `SakaiSkeleton` — shimmer placeholder (exported via `sakai_loading_skeleton.dart`). Factories: `SakaiSkeleton.line()`, `.card()`, `.circle()`, plus static `SakaiSkeleton.list(itemCount, itemHeight)` for a vertical card stack.
- `ComingSoonState` — "backend pending" preset. Renders when a view catches `BackendUnavailableException`.

### Async
- `AsyncValueView<T>` — Riverpod `AsyncValue` rendering helper. Composes the four states (`loading` → skeleton list, `error` → `SakaiErrorState`, `empty` → `SakaiEmptyState`, `data` → `dataBuilder(value)`). Use instead of `AsyncValue.when(...)` boilerplate.

### Motion + UX
- `SakaiWelcomeCarousel` — onboarding carousel. Pair with `SakaiWelcomeSlide` records and a single `onComplete` callback.

## 5. Screen skeleton

Copy-paste template for a new screen. Uses `SakaiScreenScaffold` + `SakaiBottomActionBar` inside the body:

```dart
import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    return SakaiScreenScaffold(
      title: 'Example',
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SakaiSectionHeader(title: 'Section'),
                SakaiSurfaceCard(child: Text('Content tile')),
                SizedBox(height: tokens.spaceMd),
                // ... more Sakai* widgets
              ],
            ),
          ),
          SakaiBottomActionBar(
            actions: [
              SakaiSecondaryButton(label: 'Cancel', onPressed: () {}),
              SakaiPrimaryButton(label: 'Confirm', onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
```

> Need a custom app bar (e.g. transparent over a map)? Skip `SakaiScreenScaffold` and compose `Scaffold(appBar: SakaiAppBar.transparent(...), body: ...)` directly.

## 6. Do / Don't

| Do | Don't |
|---|---|
| `SakaiSemanticColors.of(context).danger` | `Colors.red` |
| `SakaiSemanticColors.of(context).success` | `Colors.green` |
| `SakaiSemanticColors.of(context).warning` | `Colors.amber` / `Colors.orange` |
| `Theme.of(context).colorScheme.outlineVariant` | `Colors.grey[300]` |
| `tokens.spaceMd` | `16.0` literal |
| `tokens.radiusMd` | `12.0` literal |
| `SakaiSnackBar.error(ctx, msg)` | `ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(...))` |
| `SakaiModalSheet.show(ctx, builder: ...)` | `showModalBottomSheet(context: ctx, builder: ...)` |
| `SakaiDialog.confirm(ctx, ...)` | bespoke `AlertDialog(...)` |
| `SakaiTextField(...)` / `SakaiFormField(...)` | bare `TextField(...)` |
| `SakaiPrimaryButton(label: ..., onPressed: ...)` | `ElevatedButton.styleFrom(backgroundColor: Colors.X)` |
| `AsyncValueView<T>(value: ..., dataBuilder: ...)` | hand-rolled `value.when(loading: ..., error: ..., data: ...)` |
| `SakaiSkeleton.list(itemCount: 4)` | custom shimmer / `CircularProgressIndicator` for list loaders |
| Verify light + dark per-screen | "Material 3 will handle it" |

## 7. Adding a new shared component

When you find a duplicated pattern across passenger + driver, extract it to `sakai_shared`:

1. **File location:** `mobile/shared/lib/widgets/sakai_<name>.dart`. Use `lower_snake_case` filenames. Class name is `Sakai<PascalName>`.
2. **Public API:** prefer factory constructors over enum-driven variants when there are 1-2 alternatives (e.g., `SakaiAppBar.transparent()` vs an enum). Use enums for 3+ variants (`SakaiStatus`, `SakaiAvatarSize`, `SakaiDividerInset`).
3. **Tokens only:** never read `Colors.X`. Source spacing / radii / elevation / motion from `SakaiDesignTokens.of(context)`; source colors from `Theme.of(context).colorScheme` or `SakaiSemanticColors.of(context)`.
4. **Tests:** add 2-3 widget tests under `mobile/shared/test/widgets/sakai_<name>_test.dart`. Cover the happy path + one branch (e.g., severity, disabled state, destructive flag).
5. **Export:** add to `mobile/shared/lib/sakai_shared.dart` in alphabetic order with the other `widgets/sakai_*` exports.
6. **No Google Maps SDK:** `mobile/shared/` must not depend on `google_maps_flutter`. Map widgets stay app-local.
7. **No new external state libs:** widgets should stay stateless or use `StatefulWidget` only. Don't introduce Bloc / Provider into shared. (Riverpod is used by `AsyncValueView` only because it's the rendering glue, not state.)
8. **Doc entry:** add a one-line entry under §4 of this doc.

## 8. Themes + dark mode

Both apps consume `SakaiTheme.light(config)` and `SakaiTheme.dark(config)` via `MaterialApp.themeMode: ThemeMode.system`. Verify any new screen in BOTH modes — Material 3's algorithmic surface tints don't always carry semantic intent across modes.

Specific dark-mode tweaks already applied in `SakaiTheme._build`:
- `AppBarTheme.surfaceTintColor = colorScheme.surface` in both modes to suppress the M3 scroll-under purple shift on the red seed.
- `AppBarTheme.scrolledUnderElevation = 1` so scrolled content visually lifts the bar.
- `SakaiSemanticColors.warningDark` raised +8% lightness in dark mode (amber retains contrast on dark surfaces).
- Driver config pins explicit `darkBackground` (`0xFF0D1117`), `darkSurface` (`0xFF161B22`), and `darkBorder` (`0xFF30363D`) to give the driver app a dispatch-grade dark identity.
- `InputDecorationTheme.fillColor` uses `surfaceContainerHighest` at `alpha: 0.2` (dark) / `0.4` (light) for tone-aware fields.

## 9. Where this lives

- Source: `mobile/shared/`
- Docs: `mobile/shared/docs/design-system.md` (this file)
- Index: linked from `mobile/shared/README.md`.
