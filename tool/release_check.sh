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

echo "== Analysis =="
flutter analyze --no-pub --fatal-infos

echo "== Localization guards =="
python3 tool/check_l10n.py
python3 tool/check_hardcoded_finnish.py

echo "== Test suite =="
flutter test --no-pub

echo "== Validation gates =="
flutter test --no-pub test/validation/

echo "== Performance benchmarks =="
flutter test --no-pub test/performance/phase4_benchmark_test.dart

if [[ "${SKIP_WEB:-0}" != "1" ]]; then
  echo "== Web build =="
  flutter build web --release --base-href /soilscope-public/
fi

echo "Release checks passed."
