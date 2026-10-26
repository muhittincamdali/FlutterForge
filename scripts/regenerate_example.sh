#!/usr/bin/env bash
# Regenerates the Dart and Markdown files of example/ with `forge create`, so
# the committed example stays the exact output of the generator. The platform
# folders (android/, ios/) are left as they are.
#
#   scripts/regenerate_example.sh
set -euo pipefail

cd "$(dirname "$0")/.."
staging="_example_staging"
rm -rf "$staging"
trap 'rm -rf "$staging"' EXIT

dart run bin/forge.dart create forge_example \
  --output-directory "$staging" \
  --forge-path . \
  --org dev.flutterforge \
  --description "The FlutterForge example app: a todo list read from a JSON API." \
  --no-flutter-create \
  --no-pub

(cd "$staging" && find . -type f) | while read -r file; do
  mkdir -p "example/$(dirname "$file")"
  cp "$staging/$file" "example/$file"
done
echo "example/ regenerated. Review it with: git diff -- example"
