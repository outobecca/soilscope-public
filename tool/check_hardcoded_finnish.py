#!/usr/bin/env python3
"""Fail when Finnish copy is hardcoded in presentation code.

The Logic Lab palettes keep Finnish as their source copy with English lookups
(guarded by palette_l10n_test.dart). The tutorial matcher accepts legacy
Finnish step titles. Every other widget must use AppLocalizations instead of a
literal.
"""

from pathlib import Path
import re
import sys

FINNISH = set("äöåÄÖÅ")
ALLOWED_FILES = {
    "function_palette.dart",
    "input_palette.dart",
    "tutorial_overlay_widget.dart",
}


def strip_comments(source: str) -> str:
    def blank_block(match: re.Match[str]) -> str:
        return "\n" * match.group(0).count("\n")

    source = re.sub(r"/\*.*?\*/", blank_block, source, flags=re.S)
    return "\n".join(line.split("//", 1)[0] for line in source.splitlines())


def main() -> int:
    root = Path("lib/presentation")
    offenders = []
    for path in sorted(root.rglob("*.dart")):
        if path.name in ALLOWED_FILES:
            continue
        for number, line in enumerate(
            strip_comments(path.read_text(encoding="utf-8")).splitlines(), 1
        ):
            if FINNISH.intersection(line):
                offenders.append(f"{path}:{number}: {line.strip()}")

    if offenders:
        print("Hardcoded Finnish copy found; move it to the ARB files:")
        print("\n".join(offenders))
        return 1

    print("No hardcoded Finnish copy outside the guarded palettes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
