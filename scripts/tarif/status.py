#!/usr/bin/env python3
"""Prints per-country progress, writes status.md, and (with --next) the next batch request: 'ISO N country'."""
import os, sys, json, glob
BASE = os.environ.get('TARIF_DIR', '/Users/skurtz/OpenBot/Shared/tarif-programi')
TARGET = 1000
def prio():
    out = []
    for ln in open(os.path.join(BASE, 'priority.txt'), encoding='utf8'):
        if ln.startswith('#') or '|' not in ln: continue
        tr, iso, en = ln.strip().split('|'); out.append((tr, iso, en))
    return out
def count(iso):
    p = os.path.join(BASE, 'accepted', f'{iso}.jsonl')
    return sum(1 for l in open(p, encoding='utf8') if l.strip()) if os.path.exists(p) else 0
def saturated():
    p = os.path.join(BASE, 'saturated.txt')
    return {l.split()[0] for l in open(p) if l.strip() and not l.startswith('#')} if os.path.exists(p) else set()
def batches(iso):
    nums = []
    for f in glob.glob(os.path.join(BASE, 'accepted', 'batches', f'{iso}-*.jsonl')) + glob.glob(os.path.join(BASE, 'incoming', f'{iso}-*.jsonl')):
        b = os.path.basename(f)[len(iso) + 1:-6]
        d = ''.join(ch for ch in b if ch.isdigit())
        if d: nums.append(int(d))
    return max(nums) if nums else 0
def main():
    sat = saturated(); rows = []; total = 0
    for tr, iso, en in prio():
        n = count(iso); total += n
        rows.append((tr, iso, en, n))
    lines = ['# Tarif programı durumu', '', f'Toplam kabul edilmiş gerçek tarif: **{total}** (hedef: ülke başına {TARGET})', '', '| # | Ülke | ISO | Kabul | Hedef % | Not |', '|---|---|---|---|---|---|']
    for i, (tr, iso, en, n) in enumerate(rows, 1):
        lines.append(f'| {i} | {tr} | {iso} | {n} | {min(100, n * 100 // TARGET)}% | {"doygunluk" if iso in sat else ""} |')
    open(os.path.join(BASE, 'status.md'), 'w', encoding='utf8').write('\n'.join(lines) + '\n')
    if '--next' in sys.argv:
        for tr, iso, en, n in rows:
            if n < TARGET and iso not in sat:
                print(f'{iso} {batches(iso) + 1} {tr} {n}'); return
        print('DONE')
    else:
        print('\n'.join(lines[:3]))
        print(', '.join(f'{tr} {n}' for tr, iso, en, n in rows if n))
main()
