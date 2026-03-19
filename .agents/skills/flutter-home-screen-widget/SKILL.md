---
name: "flutter-home-screen-widget"
description: "Adding a Home Screen widget to your Flutter App"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Fri, 06 Mar 2026 20:49:44 GMT"

---
# flutter-home-screen-widgets

## Goal
Implements native home screen widgets (iOS and Android) for a Flutter application using the `home_widget` package. It establishes data sharing between the Dart environment and native platforms via App Groups (iOS) and SharedPreferences (Android), enabling text updates and rendering Flutter UI components as images for native display. Assumes a pre-existing Flutter project environment with native build tools (Xcode and Android Studio) configured.

## Instructions

1. **Initialize Dependencies**
   Add the `home_widget` package to the Flutter project.
   ```bash
   flutter pub add home_widget
   flutter pub get
   ```

2. **Decision Logic: Platform & Feature Selection**
   Determine the target platforms and required widget capabilities.
   **[BLOCKING] User Consultation**
   BEFORE performing any implementation, you MUST ask:
   * "Which platforms are you targeting?"
   * "Do you need simple text or complex UI?"

   
   *Flowchart:*
   * If iOS -> Proceed to Step 4 (iOS Native Setup).
   * If Android -> Proceed to Step 5 (Android Native Setup).
   * If rendering Flutter UI as images -> Proceed to Step 6 after basic setup.

3. **Implement Dart Data Sharing Logic**
   Create the Dart logic to save data to the native key/value store and trigger widget updates.
   ```dart
   import 'package:home_widget/home_widget.dart';

   // Replace with actual App Group ID for iOS
   const String appGroupId = 'group.com.yourcompany.app'; 
   const String iOSWidgetName = 'NewsWidgets';
   const String androidWidgetName = 'NewsWidget';

   Future<void> updateWidgetData(String title, String description) async {
     await HomeWidget.setAppGroupId(appGroupId);
     await HomeWidget.saveWidgetData<String>('headline_title', title);
     await HomeWidget.saveWidgetData<String>('headline_description', description);
     await HomeWidget.updateWidget(
       iOSName: iOSWidgetName,
       androidName: androidWidgetName,
     );
   }
   ```

4. **iOS Native Setup (If applicable)**
   * Configure an App Group in Xcode for both the Runner target and the Widget Extension target.
   * Create a Widget Extension target in Xcode (e.g., `NewsWidgets`). Uncheck "Include Live Activity" and "Include Configuration Intent".
   * Implement the `TimelineProvider` and `View` in Swift:
   ```swift
   import WidgetKit
   import SwiftUI

   struct NewsArticleEntry: TimelineEntry {
       let date: Date
       let title: String
       let description: String
   }

   struct Provider: TimelineProvider {
       func placeholder(in context: Context) -> NewsArticleEntry {
           NewsArticleEntry(date: Date(), title: "Placeholder Title", description: "Placeholder description")
       }

       func getSnapshot(in context: Context, completion: @escaping (NewsArticleEntry) -> ()) {
           let entry: NewsArticleEntry
           if context.isPreview {
               entry = placeholder(in: context)
           } else {
               // Replace with actual App Group ID
               let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.app")
               let title = userDefaults?.string(forKey: "headline_title") ?? "No Title Set"
               let description = userDefaults?.string(forKey: "headline_description") ?? "No Description Set"
               entry = NewsArticleEntry(date: Date(), title: title, description: description)
           }
           completion(entry)
       }

       func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
           getSnapshot(in: context) { (entry) in
               let timeline = Timeline(entries: [entry], policy: .atEnd)
               completion(timeline)
           }
       }
   }

   struct NewsWidgetsEntryView : View {
       var entry: Provider.Entry

       var body: some View {
           VStack(alignment: .leading) {
               Text(entry.title).font(.headline)
               Text(entry.description).font(.subheadline)
           }
       }
   }
   ```
   *Validate-and-Fix:* Run `flutter build ios --config-only` to ensure the Flutter configuration syncs with the new Xcode targets. If build fails, verify the App Group ID matches exactly between Dart and Swift.

