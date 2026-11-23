#!/usr/bin/env python3
"""Validates incoming recipe batches and accepts the good ones.
incoming/<ISO>-<n>.jsonl -> accepted/<ISO>.jsonl (master, ids assigned) + accepted/<ISO>-titles.txt
Bad recipes go to rejected/<batch>.jsonl and reasons to reports/<batch>.txt. Idempotent: a batch file is moved to
accepted/batches/ once fully processed (rejected lines can be fixed and re-submitted under a new name)."""
import json, os, re, sys, glob, shutil, unicodedata
BASE = os.environ.get('TARIF_DIR', '/Users/skurtz/OpenBot/Shared/tarif-programi')
CATS = {'Ana Yemek', 'Tatlı', 'Çorba', 'Kahvaltılık', 'Pratik', 'Hamur İşi', 'Salata', 'Vegan'}
DIFF = {'Çok Kolay', 'Kolay', 'Orta', 'Zor'}
UNITS = {'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup', 'pc', 'clove', 'bunch', 'pinch', 'cm'}
TOOLS = {'bowl', 'pan', 'plate', 'knife', 'pot', 'whisk', 'oven', 'grill', 'blender', 'mortar', 'hammer'}
BAN_PREFIX = ['özel', 'pratik', 'hızlı', 'fırında', 'geleneksel', 'acemi dostu', 'hafif', 'bol baharatlı', 'kremalı',
              'anne eli değmiş', 'usta işi', 'köz kokulu', 'zeytinyağlı', 'fesleğenli', 'tereyağlı']
PLACEHOLDER = re.compile(r'todo|lorem|placeholder|\.\.\.|…{2,}|xxx|\?\?\?|tbd|buraya', re.I)

def load_priority():
    out = {}
    for ln in open(os.path.join(BASE, 'priority.txt'), encoding='utf8'):
        if ln.startswith('#') or '|' not in ln: continue
        tr, iso, en = ln.strip().split('|')
        out[tr] = (iso, en)
    return out

def norm(s):
    s = unicodedata.normalize('NFKD', s.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'\([^)]*\)', ' ', s)
    s = re.sub(r'[^a-z0-9ığüşöç ]', ' ', s)
    return re.sub(r'\s+', ' ', s).strip()

def stem(w, n=5): return w[:n]

def strip_adj(t):
    t = norm(t)
    for p in sorted(BAN_PREFIX, key=len, reverse=True):
        if t.startswith(norm(p) + ' '): return t[len(norm(p)) + 1:]
    return t

def check(r, country_iso):
    e = []
    g = lambda k: r.get(k)
    if g('country') not in PRIORITY or PRIORITY[g('country')][0] != country_iso: e.append('country yanlış/uyumsuz')
    if g('category') not in CATS: e.append('category geçersiz')
    if g('difficulty') not in DIFF: e.append('difficulty geçersiz')
    for k, lo, hi in (('prep', 0, 240), ('cook', 0, 480), ('servings', 1, 40)):
        if not isinstance(g(k), int) or not (lo <= g(k) <= hi): e.append(f'{k} geçersiz')
    if isinstance(g('prep'), int) and isinstance(g('cook'), int) and g('prep') + g('cook') < 5: e.append('toplam süre çok kısa')
    for k in ('title_tr', 'title_en'):
        if not isinstance(g(k), str) or not (3 <= len(g(k).strip()) <= 90): e.append(f'{k} geçersiz')
    if g('title_tr') and g('title_tr') == g('title_en') and not re.search(r'[()]', g('title_tr')): pass
    ings = g('ingredients') or []
    if not (3 <= len(ings) <= 22): e.append('malzeme sayısı 3–22 değil')
    for i in ings:
        if not all(isinstance(i.get(k), str) and i.get(k).strip() for k in ('tr', 'en', 'amount', 'unit')): e.append('malzeme alanı eksik'); break
        if i['unit'] not in UNITS: e.append('birim geçersiz: ' + i['unit']); break
        try:
            if float(i['amount'].replace(',', '.')) <= 0: raise ValueError
        except ValueError: e.append('amount sayı değil: ' + i['amount']); break
    steps = g('steps') or []
    if not (4 <= len(steps) <= 12): e.append('adım sayısı 4–12 değil (şartname: tarif eksiksiz anlatılmalı)')
    text_tr = ''
    for s in steps:
        if s.get('tool') not in TOOLS: e.append('tool geçersiz: ' + str(s.get('tool'))); break
        if not isinstance(s.get('sec'), int) or not (0 <= s['sec'] <= 21600): e.append('sec geçersiz'); break
        for k in ('title_tr', 'text_tr', 'title_en', 'text_en'):
            if not isinstance(s.get(k), str) or len(s[k].strip()) < 3: e.append(f'adım {k} eksik'); break
        else:
            if len(s['text_tr']) < 25 or len(s['text_en']) < 25: e.append('adım metni çok kısa'); break
            text_tr += ' ' + s['text_tr'].lower(); continue
        break
    blob = json.dumps(r, ensure_ascii=False)
    if PLACEHOLDER.search(blob): e.append('yer tutucu/üç nokta metni')
    # nonsense guard: most ingredients must actually appear in the steps
    if ings and text_tr:
        hit = 0
        for i in ings:
            w = norm(i['tr']).split()
            if any(stem(x, 4) in norm(text_tr) for x in w if len(x) >= 4): hit += 1
        if hit < max(2, int(len(ings) * 0.5)): e.append(f'malzemeler adımlarda geçmiyor ({hit}/{len(ings)})')
    if steps and len({s.get('text_tr') for s in steps}) < len(steps): e.append('tekrarlanan adım metni')
    if g('wiki') is not None and not isinstance(g('wiki'), str): e.append('wiki geçersiz')
    return e

