# 10.000+ Tarif Destekli Acemi Dostu Yemek Pişirme Asistanı (AreWeCookin)

## 1. Veri Ölçeği ve Firestore Mimarisi (10.000+ Recipes)
- Koleksiyon: `recipes`
- **Sayfalama (Pagination):** Keşfet ve arama ekranlarında 20'şerli sayfalar halinde `startAfterDocument` ve `limit(20)` kullanılacak.
- **İndeksleme & Arama:**
  - `ingredientKeys`: Normalize edilmiş malzeme dizisi (örn: `["un", "seker", "yumurta"]`).
  - Kiler sorgusunda `arrayContainsAny` ile anahtar malzemeler taranır ve istemci tarafında Riverpod ile uyum yüzdesi hesaplanır.
- **Toplu Veri Yükleyici (Bulk Ingestion):**
  - Projede `scripts/bulk_seeder.dart` bulunacak.
  - Bu script, Firestore `WriteBatch` kullanarak 10.000 adet zengin içerikli tarifi (kategori, adımlar, acemi püf noktaları, araç ikonları ve ikameleriyle birlikte) 500'erli paketler halinde Firestore'a yazabilecek yapıda olacak.

## 2. Şema Yapısı
- `id`: String
- `title`: String
- `category`: String ("Ana Yemek", "Tatlı", "Çorba", "Kahvaltılık", "Pratik", "Hamur İşi", "Salata", "Vegan")
- `prepTime`: int (dk)
- `cookTime`: int (dk)
- `difficulty`: String ("Çok Kolay", "Kolay", "Orta")
- `ingredientKeys`: List<String>
- `ingredients`: List<Map> [{"name": "Un", "amount": "2", "unit": "su bardağı", "isOptional": false}]
- `substitutions`: List<Map> [{"ingredient": "un", "alternative": "Yulaf unu", "tip": "Bağlayıcılık için 1 yumurta fazla kırın."}]
- `steps`: List<Map> [
    {
      "order": 1,
      "title": "Hazırlık",
      "instruction": "Fırını 180 dereceye ayarlayın ve tepsiyi çıkarın.",
      "toolIcon": "microwave",
      "timerSeconds": 0,
      "proTip": "Fırının tam ısınması yaklaşık 10 dakika sürer; malzemeleri hazırlarken önceden açın."
    }
  ]

## 3. Ekranlar
1. **Discover Screen:** 10.000+ tarif arasında sonsuz kaydırma (infinite scroll pagination), kategori filtreleri ve canlı arama.
2. **Pantry (Kiler) Screen:** Malzeme havuzundan çoklu seçim, anlık eşleşme skoru `(Mevcut / Gereken) * 100` ve eksik malzemeler için ikame önerileri.
3. **Recipe Detail Screen:** İnteraktif malzeme listesi, ikame uyarıları ve "Yapmaya Başlayalım" butonu.
4. **Cooking Mode Screen:** Fullscreen PageView, süre sayacı (Timer), adım araçları vektörel ikonları ve acemi odaklı pro-tip kutuları.
