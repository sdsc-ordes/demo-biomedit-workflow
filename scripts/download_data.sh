#!/usr/bin/env sh
# Download source zip and extract it to target dir

set -euo pipefail

URL="https://synthetichealth.github.io/synthea-sample-data/downloads/synthea_sample_data_fhir_stu3_sep2019.zip"
OUT_DIR="data/raw/"
mkdir -p "$OUT_DIR"
curl "$URL" --output tmp.zip && \
    unzip tmp.zip -d "$OUT_DIR"
rm tmp.zip
