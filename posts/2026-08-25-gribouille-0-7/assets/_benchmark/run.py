#!/usr/bin/env python3
"""Compile time of one chart across Gribouille versions.

Compiles `case.typ` once per version, chart, and row count, three times each,
and writes every run to `results.csv`. The post plots the median of the three.

The latest patch of each minor version is used, and reported under the minor
version alone. 0.7 is read from a local build, because the sweep was run before
the release reached Typst Universe; change it to the published version to
reproduce the figure from packages alone.

Usage:
    python3 run.py
"""

import csv
import json
import pathlib
import statistics
import subprocess
import time

HERE = pathlib.Path(__file__).resolve().parent
TEMPLATE = (HERE / "case.typ").read_text()
TIMEOUT_SECONDS = 400
REPEATS = 3

VERSIONS = [
    ("0.1", '"@preview/gribouille:0.1.1"'),
    ("0.2", '"@preview/gribouille:0.2.1"'),
    ("0.3", '"@preview/gribouille:0.3.0"'),
    ("0.4", '"@preview/gribouille:0.4.1"'),
    ("0.5", '"@preview/gribouille:0.5.0"'),
    ("0.6", '"@preview/gribouille:0.6.0"'),
    ("0.7", '"@local/gribouille:0.0.0"'),
]

CHARTS = {
    "Scatter": (
        'aes(x: "x", y: "y")',
        "geom-point(size: 1pt)",
        [500, 1000, 2000, 4000],
    ),
    "Boxplot": (
        'aes(x: "g", y: "y")',
        "geom-boxplot()",
        [4000, 8000, 16000, 32000, 64000],
    ),
}


def compile_once(source_path: pathlib.Path, image_path: pathlib.Path) -> float | None:
    """Compile one document and return the wall-clock seconds, or None on failure."""
    started = time.time()
    try:
        result = subprocess.run(
            ["typst", "compile", "--format", "png", str(source_path), str(image_path)],
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return None
    if result.returncode != 0:
        return None
    return time.time() - started


def main() -> None:
    source_path = HERE / "_case-run.typ"
    image_path = HERE / "_case-run.png"
    records = []

    for chart, (mapping, layer, sizes) in CHARTS.items():
        for rows in sizes:
            for label, package in VERSIONS:
                source = (
                    TEMPLATE.replace("PACKAGE", package)
                    .replace("NROWS", str(rows))
                    .replace("MAPPING", mapping)
                    .replace("LAYER", layer)
                )
                source_path.write_text(source)
                runs = []
                for _ in range(REPEATS):
                    seconds = compile_once(source_path, image_path)
                    if seconds is None:
                        runs = []
                        break
                    runs.append(seconds)
                median = round(statistics.median(runs), 2) if runs else None
                records.append(
                    {"chart": chart, "rows": rows, "version": label, "runs": runs}
                )
                print(chart, rows, label, median, flush=True)

    source_path.unlink(missing_ok=True)
    image_path.unlink(missing_ok=True)

    with (HERE / "results.csv").open("w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["chart", "rows", "version", "run", "seconds"])
        for record in records:
            for index, seconds in enumerate(record["runs"], start=1):
                writer.writerow(
                    [
                        record["chart"],
                        record["rows"],
                        record["version"],
                        index,
                        f"{seconds:.3f}",
                    ]
                )
    (HERE / "results.json").write_text(json.dumps(records, indent=1))


if __name__ == "__main__":
    main()
