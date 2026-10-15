#!/usr/bin/env bash
# Package skills/buongiorno as dist/buongiorno.skill (a zip with buongiorno/ at its root),
# the format the Claude desktop app and claude.ai accept for upload.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist && mkdir -p dist
( cd skills && find buongiorno -type f ! -name '*.pyc' ! -path '*/__pycache__/*' ! -name '.DS_Store' \
    | LC_ALL=C sort | zip -X -q ../dist/buongiorno.skill -@ )
echo "Built dist/buongiorno.skill"
unzip -l dist/buongiorno.skill
