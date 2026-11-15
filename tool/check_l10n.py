#!/usr/bin/env python3
"""Validate ARB key/placeholder parity and gate newly added unused keys."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EN_PATH = Path("lib/l10n/app_en.arb")
FI_PATH = Path("lib/l10n/app_fi.arb")
PLACEHOLDER = re.compile(r"\{([A-Za-z_][A-Za-z0-9_]*)")


def load_arb(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"Could not read {path}: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return value


def messages(doc: dict) -> dict[str, str]:
    return {key: value for key, value in doc.items() if not key.startswith("@")}


def placeholders(value: str) -> set[str]:
    return set(PLACEHOLDER.findall(value))


def metadata_placeholders(doc: dict, key: str) -> dict[str, object]:
    metadata = doc.get(f"@{key}", {})
    if not isinstance(metadata, dict):
        return {}
    declared = metadata.get("placeholders", {})
    if not isinstance(declared, dict):
        return {}
    return {
        name: spec.get("type") if isinstance(spec, dict) else None
        for name, spec in declared.items()
    }


def used_identifiers() -> set[str]:
    identifiers: set[str] = set()
    for path in (ROOT / "lib").rglob("*.dart"):
        if "app_localizations" in path.name:
            continue
        text = path.read_text(encoding="utf-8")
        identifiers.update(re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", text))
    return identifiers


def read_base_messages(base: str) -> dict[str, str]:
    result = subprocess.run(
        ["git", "show", f"{base}:{EN_PATH.as_posix()}"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise ValueError(
            f"Could not read {EN_PATH} at base {base}: {result.stderr.strip()}"
        )
    try:
        return messages(json.loads(result.stdout))
    except json.JSONDecodeError as error:
        raise ValueError(f"Base ARB is not valid JSON: {error}") from error


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base",
        help="Git revision to compare against; only newly added unused keys fail.",
    )
    parser.add_argument(
        "--list-unused",
        action="store_true",
        help="Print every currently unused key.",
    )
    args = parser.parse_args()

    try:
        en = load_arb(ROOT / EN_PATH)
        fi = load_arb(ROOT / FI_PATH)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1

    en_messages = messages(en)
    fi_messages = messages(fi)
    errors: list[str] = []

    missing_fi = sorted(set(en_messages) - set(fi_messages))
    missing_en = sorted(set(fi_messages) - set(en_messages))
    if missing_fi:
        errors.append(f"keys missing from {FI_PATH}: {', '.join(missing_fi[:20])}")
    if missing_en:
        errors.append(f"keys missing from {EN_PATH}: {', '.join(missing_en[:20])}")

    for key in sorted(set(en_messages) & set(fi_messages)):
        en_placeholders = placeholders(en_messages[key])
        fi_placeholders = placeholders(fi_messages[key])
        if en_placeholders != fi_placeholders:
            errors.append(
                f"{key}: placeholders differ "
                f"(en={sorted(en_placeholders)}, fi={sorted(fi_placeholders)})"
            )

        en_meta = metadata_placeholders(en, key)
        fi_meta = metadata_placeholders(fi, key)
        if set(en_meta) != en_placeholders:
            errors.append(
                f"{key}: en metadata placeholders {sorted(en_meta)} "
                f"do not match strings {sorted(en_placeholders)}"
            )
        if set(fi_meta) != fi_placeholders:
            errors.append(
                f"{key}: fi metadata placeholders {sorted(fi_meta)} "
                f"do not match strings {sorted(fi_placeholders)}"
            )
        if en_meta != fi_meta:
            errors.append(f"{key}: placeholder metadata differs between locales")

    en_metadata_keys = {
        key[1:] for key in en if key.startswith("@") and key != "@@locale"
    }
    fi_metadata_keys = {
        key[1:] for key in fi if key.startswith("@") and key != "@@locale"
    }
    if en_metadata_keys != fi_metadata_keys:
        errors.append("ARB metadata keys differ between locales")

    used = used_identifiers()
    unused = sorted(set(en_messages) - used)

    if args.list_unused:
        for key in unused:
            print(f"unused: {key}")

    if args.base:
        try:
            base_messages = read_base_messages(args.base)
        except ValueError as error:
            print(error, file=sys.stderr)
            return 1
        new_keys = sorted(set(en_messages) - set(base_messages))
        new_unused = sorted(set(new_keys) & set(unused))
        print(
            f"Localization: {len(en_messages)} keys; "
            f"{len(new_keys)} new; {len(unused)} currently unused."
        )
        if new_unused:
            errors.append(
                "new localization keys are not referenced by lib/: "
                + ", ".join(new_unused)
            )
    else:
        print(
            f"Localization: {len(en_messages)} keys; "
            f"{len(unused)} currently unused (report only)."
        )

    if errors:
        print("Localization checks failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print("ARB keys and placeholders are in lockstep.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
