#!/bin/zsh
# One full cycle: validate incoming batches -> build packs -> upload -> status. Safe to run any time, idempotent.
cd "$(dirname "$0")/../.." || exit 1
export PATH=/opt/homebrew/bin:$PATH:$HOME/.local/bin
python3 scripts/tarif/ingest.py || exit 1
if grep -q . /dev/null; then :; fi
python3 scripts/tarif/build_packs.py || exit 1
zsh scripts/tarif/upload_packs.sh || exit 1
python3 scripts/tarif/status.py
