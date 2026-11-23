#!/bin/zsh
# Uploads build/packs to R2 (arewecookin-photos/packs/...). Only files whose hash changed are sent.
cd "$(dirname "$0")/../.." || exit 1
STATE=/Users/skurtz/OpenBot/Shared/tarif-programi/uploaded.sha
touch $STATE
n=0
for f in build/packs/*/*.json build/packs/manifest.json; do
  [ -f "$f" ] || continue
  key="packs/${f#build/packs/}"
  h=$(shasum -a 1 "$f" | cut -c1-40)
  grep -q "^$h $key\$" $STATE && continue
  (cd cloudflare/photos && wrangler r2 object put "arewecookin-photos/$key" --file "../../$f" --content-type "application/json" --remote >/dev/null 2>&1) || { echo "UPLOAD FAIL $key"; exit 2; }
  grep -v " $key\$" $STATE > $STATE.tmp; mv $STATE.tmp $STATE; echo "$h $key" >> $STATE; n=$((n+1))
done
echo "uploaded $n files"