5. **Android Native Setup (If applicable)**
   * Create an `AppWidgetProvider` in Android Studio (`New -> Widget -> App Widget`).
   * Define the XML layout (`res/layout/news_widget.xml`):
   ```xml
   <RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
       android:id="@+id/widget_container"
       android:layout_width="match_parent"
       android:layout_height="match_parent"
       android:background="@android:color/white">
       <TextView
           android:id="@+id/headline_title"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="Title"
           android:textStyle="bold"
           android:textSize="20sp" />
       <TextView
           android:id="@+id/headline_description"
           android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:layout_below="@+id/headline_title"
           android:text="Description"
           android:textSize="16sp" />
   </RelativeLayout>
   ```
   * Implement the Kotlin Provider (`NewsWidget.kt`):
   ```kotlin
   package com.yourdomain.yourapp

   import android.appwidget.AppWidgetManager
   import android.appwidget.AppWidgetProvider
   import android.content.Context
   import android.widget.RemoteViews
   import es.antonborri.home_widget.HomeWidgetPlugin

   class NewsWidget : AppWidgetProvider() {
       override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
           for (appWidgetId in appWidgetIds) {
               val widgetData = HomeWidgetPlugin.getData(context)
               val views = RemoteViews(context.packageName, R.layout.news_widget).apply {
                   val title = widgetData.getString("headline_title", null)
                   setTextViewText(R.id.headline_title, title ?: "No title set")

                   val description = widgetData.getString("headline_description", null)
                   setTextViewText(R.id.headline_description, description ?: "No description set")
               }
               appWidgetManager.updateAppWidget(appWidgetId, views)
           }
       }
   }
   ```

6. **Render Flutter Widgets as Images (Optional)**
   If the user requires complex UI (like charts) on the widget, render the Flutter widget to a PNG and pass the file path.
   *Dart Implementation:*
   ```dart
   final _globalKey = GlobalKey();

   // Wrap your target widget with a RepaintBoundary/Key
   // Center(key: _globalKey, child: const LineChart())

   Future<void> renderAndSaveWidget() async {
     if (_globalKey.currentContext != null) {
       var path = await HomeWidget.renderFlutterWidget(
         const LineChart(),
         fileName: 'screenshot',
         key: 'filename',
         logicalSize: _globalKey.currentContext!.size,
         pixelRatio: MediaQuery.of(_globalKey.currentContext!).devicePixelRatio,
       );
       await HomeWidget.updateWidget(iOSName: iOSWidgetName, androidName: androidWidgetName);
     }
   }
   ```
   *Native Image Loading (Android Example):*
   ```kotlin
   // Inside RemoteViews apply block:
   val imageName = widgetData.getString("filename", null)
   val imageFile = java.io.File(imageName)
   if (imageFile.exists()) {
       val myBitmap = android.graphics.BitmapFactory.decodeFile(imageFile.absolutePath)
       setImageViewBitmap(R.id.widget_image, myBitmap)
   }
   ```

## Constraints
* **Immutable Native Identifiers:** The `iOSName` and `androidName` in Dart MUST exactly match the Swift struct name and Kotlin class name respectively.
* **App Group Prefix:** iOS App Group IDs MUST be prefixed with `group.` and match exactly in Xcode capabilities, Swift `UserDefaults(suiteName:)`, and Dart `HomeWidget.setAppGroupId()`.
* **No Direct Flutter UI:** Never attempt to render Flutter widgets directly in the native widget lifecycle. You MUST use `renderFlutterWidget` to generate a static image if complex UI is required.
* **Full Re-run Required:** Changing native code (PendingIntents, Layouts, Manifest) requires a full `flutter run`.
* **Widget Re-add:** After native changes, it is often necessary to remove and re-add the widget on the home screen for changes to take effect.
* **Android Cell Sizing:** Android widget dimensions in `res/xml/*_info.xml` must be calculated in cells (e.g., `minWidth="250dp"`). Do not use arbitrary pixel values.
* **Validate-and-Fix:** Always instruct the user to run native builds (`flutter build ios` / `flutter build apk`) after modifying native files to catch syntax or linking errors immediately.
