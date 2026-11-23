#!/usr/bin/env python3
"""accepted/<ISO>.jsonl -> build/packs/{manifest.json,<ISO>/<k>.json} (the app loads these on demand).
Photos: only when the recipe's `wiki` names a real English Wikipedia article whose lead image is a free Wikimedia
Commons file (automatic check, cached in photos.json). Everything else shows the category artwork."""
import json, os, re, sys, glob, time, urllib.request, urllib.parse, unicodedata
BASE = os.environ.get('TARIF_DIR', '/Users/skurtz/OpenBot/Shared/tarif-programi')
OUT = os.environ.get('PACK_OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'build', 'packs'))
PAGE = 100
UN = {'g': ('g', 'g'), 'ml': ('ml', 'ml'), 'kg': ('kg', 'kg'), 'cm': ('cm', 'cm'), 'cup': ('su bardağı', 'cup'), 'tbsp': ('yemek kaşığı', 'tbsp'),
      'tsp': ('çay kaşığı', 'tsp'), 'pc': ('adet', 'pcs'), 'l': ('litre', 'l'), 'clove': ('diş', 'clove'), 'pinch': ('tutam', 'pinch'), 'bunch': ('demet', 'bunch')}
UA = 'arewecookin-recipe-photo-check/1.0 (github.com/skurtz0/arewecookin)'
PH = os.path.join(BASE, 'photos.json')

def ascii_key(s):
    s = unicodedata.normalize('NFKD', s.lower().replace('ı', 'i'))
    s = ''.join(c for c in s if not unicodedata.combining(c))
    w = re.sub(r'\([^)]*\)', ' ', s)
    w = re.sub(r'[^a-z0-9 ]', ' ', w).split()
    return w[0] if w else 'x'

def wiki_image(title, cache):
    if title in cache: return cache[title]
    url = 'https://en.wikipedia.org/w/api.php?' + urllib.parse.urlencode(dict(action='query', titles=title, redirects=1, prop='pageimages|pageprops', piprop='thumbnail', pithumbsize=500, format='json'))
    try:
        d = json.load(urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': UA}), timeout=30))
    except Exception as e:
        return None  # not cached: try again next run
    time.sleep(0.4)
    res = None
    for p in d.get('query', {}).get('pages', {}).values():
        th = (p.get('thumbnail') or {}).get('source', '')
        if 'missing' in p or 'disambiguation' in (p.get('pageprops') or {}) or '/wikipedia/commons/' not in th: continue
        res = th
    cache[title] = res
    return res

def img_ok(url, wiki, title_en):
    """Conservative: a photo file (jpg) whose file name names the dish. Diagrams, ingredient pictures and
    generic images ('3_types_of_lentil.png' for 'Dal') are dropped; those recipes show the category artwork."""
    if not url: return None
    name = urllib.parse.unquote(url.split('/')[-1]).lower()
    if not re.search(r'\.jpe?g(\?|$)', name.split('px-', 1)[-1]): return None
    toks = {t for t in re.findall(r'[a-z]{4,}', unicodedata.normalize('NFKD', (wiki or '') + ' ' + (title_en or '')).encode('ascii', 'ignore').decode().lower())}
    toks -= {'with', 'from', 'style', 'recipe', 'fried', 'baked', 'roasted', 'soup', 'salad', 'sauce', 'cake', 'bread', 'rice', 'chicken'}
    return url if any(t in name for t in toks) else None

def main():
    cache = json.load(open(PH)) if os.path.exists(PH) else {}
    os.makedirs(OUT, exist_ok=True)
    manifest = {'v': int(time.time()), 'pageSize': PAGE, 'countries': {}}
    for f in sorted(glob.glob(os.path.join(BASE, 'accepted', '??.jsonl'))):
        iso = os.path.basename(f)[:2]
        rows = [json.loads(l) for l in open(f, encoding='utf8') if l.strip()]
        if not rows: continue
        recs = []
        for r in rows:
            img = img_ok(wiki_image(r['wiki'], cache) if r.get('wiki') else None, r.get('wiki'), r['title_en'])
            ing = [dict(k=ascii_key(i['tr']), n=i['tr'], ne=i['en'], a=i['amount'], u=UN[i['unit']][0], ue=UN[i['unit']][1]) for i in r['ingredients']]
            st = [dict(o=k + 1, tool=s['tool'], sec=s['sec'], t=s['title_tr'], i=s['text_tr'], te=s['title_en'], ie=s['text_en'], p=s.get('tip_tr', ''), pe=s.get('tip_en', '')) for k, s in enumerate(r['steps'])]
            recs.append(dict(id=r['id'], c=r['country'], cat=r['category'], d=r['difficulty'], p=r['prep'], k=r['cook'], sv=r['servings'], tr=r['title_tr'], en=r['title_en'], img=img, ing=ing, st=st))
        d = os.path.join(OUT, iso); os.makedirs(d, exist_ok=True)
        for old in glob.glob(os.path.join(d, '*.json')): os.remove(old)
        pages = [recs[i:i + PAGE] for i in range(0, len(recs), PAGE)]
        for k, pg in enumerate(pages):
            json.dump(pg, open(os.path.join(d, f'{k}.json'), 'w', encoding='utf8'), ensure_ascii=False, separators=(',', ':'))
        manifest['countries'][rows[0]['country']] = dict(iso=iso, count=len(recs), pages=len(pages), photos=sum(1 for r in recs if r['img']))
    json.dump(manifest, open(os.path.join(OUT, 'manifest.json'), 'w', encoding='utf8'), ensure_ascii=False, separators=(',', ':'))
    json.dump(cache, open(PH, 'w'), ensure_ascii=False, indent=0)
    print(json.dumps({k: v['count'] for k, v in manifest['countries'].items()}, ensure_ascii=False))

if __name__ == '__main__': main()
