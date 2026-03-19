---
name: "flutter-native-interop"
description: "Interoperate with native APIs in a Flutter app on Android, iOS, and the web"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Wed, 04 Mar 2026 19:26:40 GMT"

---
# Flutter Platform Integration

## Goal
Integrates Flutter applications with platform-specific code and native features across Android, iOS, and Web environments. Determines the optimal interoperability strategy (FFI, Platform Channels, Platform Views, or JS Interop) and implements the necessary Dart and native code bindings while adhering to thread safety, WebAssembly (Wasm) compatibility, and modern build hook standards.

## Instructions

### 1. Determine Integration Strategy (Decision Logic)
Evaluate the user's requirements using the following decision tree to select the correct integration path:

*   **Scenario A: Calling native C/C++ code.**
    *   *Action:* Use `dart:ffi` with the `package_ffi` template and build hooks.
    *   *Exception:* If accessing the Flutter Plugin API or requiring static linking on iOS, use the legacy `plugin_ffi` template.
*   **Scenario B: Calling OS-specific APIs (Java/Kotlin for Android, Swift/Obj-C for iOS).**
    *   *Action:* Use Platform Channels (`MethodChannel`) or the `pigeon` package for type-safe code generation.
*   **Scenario C: Embedding native UI components into the Flutter widget tree.**
    *   *Action:* Use Platform Views (`AndroidView` / `AndroidViewSurface` for Android, `UiKitView` for iOS).
*   **Scenario D: Web integration and JavaScript APIs.**
    *   *Action:* Use `package:web` and `dart:js_interop` (Wasm-compatible). Use `HtmlElementView` for embedding web content.

**STOP AND ASK THE USER:** "Which platform(s) are you targeting, and what specific native functionality or UI component do you need to integrate?"

### 2. Implement C/C++ Interop (`dart:ffi`)
If Scenario A is selected, implement the modern FFI architecture using build hooks (Flutter 3.38+).

1.  Generate the package:
    ```bash
    flutter create --template=package_ffi native_add
    ```
2.  Configure the build hook (`hook/build.dart`) to compile the native code:
    ```dart
    import 'package:hooks/hooks.dart';
    import 'package:native_toolchain_c/native_toolchain_c.dart';

    void main(List<String> args) async {
      await build(args, (config, output) async {
        final builder = CBuilder.library(
          name: 'native_add',
          assetId: 'native_add/src/native_add.dart',
          sources: ['src/native_add.c'],
        );
        await builder.run(config: config, output: output);
      });
    }
    ```
3.  Bind the native function in Dart (`lib/src/native_add.dart`):
    ```dart
    import 'dart:ffi';

    @Native<Int32 Function(Int32, Int32)>()
    external int sum(int a, int b);
    ```

### 3. Implement Platform Channels (MethodChannel)
If Scenario B is selected, implement asynchronous message passing.

1.  **Dart Client Implementation:**
    ```dart
    import 'package:flutter/services.dart';

    class NativeApi {
      static const platform = MethodChannel('com.example.app/channel');

      Future<String> getNativeData() async {
        try {
          final String result = await platform.invokeMethod('getData');
          return result;
        } on PlatformException catch (e) {
          return "Error: '${e.message}'.";
        }
      }
    }
    ```
2.  **Android Host Implementation (Kotlin):**
    ```kotlin
    import androidx.annotation.NonNull
    import io.flutter.embedding.android.FlutterActivity
    import io.flutter.embedding.engine.FlutterEngine
    import io.flutter.plugin.common.MethodChannel

    class MainActivity: FlutterActivity() {
      private val CHANNEL = "com.example.app/channel"

      override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
          if (call.method == "getData") {
            result.success("Data from Android")
          } else {
            result.notImplemented()
          }
        }
      }
    }
    ```
3.  **iOS Host Implementation (Swift):**
    ```swift
    import Flutter
    import UIKit

    @UIApplicationMain
    @objc class AppDelegate: FlutterAppDelegate {
      override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.app/channel", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if call.method == "getData" {
            result("Data from iOS")
          } else {
            result(FlutterMethodNotImplemented)
          }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
    }
    ```

### 4. Implement Platform Views
If Scenario C is selected, embed native views.

1.  **Dart Implementation (iOS Example):**
    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';

    Widget buildNativeView() {
      const String viewType = '<platform-view-type>';
      final Map<String, dynamic> creationParams = <String, dynamic>{};

      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    ```
2.  **iOS Factory Implementation (Swift):**
    ```swift
    import Flutter
    import UIKit

    class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
        private var messenger: FlutterBinaryMessenger

        init(messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            super.init()
        }

        func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
            return FLNativeView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
        }

        public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
              return FlutterStandardMessageCodec.sharedInstance()
        }
    }

    class FLNativeView: NSObject, FlutterPlatformView {
        private var _view: UIView

        init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
            _view = UIView()
            super.init()
            _view.backgroundColor = UIColor.blue
        }

        func view() -> UIView { return _view }
    }
    ```
    *Validate-and-Fix:* Ensure the factory is registered in `AppDelegate.swift` using `registrar.register(factory, withId: "<platform-view-type>")`.

### 5. Implement Web Integration (Wasm & JS Interop)
If Scenario D is selected, implement Wasm-compatible web integrations.

1.  **JS Interop (Dart):**
    ```dart
    import 'dart:js_interop';
    import 'package:web/web.dart' as web;

    @JS('console.log')
    external void log(JSAny? value);

    void manipulateDOM() {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.text = "Hello from Wasm-compatible Dart!";
      web.document.body?.append(div);
      log("DOM updated".toJS);
    }
    ```
2.  **Embedding HTML Elements:**
    ```dart
    import 'package:flutter/widgets.dart';
    import 'package:web/web.dart' as web;

    Widget buildVideoElement() {
      return HtmlElementView.fromTag('video', onElementCreated: (Object video) {
        final videoElement = video as web.HTMLVideoElement;
        videoElement.src = 'https://example.com/video.mp4';
        videoElement.style.width = '100%';
        videoElement.style.height = '100%';
      });
    }
    ```

## Constraints
*   **Thread Safety:** Whenever you invoke a channel method on the platform side destined for Flutter, you MUST invoke it on the platform's main/UI thread. Use `Handler(Looper.getMainLooper()).post` (Android) or `DispatchQueue.main.async` (iOS) if jumping from a background thread.
*   **WebAssembly Compatibility:** DO NOT use `dart:html`, `dart:js`, or `package:js`. You MUST use `package:web` and `dart:js_interop` to ensure the app compiles to Wasm.
*   **Wasm iOS Limitation:** Flutter compiled to Wasm currently CANNOT run on the iOS version of any browser due to WebKit limitations. Ensure fallback to JS compilation is maintained.
*   **FFI Naming:** When implementing `build.dart` hooks for Apple platforms, dynamic libraries MUST have consistent filenames across all target architectures (e.g., do not use `lib_arm64.dylib`).
*   **Platform View Performance:** Handling `SurfaceView` on Android via Platform Views is problematic and should be avoided when possible. Prefer `TextureLayerHybridComposition` for better Flutter rendering performance.
