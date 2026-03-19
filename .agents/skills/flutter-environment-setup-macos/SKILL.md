---
name: "flutter-environment-setup-macos"
description: "Set up a macOS environment for Flutter development"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Thu, 26 Feb 2026 23:40:36 GMT"

---
# flutter-macos-setup

## Goal
Configures a macOS development environment for building, running, and deploying Flutter applications. Validates tooling dependencies including Xcode and CocoaPods, and ensures the environment passes Flutter's diagnostic checks for macOS desktop development. Assumes the host operating system is macOS and the user has administrative privileges.

## Instructions

1. **Verify Flutter Installation**
   Check if Flutter is installed and accessible in the current environment.
   ```bash
   flutter --version
   ```
   *Decision Logic:*
   * If the command fails, **STOP AND ASK THE USER:** "Flutter is not installed or not in your PATH. Please install Flutter and add it to your PATH before continuing."
   * If the command succeeds, proceed to step 2.

2. **Verify Xcode Installation**
   Ensure Xcode is installed on the macOS system.
   ```bash
   xcodebuild -version
   ```
   *Decision Logic:*
   * If Xcode is not installed, **STOP AND ASK THE USER:** "Xcode is required for macOS Flutter development. Please install the latest version of Xcode from the Mac App Store and notify me when complete."
   * If Xcode is installed, proceed to step 3.

3. **Configure Xcode Command-Line Tools**
   Link the Xcode command-line tools to the installed version of Xcode and run the first-launch setup.
   **STOP AND ASK THE USER:** "I need to configure Xcode command-line tools. This requires administrative privileges. Please run the following command in your terminal and confirm when done:"
   ```bash
   sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
   ```
   *(Note: If the user installed Xcode in a non-standard directory, instruct them to replace `/Applications/Xcode.app` with their custom path).*

4. **Accept Xcode Licenses**
   The Xcode license agreements must be accepted before compilation can occur.
   **STOP AND ASK THE USER:** "Please run the following command to review and accept the Xcode license agreements:"
   ```bash
   sudo xcodebuild -license
   ```

5. **Install CocoaPods**
   CocoaPods is required for Flutter plugins that utilize native macOS code.
   Check if CocoaPods is installed:
   ```bash
   pod --version
   ```
   *Decision Logic:*
   * If installed, proceed to step 6.
   * If not installed, instruct the user to install it (e.g., via Homebrew or RubyGems) and verify the installation.
   ```bash
   sudo gem install cocoapods
   ```

6. **Validate Setup (Validate-and-Fix Loop)**
   Run the Flutter diagnostic tool to check for any remaining macOS toolchain issues.
   ```bash
   flutter doctor -v
   ```
   *Decision Logic:*
   * Analyze the output under the **Xcode** section.
   * If there are errors or missing components, identify the specific missing dependency, provide the user with the exact command to fix it, and re-run `flutter doctor -v`.
   * Repeat this loop until the Xcode section reports no issues.

7. **Verify Device Availability**
   Ensure Flutter can detect the macOS desktop as a valid deployment target.
   ```bash
   flutter devices
   ```
   Verify that at least one entry in the output has "macos" listed as the platform. If it is missing, instruct the user to enable macOS desktop support:
   ```bash
   flutter config --enable-macos-desktop
   ```

## Constraints
* Do NOT include any external URLs or links in the output or prompts.
* Do NOT attempt to run `sudo` commands automatically; always pause and provide the exact command for the user to execute.
* Do NOT explain basic terminal usage or general macOS concepts.
* MUST ensure the `flutter doctor` Xcode section is completely clear of errors before considering the skill complete.
* MUST assume the user is operating on a macOS environment; do not provide Windows or Linux alternatives.