def existing_titles(iso, tr):
    t = set()
    p = os.path.join(BASE, 'accepted', f'{iso}.jsonl')
    if os.path.exists(p):
        for ln in open(p, encoding='utf8'):
            t.add(strip_adj(json.loads(ln)['title_tr']))
    # hand-written recipes already in the app
    try:
        sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'world_recipes'))
        from r1 import R
        import r2, r3, r4, r5, r6, r7, r8
        for x in R:
            if x['c'] == tr: t.add(strip_adj(x['tr']))
    except Exception: pass
    return t

def main():
    global PRIORITY
    PRIORITY = load_priority()
    for d in ('accepted/batches', 'rejected', 'reports'): os.makedirs(os.path.join(BASE, d), exist_ok=True)
    summary = []
    for f in sorted(glob.glob(os.path.join(BASE, 'incoming', '*.jsonl'))):
        batch = os.path.basename(f)[:-6]
        iso = batch.split('-')[0]
        tr = next((k for k, v in PRIORITY.items() if v[0] == iso), None)
        if not tr: summary.append(f'{batch}: bilinmeyen ISO'); continue
        seen = existing_titles(iso, tr)
        acc, rej = [], []
        master = os.path.join(BASE, 'accepted', f'{iso}.jsonl')
        n = sum(1 for _ in open(master, encoding='utf8')) if os.path.exists(master) else 0
        # Revision batches (IN-001r1): a recipe whose title already exists REPLACES it (same id), improving it in place.
        is_rev = bool(re.match(r'^[A-Z]{2}-\d+r\d+$', batch))
        rows_master = [json.loads(l) for l in open(master, encoding='utf8') if l.strip()] if os.path.exists(master) else []
        by_title = {norm(r['title_tr']): i for i, r in enumerate(rows_master)}
        replaced = 0
        for ln_no, ln in enumerate(open(f, encoding='utf8'), 1):
            if not ln.strip(): continue
            try: r = json.loads(ln)
            except Exception as ex: rej.append((ln_no, ['JSON bozuk'], ln)); continue
            errs = check(r, iso)
            key = strip_adj(r.get('title_tr', ''))
            if is_rev and norm(r.get('title_tr', '')) in by_title:
                if not errs:
                    i = by_title[norm(r['title_tr'])]
                    r['id'] = rows_master[i]['id']; rows_master[i] = r; replaced += 1
                    continue
            elif key in seen: errs.append('tekrar/sıfatla çoğaltılmış başlık: ' + r.get('title_tr', ''))
            if errs: rej.append((ln_no, errs, ln)); continue
            seen.add(key); n += 1
            r['id'] = f'p_{iso}_{n:05d}'
            acc.append(r)
        if replaced:
            with open(master, 'w', encoding='utf8') as m:
                for r in rows_master: m.write(json.dumps(r, ensure_ascii=False) + '\n')
        with open(master, 'a', encoding='utf8') as m:
            for r in acc: m.write(json.dumps(r, ensure_ascii=False) + '\n')
        titles = os.path.join(BASE, 'accepted', f'{iso}-titles.txt')
        with open(titles, 'a', encoding='utf8') as t:
            for r in acc: t.write(r['title_en'] + ' | ' + r['title_tr'] + '\n')
        rp = os.path.join(BASE, 'reports', f'{batch}.txt')
        if rej:
            with open(os.path.join(BASE, 'rejected', f'{batch}.jsonl'), 'w', encoding='utf8') as rj:
                for _, _, ln in rej: rj.write(ln if ln.endswith('\n') else ln + '\n')
            open(rp, 'w', encoding='utf8').write(f'{batch}: kabul {len(acc)}, yenilenen {replaced}, ret {len(rej)}\n' + '\n'.join(f'satır {a}: ' + '; '.join(b) for a, b, _ in rej) + '\n')
        else:
            open(rp, 'w', encoding='utf8').write(f'{batch}: kabul {len(acc)}, yenilenen {replaced}, ret 0\n')
        shutil.move(f, os.path.join(BASE, 'accepted', 'batches', os.path.basename(f)))
        summary.append(f'{batch}: kabul {len(acc)}, yenilenen {replaced}, ret {len(rej)} (ülke toplam {n})')
    print('\n'.join(summary) if summary else 'incoming boş')

if __name__ == '__main__': main()
