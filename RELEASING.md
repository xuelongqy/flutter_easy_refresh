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
