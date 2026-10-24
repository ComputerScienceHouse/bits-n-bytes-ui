# UI Fixes — Flutter Jitter on Raspberry Pi

Working checklist of every change required to eliminate the dropped-frame jitter on the
Raspberry Pi 4B kiosk (`bits_n_bytes_ui`, flutter-pi / DRM-KMS). Each item is tagged
**[UI]** (CPU/Dart thread — profilable on any machine) or **[GPU]** (raster thread — only
truthfully measurable on the Pi). Diagnose with `flutter run --profile` + DevTools →
Performance: top bar = UI thread, bottom bar = raster thread.

**Status legend:** ✅ applied · ⬜ not yet applied

---

## Critical

### 1. ✅ [UI] Move serial parsing off the O(n²) string path
**File:** `lib/services/serial_service_real.dart` — `_onJsonDataReceived`

**Problem:** `currentBuffer += String.fromCharCodes(data)` plus repeated `substring` and a
char-by-char brace scan over the *whole* buffer on every chunk. Runs on the main isolate via
`SerialPortReader`, so it fights rendering on every byte the ESP/Jetson sends.

**Fix applied:** single forward index scan that tracks brace depth, dispatches each complete
JSON object via `_dispatchJson`, and keeps only the unconsumed tail in `_jsonBuffers`. No
per-chunk `+=`/`substring` rebuilds. Removed the dead `_accumulatedBuffer` field and the unused
`dart:developer` import.

> Further improvement (optional): move the read+parse into a background `Isolate`/`compute` and
> push only parsed objects back to the UI isolate.

### 2. ✅ [UI] Stop stacking anonymous `ValueNotifier` listeners
**Files:** `lib/pages/welcome.dart`, `lib/services/log_service.dart`, `lib/pages/admin.dart`

**Problem:** anonymous listeners were added but never removed, so they stacked. `welcome.dart`
added a fresh NFC listener from `initState`, the refresh button, **and** the 404 branch — one
packet then fired N handlers → N logins, N rebuilds, ever-growing CPU (jitter that worsens the
longer the kiosk runs).

**Fix applied:**
- `welcome.dart`: register `_onNfcData` **once** in `initState`; refresh button and 404 branch
  now only call `_sendNfcInit()` (send the init packet) instead of re-adding a listener;
  `dispose` removes `_onNfcData`.
- `admin.dart`: named `_onEspState`, added in `initState`, removed in `dispose`.
- `log_service.dart`: `init()` is now idempotent (`_initialized` guard) and registers named
  `_onEspState` / `_onJetsonState` listeners.

### 3. ✅ [UI/startup] Bundle fonts instead of fetching Google Fonts at runtime
**Files:** `lib/util.dart`, `pubspec.yaml`, `assets/fonts/`

**Problem:** `GoogleFonts.getTextTheme` downloaded font files over HTTP on first launch →
network-dependent startup stall + reflow when the fonts swapped in.

**Fix applied:** removed the `google_fonts` dependency; bundled the TTFs as assets
(`Roboto-Variable.ttf`, `IBMPlexMono-{Regular,Medium,SemiBold,Bold}.ttf`) and declared them under
`flutter: fonts:`. `createTextTheme` now applies the bundled families directly (Roboto = body,
IBM Plex Mono = display), so glyphs are present from the first frame.

### 4. ✅ [GPU] Drop blurred `BoxShadow`
**Files:** `lib/components/cart_item.dart`, `lib/components/shelf.dart`, `lib/pages/receipt.dart`

**Problem:** blur forces an offscreen `saveLayer`/compositing pass — the single most expensive op
on the Pi's GPU — and in the cart it happened per list item, rebuilt on every Jetson packet.

**Fix applied:** replaced each blurred `BoxShadow` with a flat 1px
`Border.all(color: outlineVariant)` (cart item, shelf, receipt card) and a flat left `BorderSide`
for the receipt sidebar. No offscreen layers.

---

## High priority (not yet applied)

### 5. ⬜ [GPU] `Image.network` decoded at full resolution
**File:** `lib/components/cart_item.dart:38`

Decodes the full-size image (displayed at 100×100) and re-decodes on cache eviction; the cart list
is rebuilt (`cart = List.from(cart)`) on every Jetson packet.

**Fix:** add `cacheWidth: 100` for a downsampled decode; consider `cached_network_image` or
pre-seeding the image cache.

### 6. ⬜ [UI] Log notifier copies a 100-element list on every log
**File:** `lib/services/log_service.dart`

`vn.value = [...vn.value, msg]` + `removeAt(0)` are both O(n), plus an unconditional `log()` per
event. Serial data is logged per packet → constant allocation/GC churn.

**Fix:** fixed-size ring buffer / `ListQueue`; gate verbose `log()` behind a debug flag; throttle.

### 7. ⬜ [UI] ESP state notifies on every packet, even when unchanged
**File:** `lib/services/serial_service_real.dart` (`espState.value = jsonData`)

Always notifies, waking `LogService.parseJsonChanges`, the CartPage door listener, and AdminPage —
per packet.

**Fix:** debounce/coalesce UI-facing updates (~10–20 Hz) and skip notifying on unchanged fields.

---

## Lower priority (not yet applied)

- ⬜ `CartItem` / `Shelf` are `StatefulWidget` with no state → make `StatelessWidget`.
- ⬜ Add `const` constructors to static subtrees to cut rebuilds.
- ⬜ `MediaQuery.sizeOf(context).width` read inside item builders
  (`cart_item.dart:16`, `shelf.dart:85`) → hoist above the builder.
- ⬜ `SvgPicture.asset` rasterizes vectors at runtime → pre-rasterize static logos to PNG.
- ⬜ `cart = List.from(cart)` after mutating in place (`cart.dart`) is a redundant allocation.

---

## Verification rules

- **Measure, don't guess.** Reproduce with `flutter run --profile` on the Pi and watch the UI vs
  raster split before/after each change. UI-thread items (1, 2, 3, 6, 7) verify on any machine;
  GPU items (4, 5) need the Pi to confirm.
- **Do not** judge jitter by eye over a `--stream` (Sunshine/Moonlight) session — the encoder adds
  latency that masks/fakes smoothness. Use on-device DevTools metrics.
- `bnb run sim` validates the serial/framing path cross-platform (no GPU) in seconds.
- `bnb run dev` runs the full kiosk on the Pi with real GPU + hot reload for final sign-off.
