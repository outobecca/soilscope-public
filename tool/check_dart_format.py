#!/usr/bin/env python3
"""Check formatting for new and already-formatted Dart files.

The repository has pre-existing formatting drift. Formatting every file would
create a large unrelated diff, so this check is a ratchet:

* a new file must be formatted;
* a changed file that was already formatted at the comparison base must stay
  formatted;
* changing a file that was unformatted at the base does not fail the gate.

Generated files are excluded because their formatter is the generator, not
`dart format`.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path

GENERATED_SUFFIXES = (".freezed.dart", ".g.dart", ".gr.dart")
GENERATED_NAMES = {
    "app_localizations.dart",
    "app_localizations_en.dart",
    "app_localizations_fi.dart",
}


def is_generated(path: str) -> bool:
    return path.endswith(GENERATED_SUFFIXES) or Path(path).name in GENERATED_NAMES


def is_formatted(source: bytes) -> bool:
    # Keep the probe inside the package so `dart format` uses the same
    # language version as the real source files.
    with tempfile.NamedTemporaryFile(
        dir=Path.cwd(),
        prefix=".format_check_",
        suffix=".dart",
        delete=False,
    ) as handle:
        handle.write(source)
        temp_path = handle.name
    try:
        result = subprocess.run(
            ["dart", "format", "--output=none", "--set-exit-if-changed", temp_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return result.returncode == 0
    finally:
        os.unlink(temp_path)


def git_show(base: str, path: str) -> bytes | None:
    result = subprocess.run(
        ["git", "show", f"{base}:{path}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.stdout if result.returncode == 0 else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=os.environ.get("BASE_SHA", ""))
    parser.add_argument("--head", default="HEAD")
    args = parser.parse_args()

    base = args.base
    if not base or set(base) == {"0"}:
        base = "HEAD^"

    if subprocess.run(
        ["git", "rev-parse", "--verify", base],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode != 0:
        print(f"No comparison base {base!r}; nothing to check.")
        return 0

    diff = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--diff-filter=ACMR",
            base,
            args.head,
            "--",
            "*.dart",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if diff.returncode != 0:
        print(f"Could not compare against {base!r}: {diff.stderr.strip()}")
        return 1

    offenders: list[str] = []
    for path in sorted(diff.stdout.splitlines()):
        path = path.strip()
        if not path or is_generated(path):
            continue
        file_path = Path(path)
        if not file_path.is_file():
            continue

        base_source = git_show(base, path)
        if base_source is not None and not is_formatted(base_source):
            # The file already had formatting debt at the base; do not make
            # this change responsible for cleaning all of it up.
            continue

        if not is_formatted(file_path.read_bytes()):
            offenders.append(path)

    if offenders:
        print("These new or previously formatted Dart files are not formatted:")
        print("\n".join(offenders))
        print("\nRun: dart format " + " ".join(offenders))
        return 1

    print("Dart formatting ratchet passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
