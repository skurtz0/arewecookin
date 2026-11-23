#!/usr/bin/env python3
"""Decides whether a new batch must be requested from the content agent. Prints JSON {"send":bool,"text":str,"why":str}.
State: pending.json {iso,batch,country,sentAt}. A request is considered done when its batch file was accepted
(accepted/batches/<ISO>-<NNN>*.jsonl exists) or it is older than 6 hours (agent lost it -> ask again)."""
import os, json, time, glob, subprocess, sys
BASE = os.environ.get('TARIF_DIR', '/Users/skurtz/OpenBot/Shared/tarif-programi')
HERE = os.path.dirname(os.path.abspath(__file__))
PEND = os.path.join(BASE, 'pending.json')
BATCH = 25
def out(send, text='', why=''):
    print(json.dumps(dict(send=send, text=text, why=why), ensure_ascii=False)); sys.exit(0)
nxt = subprocess.run([sys.executable, os.path.join(HERE, 'status.py'), '--next'], capture_output=True, text=True).stdout.strip()
if nxt == 'DONE': out(False, why='tüm ülkeler hedefte veya doygun')
iso, n, country, have = nxt.split(' ', 3)[0], int(nxt.split(' ')[1]), None, None
parts = nxt.split(' ')
iso, n = parts[0], int(parts[1]); have = parts[-1]; country = ' '.join(parts[2:-1])
pend = json.load(open(PEND)) if os.path.exists(PEND) else None
if pend:
    done = glob.glob(os.path.join(BASE, 'accepted', 'batches', f"{pend['iso']}-{pend['batch']:03d}*.jsonl"))
    waiting_incoming = glob.glob(os.path.join(BASE, 'incoming', f"{pend['iso']}-{pend['batch']:03d}*.jsonl"))
    age = time.time() - pend['sentAt']
    if not done and (waiting_incoming or age < 6 * 3600):
        out(False, why=f"bekleniyor: {pend['iso']}-{pend['batch']:03d} ({int(age/60)} dk)")
# rejected lines of the last processed batch that the agent should fix?
fix = ''
for rj in sorted(glob.glob(os.path.join(BASE, 'rejected', f'{iso}-*.jsonl')), key=os.path.getmtime)[-1:]:
    name = os.path.basename(rj)[:-6]
    if not glob.glob(os.path.join(BASE, 'accepted', 'batches', name + 'r*.jsonl')) and not glob.glob(os.path.join(BASE, 'incoming', name + 'r*.jsonl')) and not os.path.exists(os.path.join(BASE, 'rejected', name + '.handled')):
        fix = f"\nÖnce düzelt: reddedilen satırlar /Users/skurtz/OpenBot/Shared/tarif-programi/rejected/{name}.jsonl (sebepler reports/{name}.txt). Düzeltilmişlerini {name}r1.jsonl adıyla incoming/'e yaz. Sonra yeni parti."
        open(os.path.join(BASE, 'rejected', name + '.handled'), 'w').write('asked')
bn = f'{n:03d}'
text = (f"Tarif programı (arewecookin) parti isteği. Önce /Users/skurtz/OpenBot/Shared/tarif-programi/SPEC.md oku (biçim ve kurallar).{fix}\n"
        f"YENİ PARTİ: {iso}-{bn}, ülke: {country}, {BATCH} tarif. Bu ülkede şu ana kadar kabul edilen tarif sayısı: {have} (hedef 1000). "
        f"Daha önce yazılanları /Users/skurtz/OpenBot/Shared/tarif-programi/accepted/{iso}-titles.txt dosyasından oku ve TEKRAR etme (sıfatla çoğaltma yasak). "
        f"Gerçekten var olan, farklı yemekler yaz; mevcut kategori çeşitliliğini koru (Ana Yemek, Çorba, Tatlı, Hamur İşi, Salata, Kahvaltılık, Pratik, Vegan). "
        f"Dosya: /Users/skurtz/OpenBot/Shared/tarif-programi/incoming/{iso}-{bn}.jsonl . Bitince bana kısa mesaj: \"{iso}-{bn} hazır, N tarif\". "
        f"Bu ülkede gerçekten farklı tarif tükendiyse sayı uydurma: \"{iso} doygunluk, toplam N\" yaz.")
json.dump(dict(iso=iso, batch=n, country=country, sentAt=time.time()), open(PEND, 'w'))
out(True, text, f'{iso}-{bn} isteniyor')
