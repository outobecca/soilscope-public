#!/usr/bin/env python3
"""Check the coverage baseline for the hand-written domain and service layers."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

GENERATED = re.compile(r"\.(?:g|freezed|gr)\.dart$")


def parse_lcov(path: Path) -> dict[str, tuple[int, int]]:
    records: dict[str, tuple[int, int]] = {}
    current: str | None = None
    hit = 0
    total = 0

    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            current = line[3:].replace("\\", "/")
            if not current.startswith("lib/"):
                marker = current.find("lib/")
                if marker != -1:
                    current = current[marker:]
            hit = 0
            total = 0
        elif line.startswith("LH:"):
            hit = int(line[3:])
        elif line.startswith("LF:"):
            total = int(line[3:])
        elif line == "end_of_record" and current is not None:
            records[current] = (hit, total)
            current = None

    return records


def summarize(
    records: dict[str, tuple[int, int]], prefix: str
) -> tuple[int, int, int]:
    hit = 0
    total = 0
    files = 0
    for path, (file_hit, file_total) in records.items():
        if not path.startswith(prefix) or GENERATED.search(path):
            continue
        hit += file_hit
        total += file_total
        files += 1
    return hit, total, files


def percent(hit: int, total: int) -> float:
    return hit / total * 100.0 if total else 0.0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--lcov", default="coverage/lcov.info")
    parser.add_argument("--min-domain", type=float, default=67.0)
    parser.add_argument("--min-services", type=float, default=70.0)
    args = parser.parse_args()

    path = Path(args.lcov)
    if not path.is_file():
        print(f"Coverage file not found: {path}", file=sys.stderr)
        return 1

    records = parse_lcov(path)
    if not records:
        print(f"No coverage records found in {path}", file=sys.stderr)
        return 1

    domain_hit, domain_total, domain_files = summarize(records, "lib/domain/")
    services_hit, services_total, services_files = summarize(
        records, "lib/domain/services/"
    )
    all_hit, all_total, _ = summarize(records, "lib/")

    domain = percent(domain_hit, domain_total)
    services = percent(services_hit, services_total)
    overall = percent(all_hit, all_total)

    print(
        f"Domain coverage: {domain:.2f}% "
        f"({domain_hit}/{domain_total} lines, {domain_files} files)"
    )
    print(
        f"Service coverage: {services:.2f}% "
        f"({services_hit}/{services_total} lines, {services_files} files)"
    )
    print(f"All lib coverage (report only): {overall:.2f}% ({all_hit}/{all_total})")

    failures = []
    if domain < args.min_domain:
        failures.append(
            f"domain {domain:.2f}% is below the {args.min_domain:.2f}% baseline"
        )
    if services < args.min_services:
        failures.append(
            f"services {services:.2f}% is below the {args.min_services:.2f}% baseline"
        )

    if failures:
        for failure in failures:
            print(f"Coverage gate failed: {failure}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
