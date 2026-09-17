# Repo standards

## Non-negotiables

- `flutter analyze` reports zero issues.
- `flutter test` passes every test.
- No TODOs, stubs, or placeholder implementations.
- No god files. Keep drawing, music, playback, audio, and UI in their own
  layers under `lib/src/`.

## Commits and tests

- Write a test with every behavior change; never merge a failing suite.
- Keep diffs focused: one concern per change.
- Commit subjects follow Conventional Commits so cocogitto can bump
  versions: `<type>: <description>` where the type is English
  (`feat`, `fix`, `chore`, `ci`, `docs`, `refactor`, `style`, `test`,
  `perf`, `revert`, `build`, `misc`) and the description is Chinese.
  Run `git config core.hooksPath .githooks` once so non-conventional
  subjects are auto-prefixed with `misc:`.
- Releases are automatic. A `feat`/`fix`/`perf`/`revert` commit merged to
  `main` makes cocogitto bump `pubspec.yaml`, tag `vX.Y.Z`, and ship a
  full platform release through GitHub Actions back to GitLab.

## Release pipeline

- GitLab is the source of truth. `github-sync` mirrors `main` and tags to
  `github.com/justacalico/artboard`.
- `.github/workflows/build.yml` builds android (signed apk + aab), linux
  (x86_64+arm64: zip/deb/rpm/tar.gz), windows (x86_64+arm64), macOS arm64,
  and an unsigned iOS ipa, then publishes a GitHub release.
- `github-release-sync` mirrors the GitHub release assets into a GitLab
  release on the same tag.
- Android signing comes from `key.properties` + `upload-keystore.jks`,
  which are gitignored and injected from GitHub secrets. Never commit
  keystores or credentials.
- All GitLab jobs run on the self-hosted `linux-truenas` runner.
