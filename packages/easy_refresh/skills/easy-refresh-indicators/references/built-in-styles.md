# Built-in styles and extension packages

All built-in types below are exported by
`package:easy_refresh/easy_refresh.dart` in 4.x. No style package or Rive setup
is needed for them. Defaults below describe the public constructors; changing
physics or wrapping in `EasyRefresh.nested` can change the effective behavior.

| Style | Header / Footer | Axes | triggerOffset | clamping | Header / Footer infiniteOffset |
| --- | --- | --- | --- | --- | --- |
| Classic | `ClassicHeader` / `ClassicFooter` | Vertical, horizontal | 70 | false | null / 70 |
| Material | `MaterialHeader` / `MaterialFooter` | Vertical, horizontal | 100 | true | null / null |
| Cupertino | `CupertinoHeader` / `CupertinoFooter` | Vertical, horizontal | 60 | false | null / 60 |
| Bezier | `BezierHeader` / `BezierFooter` | Vertical, horizontal | 100 | false | null / null |
| BezierCircle | `BezierCircleHeader` only | Vertical | 100 | false | null / not applicable |
| Phoenix | `PhoenixHeader` / `PhoenixFooter` | Vertical | 100 | false | null / null |
| Taurus | `TaurusHeader` / `TaurusFooter` | Vertical | 100 | false | null / null |
| Delivery | `DeliveryHeader` / `DeliveryFooter` | Vertical | `kDeliveryTriggerOffset` | false | null / null |

There is no `BezierCircleFooter`. Pair its Header with another supported Footer.
Cupertino defaults to `IndicatorPosition.behind`; the others default to `above`.
Do not assume all Header options are available on every built-in constructor.

## Customization by style

| Style | Useful public parameters |
| --- | --- |
| Classic | `dragText`, `armedText`, `readyText`, `processingText`, `processedText`, `failedText`, `noMoreText`; `showText`, `showMessage`, `messageText`; `textStyle`, `messageStyle`; `textBuilder`, `messageBuilder`, `pullIconBuilder`; result icons, `iconTheme`, spacing and dimensions, progress size/stroke, `backgroundColor`, `boxDecoration`. |
| Material | `color`, `backgroundColor`, `valueColor`, `semanticsLabel`, `semanticsValue`, `noMoreIcon`; optional `showBezierBackground`, `bezierBackgroundColor`, `bezierBackgroundAnimation`, `bezierBackgroundBounce`. |
| Cupertino | `foregroundColor`, `backgroundColor`, `emptyWidget`, `userWaterDrop` (this is the actual spelling). Water drop defaults to true on Header and false on Footer. |
| Bezier | `foregroundColor`, `backgroundColor`, `showBalls`, `spinWidget`, `spinBuilder`, `noMoreWidget`, `spinInCenter`, `onlySpin`. |
| BezierCircle | `foregroundColor`, `backgroundColor`; built-in disappearance duration. |
| Phoenix / Taurus / Delivery | `skyColor`; these illustrations are vertical-only. Delivery fixes `safeArea: false`. |

Classic/Cupertino Footers enable infinite loading by default. To require an
explicit pull, use `infiniteOffset: null`. To enable infinite loading on another
Footer, use a nonnegative `infiniteOffset` with `clamping: false`. Never keep a
non-null infiniteOffset when enabling clamping or a secondary panel.

`processedDuration` controls the completed-state display, not the request
duration. Some styles fix it for their animation (BezierCircle, Taurus,
Delivery); configure only what the concrete constructor exposes.

## Six optional Rive style packages

Choose only the requested extension, add it as a dependency, and import its
matching entrypoint (`package:<package>/<package>.dart`) alongside easy_refresh.
The current extension release line is 2.x and depends on easy_refresh 4.x,
Flutter >=3.47, Dart ^3.13 and Rive ^0.14.11.

| Package | Header / Footer | Trigger | Package-specific notes |
| --- | --- | --- | --- |
| `easy_refresh_bow` | `BowHeader` / `BowFooter` | 200 | Bow spring, release-triggered; exposes `safeArea`. |
| `easy_refresh_bubbles` | `BubblesHeader` / `BubblesFooter` | 180 | Release-triggered bubbles; fixed `safeArea: false`. |
| `easy_refresh_halloween` | `HalloweenHeader` / `HalloweenFooter` | 200 | Default `processedDuration: Duration.zero`. |
| `easy_refresh_skating` | `SkatingHeader` / `SkatingFooter` | 180 | Fixed 700 ms completed animation; no `processedDuration` argument. |
| `easy_refresh_space` | `SpaceHeader` / `SpaceFooter` | 180 | Default `processedDuration: Duration.zero`. |
| `easy_refresh_squats` | `SquatsHeader` / `SquatsFooter` | 190 | Exposes `backgroundColor`; default zero completed duration. |

All six require vertical scrolling. They default to `clamping: false`,
`springRebound: false`, `safeArea: false`, and `infiniteOffset: null` on both
Header and Footer. They bundle their own `.riv` assets and manage animation
objects internally; the consumer does not copy asset files or supply a Rive
controller. For explicit startup initialization, declare `rive: ^0.14.11` in
the app and await `RiveNative.init()` after
`WidgetsFlutterBinding.ensureInitialized()` and before `runApp()`.

Each extension ships a standalone usage skill with its complete startup
example. General controller completion stays the same regardless of style.
