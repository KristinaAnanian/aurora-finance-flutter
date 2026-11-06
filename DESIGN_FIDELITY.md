# Aurora Finance — UI fidelity brief

The supplied 3-phone dark fintech reference and our HTML prototype are the
visual targets for the Android Flutter build. This is a real offline budget
tracker, so product functions should remain honest (no implied bank connection).

## Design tokens (logical px)

| Token | Value |
|---|---|
| Page background | `#0C0C0D` |
| Secondary cards | `#232324` |
| Muted labels | `#A4A4A8` |
| Page horizontal margin | `17` |
| Hero balance card | `174` high, `14` radius |
| Quick-action cards | `67` high, `13` radius |
| Bottom navigation | `52` high, rounded `32` |
| Analytics chart card | `13` radius |
| Editor gradient panel | `179` high, `13` radius |
| Form panels | `#242426`, `11–12` radius |

## Motion

- Six softly feathered moving color fields blend on the balance and amount cards.
- Primary aurora loop: **52 seconds**; the soft dark header glow: **64 seconds**.
- Colored areas translate a small amount along separate paths. Text and controls
  are not transformed or blurred.
- The Home screen ticker is disabled when another tab is active, avoiding
  offscreen animation work.
- `RepaintBoundary` isolates animation from controls; custom paint has no
  downloads, videos, heavy blur image assets, or networking.
- Reduced-motion accessibility preferences disable these repeating animations
  at startup. Device testing should verify performance on lower-end phones.

## Real data vs visual examples

- On first use, balance shows 0 and a helpful empty state.
- `Preview design` overlays explicitly labeled, in-memory samples in Home and
  Analytics. No sample is saved. The 841.12 sample total is derived from
  sample entries, not hardcoded into the analytics widget.
- Starting a real transaction exits visual preview. History and SQLite always
  show real records only.

## Visual QA when Flutter is available

1. Run `flutter analyze` and `flutter test`.
2. Compare Home, Analytics and EntryEditor to the HTML at 360 × 800 dp and
   on a narrow Android phone; inspect clipping and text scaling.
3. Watch the gradient for a full 52-second cycle, including restarting the app.
4. Verify that preview amounts are never stored, and real transactions are
   retained after restarting the app.
5. Verify that a hardware keyboard, soft keyboard, and reduced-motion setting
   do not make amount/date/category fields unreachable.

No APK was compiled or emulator screenshot captured in the authoring environment.
