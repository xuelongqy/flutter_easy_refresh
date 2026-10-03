# Publishing v4 with Melos

Run commands from the repository root. The versions and CHANGELOG entries for
this release are already prepared:

| Packages | Version |
| --- | --- |
| `easy_refresh`, `easy_paging` | `4.0.0` |
| `easy_refresh_bow`, `easy_refresh_bubbles`, `easy_refresh_halloween` | `2.0.0` |
| `easy_refresh_skating`, `easy_refresh_space`, `easy_refresh_squats` | `2.0.0` |

The packages require Flutter >= 3.47.0 and Dart ^3.13.0. The root workspace and
example are private and are excluded from publishing.

## Validate

Commit the release files first: pub reports a validation warning if package
files such as CHANGELOGs are still modified in Git.

```bash
flutter pub get
dart run melos list --no-private
dart run melos run release:check
```

`release:check` explicitly uses `melos publish --dry-run`. It validates the eight
packages using their existing `pubspec.yaml` versions. It does not publish,
generate CHANGELOG entries, commit, or tag.

Before publishing, run formatting, analysis, package skill checks, and all
`easy_refresh`, `easy_paging`, and example tests. Confirm that CI passed on the
commit being released, including the minimum supported Flutter version.

## Publish

After reviewing the package/version list, run:

```bash
dart run melos run release:publish
```

This script explicitly uses `melos publish --no-dry-run --no-private
--git-tag-version --yes`. Running it performs a real upload without another
confirmation prompt: the script wrapper does not forward interactive input to
the child command. Review the package/version list with `release:check` first.
Melos publishes
serially in dependency order, with `easy_refresh` before its dependents, and
creates package-specific local Git tags when the command succeeds. It does not
push those tags or create GitHub releases.

If publication stops, check pub.dev for the versions already uploaded before
retrying. If a dependent package cannot resolve the newly published
`easy_refresh`, wait until `4.0.0` is available on pub.dev, then rerun the command.
Do not change a successfully published version's contents.

## Preserve the prepared versions and CHANGELOGs

For this release, **do not run `melos version`**: the target versions are already
in the package manifests. `melos publish` uses those values without incrementing
them or rewriting the hand-maintained CHANGELOGs.

For a later release that actually needs a version change, specify an exact
version and disable automatic CHANGELOG generation, for example:

```bash
dart run melos version easy_refresh 4.0.1 \
  --no-changelog --no-dependent-versions --no-git-commit-version
```

Review the resulting dependency constraints and manually update the package and
root CHANGELOGs before committing. `--no-git-commit-version` also prevents tag
creation during version preparation. A bare `melos version` infers versions from
Conventional Commits and generates CHANGELOG entries by default.

## GitHub Release and online example

Publish the pub packages before creating the repository release. Build the
example with the same Flutter SDK and dependency lockfile used for validation:

```bash
cd example
flutter build apk --release --no-pub
flutter build web --release --wasm --no-pub --no-web-resources-cdn \
  --dart-define=RIVE_NATIVE_WASM_HOST=rive/
```

Upload `example/build/app/outputs/flutter-apk/app-release.apk` to the repository
release. The example currently uses the existing debug signing configuration;
this APK is a demonstration build, not a Play Store distribution build. Check
its package name, version, signing verification, and SHA-256 before uploading.

For GitHub Pages, change only the generated `build/web/index.html` base from
`<base href="/">` to `<base href="./">`. Flutter requires an absolute base at
build time, so apply the relative base after compilation. Keep the source
`web/index.html` placeholder unchanged.

The Rive host above is also relative. Copy both `wasm/` and
`wasm_compatibility/` from the official `@rive-app/flutter-native-wasm` npm
package into `build/web/rive/`, including each directory's JavaScript and Wasm
file. Use the version declared by the installed `rive_native` package's
`lib/src/wasm_version.dart` (44.0.0 for this release), verify the npm tarball's
integrity, and include the runtime's MIT license. `--no-web-resources-cdn`
already includes local CanvasKit files.

Serve the completed output under `/flutter_easy_refresh/` and verify that the
app, local renderers, and Rive animations load without missing resources.
Back up the old Pages directory, replace its complete contents with `build/web/`
(including deletion of obsolete files), and commit only that directory. Verify
the Pages deployment before announcing the release.
