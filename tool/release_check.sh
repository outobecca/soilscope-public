#!/usr/bin/env bash
# Repeatable release gate.
#
#   tool/release_check.sh            # everything
#   SKIP_WEB=1 tool/release_check.sh # skip the web build
#
# Measured field data is not bundled (see docs/validation/README.md); this gate
# proves internal consistency and reproducibility, not field accuracy.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Model parameter set =="
model_record="$(dart run tool/model_version.dart)"
echo "${model_record%%$'\n'*}"

base_ref=""
if git rev-parse --verify --quiet origin/master >/dev/null; then
  base_ref="$(git merge-base origin/master HEAD)"
elif git rev-parse --verify --quiet master >/dev/null; then
  base_ref="$(git merge-base master HEAD)"
fi

if [[ -n "$base_ref" ]]; then
  echo "== Whitespace & formatting of added Dart files =="
  git diff --check "$base_ref"...HEAD
  added_dart="$(git diff --name-only --diff-filter=A "$base_ref" HEAD -- '*.dart' \
    | grep -vE '(\.g|\.freezed|\.gr)\.dart$|app_localizations' || true)"
  if [[ -n "$added_dart" ]]; then
    printf '%s\n' "$added_dart" | xargs dart format --output=none --set-exit-if-changed
  fi
fi

echo "== Analysis =="
flutter analyze --no-pub --fatal-infos

echo "== Localization guards =="
if [[ -n "$base_ref" ]]; then
  python3 tool/check_l10n.py --base "$base_ref"
else
  python3 tool/check_l10n.py
fi
python3 tool/check_hardcoded_finnish.py

echo "== Test suite & coverage gates =="
flutter test --no-pub --coverage
python3 tool/check_coverage.py

echo "== Validation gates =="
flutter test --no-pub test/validation/

echo "== Performance benchmarks =="
flutter test --no-pub test/performance/phase4_benchmark_test.dart

if [[ "${SKIP_WEB:-0}" != "1" ]]; then
  echo "== Web build =="
  flutter build web --release --base-href /soilscope-public/
fi

echo "Release checks passed."
