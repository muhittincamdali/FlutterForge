# Contributing

Thanks for taking the time to improve FlutterForge.

## Reporting bugs

Open an issue with:

- the `ForgeClient` settings or the `forge` command line you used,
- what you expected and what happened (the exception type and its message, or the output of
  `forge`),
- `flutter --version` and the platform (Android, iOS, macOS, Windows, Linux, web or the Dart VM).

Report security issues privately as described in the
[security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change.
3. Run the checks:

   ```sh
   dart format --output=none --set-exit-if-changed .
   dart analyze
   dart test
   cd example && flutter analyze && flutter test
   ```

4. If you change the client, add or update a test in `test/network/`. The fake `http.Client` in
   `test/support/fake_http.dart` can stream a body, never answer, or record aborts.
5. If you change a template in `lib/src/cli/templates/`, run `scripts/regenerate_example.sh`
   and commit the changes in `example/`. `test/cli/example_sync_test.dart` fails while the
   example and the templates differ.
6. If you change a code sample in `README.md`, change its copy in `test/readme_test.dart`.
7. If a change affects the example's screens, run `scripts/screenshots.sh` on a Mac with Xcode.
8. `README.md` has translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI fails while a translation is behind. If you change
   `README.md` and cannot update the translations, say so in the pull request and they will be
   updated before it is merged.
9. Add a line under "Unreleased" in `CHANGELOG.md`.

## Code style

- Follow [Effective Dart](https://dart.dev/effective-dart); `analysis_options.yaml` enables
  the extra lints the package uses, and lines are up to 120 characters.
- Document every public member with `///` comments; `dart doc` fails on unresolved references.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).
