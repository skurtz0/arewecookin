import '../models/models.dart';

/// Deterministic Recipe Generator for 10,000+ realistic recipes
class RecipeGenerator {
  static const int totalCapacity = 10000;

  static const List<String> categories = [
    'Ana Yemek',
    'Tatlı',
    'Çorba',
    'Kahvaltılık',
    'Pratik',
    'Hamur İşi',
    'Salata',
    'Vegan',
  ];

  static const List<String> difficulties = [
    'Çok Kolay',
    'Kolay',
    'Orta',
  ];

  static const Map<String, List<String>> categoryDishBases = {
    'Ana Yemek': [
      'Güveçte Kuru Fasulye', 'Fırında Tavuk Pirzola', 'Karnıyarık', 'Hünkar Beğendi',
      'Izgara Kasap Köfte', 'Tas Kebabı', 'Fırında Çipura', 'Mantarlı Tavuk Sote',
      'Kıymalı Biber Dolması', 'Orman Kebabı', 'Terbiyeli Köfte', 'İmam Bayıldı',
      'Etli Nohut Yemeği', 'Fırında Sebzeli Somon', 'Ali Nazik Kebabı', 'Kuzu İncik',
      'Klasik Fırın Lazanya', 'Kremalı Mantarlı Risotto', 'Tavuklu Japon Rameni', 'Geleneksel Pad Thai',
      'Tatlı Ekşi Soslu Tavuk', 'Kıymalı Çıtır Taco', 'Tavuklu Fırın Enchilada', 'Meksika Usulü Chili con Carne',
      'Deniz Mahsullü Paella', 'Geleneksel Fırın Ratatouille', 'Bursa İskender Kebabı', 'Bodrum Çökertme Kebabı',
    ],
    'Tatlı': [
      'Fırın Sütlaç', 'Kakaolu Islak Kek', 'Geleneksel Kazandibi', 'Tereyağlı İrmik Helvası',
      'Şekerpare', 'Çilekli Magnolia', 'Cevizli Revani', 'Çikolatalı Supangle',
      'Karamelli Trileçe', 'Havuçlu Tarçınlı Kek', 'Saray Muhallebisi', 'Profiterol',
      'Baklava Dilimli Revani', 'Limonlu Cheesecake', 'Mozaik Pasta', 'Vişneli Ekmek Kadayıfı',
      'Geleneksel Tiramisu', 'Sıcak Çikolatalı Sufle', 'Tarçınlı Meksika Churros', 'Vanilyalı Panna Cotta',
      'Antep Fıstıklı Katmer', 'Meyveli Çıtır Tartalet',
    ],
    'Çorba': [
      'Süzme Kırmızı Mercimek', 'Geleneksel Ezogelin', 'Naneli Yayla Çorbası',
      'Kremalı Dağ Mantarı', 'Terbiyeli Tavuk Çorbası', 'Ev Yapımı Tarhana',
      'Fesleğenli Domates Çorbası', 'Düğün Çorbası', 'Sebzeli Minestrone', 'Kelle Paça Usulü Çorba',
      'Arpa Şehriyeli Çorba', 'Köz Kırmızı Biber Çorbası',
      'Geleneksel Miso Çorbası', 'Fransız Karamelize Soğan Çorbası', 'Tom Yum Usulü Tavuk Çorbası', 'Beyran Usulü Et Çorbası',
    ],
    'Kahvaltılık': [
      'Geleneksel Menemen', 'Kayseri Sucuklu Yumurta', 'Kaşarlı Peynirli Krep',
      'Patatesli Köy Omleti', 'Karadeniz Mıhlaması', 'Fırında Yumurtalı Kaşarlı Ekmek',
      'Peynirli Sigara Böreği', 'Yulaflı Pankek', 'Çılbır (Yoğurtlu Poşe Yumurta)',
      'Simit & Kaşar Tostu', 'Zeytin Ezmeli Bruschetta', 'Avokadolu Poşe Yumurta',
      'Yumurtalı Fried Rice', 'Taze Kruvasan Sandviç', 'Menemen Usulü Shakshuka', 'Peynirli Çıtır Gözleme',
    ],
    'Pratik': [
      'Sarımsaklı Domatesli Makarna', 'Tavuklu Fajita Wrap', 'Ton Balıklı Akdeniz Sandviç',
      'Soya Soslu Sebzeli Noodle', '5 Dakikalık Peynirli Quesadilla', 'Fırında Baharatlı Elma Dilim Patates',
      'Kremalı Tavuklu Penne', 'Mug Cake (Fincanda Kek)', 'Köz Sebzeli Lavaş Dürüm',
      'Fasulye Piyazı Sandviç', 'Kremalı Mantarlı Ekmek Üstü', 'Pratik Tavada Pizza',
      'İtalyan Pizza Margherita', 'Çıtır Ev Yapımı Smash Burger', 'Özel Soslu Islak Burger', 'Çıtır Tavuk Dürüm',
      'Guacamole & Çıtır Nachos', 'Etli Burrito Dürüm', 'Sebzeli Tavuklu Wok', 'Patatesli Gnocchi',
    ],
    'Hamur İşi': [
      'Peynirli Tepsi Böreği', 'Mayasız Puf Poğaça', 'Kıymalı Kol Böreği',
      'Taş Fırın Bazlama', 'Susamlı Çıtır Simit', 'Gözleme (Ispanaklı Peynirli)',
      'Ev Yapımı Fındık Lahmacun', 'Zeytinli Açma', 'Kıymalı Pide', 'Karaköy Poğaçası',
      'Otlu Çörek', 'Kuru Mayalı Peynirli Pide',
      'Gyoza (Japon Mantısı)', 'Çıtır Sebzeli Spring Roll', 'Kayseri Yağ Mantısı', 'Tavuklu & Pırasalı Quiche',
    ],
    'Salata': [
      'Geleneksel Çoban Salatası', 'Cevizli Gavurdağı Salatası', 'Akdeniz Yeşillikleri Salatası',
      'Roka & Parmesan Salatası', 'Antalya Usulü Tahinli Piyaz', 'Kinoa & Avokado Salatası',
      'Hellim Peynirli Yeşil Salata', 'Fırın Pancar & Keçi Peynirli Salata', 'Semizotu & Yoğurt Salatası',
      'Köz Patlıcan Salatası', 'Tavuklu Sezar Salata', 'Tabule (Bulgur Salatası)',
      'Geleneksel Grek Salatası', 'Köz Patlıcanlı Babagannuş', 'Tavuklu Chipotle Bowl', 'İzmir Usulü Kumru Sandviç',
    ],
    'Vegan': [
      'Kıtır Nohutlu Mercimek Bowl', 'Zeytinyağlı Enginar Kalbi', 'Fırında Baharatlı Karnabahar Steak',
      'Tahinli Humus & Fırın Sebzeler', 'Geleneksel Mercimek Köftesi', 'Mantarlı Tofu Sote',
      'Fıstık Soslu Sebze Yahnisi', 'Falafel Tabağı', 'Fırın Tatlı Patates Dolması',
      'Zeytinyağlı Kereviz', 'Közlenmiş Sebze Güveci', 'Buharda Edamame & Pirinç',
      'Sebzeli Sushi Roll', 'Körili Sebzeli Noodle', 'Falafel Dürüm', 'Zeytinyağlı Yaprak Sarma',
    ],
  };

  static const List<String> titleAdjectives = [
    'Özel', 'Pratik', 'Fırında', 'Geleneksel', 'Acemi Dostu', 'Hızlı',
    'Hafif', 'Geleneksel', 'Bol Baharatlı', 'Kremalı', 'Anne Eli Değmiş',
    'Usta İşi', 'Köz Kokulu', 'Zeytinyağlı', 'Fesleğenli', 'Tereyağlı',
  ];

  static const Map<String, List<Ingredient>> ingredientPool = {
    'un': [
      Ingredient(name: 'Un', amount: '2', unit: 'su bardağı'),
      Ingredient(name: 'Un', amount: '1', unit: 'su bardağı'),
      Ingredient(name: 'Un', amount: '3', unit: 'yemek kaşığı'),
    ],
    'seker': [
      Ingredient(name: 'Toz Şeker', amount: '1', unit: 'su bardağı'),
      Ingredient(name: 'Toz Şeker', amount: '2', unit: 'yemek kaşığı'),
      Ingredient(name: 'Esmer Şeker', amount: '0.5', unit: 'su bardağı'),
    ],
    'tuz': [
      Ingredient(name: 'Tuz', amount: '1', unit: 'tatlı kaşığı'),
      Ingredient(name: 'Kaya Tuzu', amount: '1', unit: 'çay kaşığı'),
    ],
    'zeytinyagi': [
      Ingredient(name: 'Zeytinyağı', amount: '3', unit: 'yemek kaşığı'),
      Ingredient(name: 'Sızma Zeytinyağı', amount: '0.5', unit: 'çay bardağı'),
    ],
    'tereyagi': [
      Ingredient(name: 'Tereyağı', amount: '2', unit: 'yemek kaşığı'),
      Ingredient(name: 'Tereyağı', amount: '50', unit: 'gram'),
    ],
    'yumurta': [
      Ingredient(name: 'Yumurta', amount: '2', unit: 'adet'),
      Ingredient(name: 'Yumurta', amount: '3', unit: 'adet'),
      Ingredient(name: 'Yumurta Sarısı', amount: '1', unit: 'adet'),
    ],
    'sut': [
      Ingredient(name: 'Süt', amount: '1', unit: 'su bardağı'),
      Ingredient(name: 'Ilık Süt', amount: '2', unit: 'su bardağı'),
    ],
    'domates': [
      Ingredient(name: 'Domates', amount: '2', unit: 'adet (küp doğranmış)'),
      Ingredient(name: 'Domates Salçası', amount: '1', unit: 'yemek kaşığı'),
      Ingredient(name: 'Rende Domates', amount: '1', unit: 'su bardağı'),
    ],
    'biber': [
      Ingredient(name: 'Yeşil Biber', amount: '2', unit: 'adet'),
      Ingredient(name: 'Kapya Biber', amount: '1', unit: 'adet'),
    ],
    'sogan': [
      Ingredient(name: 'Kuru Soğan', amount: '1', unit: 'orta boy'),
      Ingredient(name: 'Arpacık Soğan', amount: '6', unit: 'adet'),
    ],
    'sarimsak': [
      Ingredient(name: 'Sarımsak', amount: '2', unit: 'diş (ezilmiş)'),
      Ingredient(name: 'Sarımsak', amount: '3', unit: 'diş'),
    ],
    'kiyma': [
      Ingredient(name: 'Dana Kıyma', amount: '300', unit: 'gram'),
      Ingredient(name: 'Kuzu Kıyma', amount: '200', unit: 'gram'),
    ],
    'tavuk': [
      Ingredient(name: 'Tavuk Göğsü', amount: '400', unit: 'gram (kuşbaşı)'),
      Ingredient(name: 'Tavuk But', amount: '2', unit: 'adet'),
    ],
    'peynir': [
      Ingredient(name: 'Rende Kaşar Peyniri', amount: '1', unit: 'su bardağı'),
      Ingredient(name: 'Beyaz Peynir', amount: '150', unit: 'gram'),
      Ingredient(name: 'Lor Peyniri', amount: '100', unit: 'gram'),
    ],
    'patates': [
      Ingredient(name: 'Patates', amount: '3', unit: 'orta boy'),
      Ingredient(name: 'Patates', amount: '2', unit: 'adet (haşlanmış)'),
    ],
    'pirinc': [
      Ingredient(name: 'Baldo Pirinç', amount: '1.5', unit: 'su bardağı'),
      Ingredient(name: 'Kırık Pirinç', amount: '0.5', unit: 'çay bardağı'),
    ],
    'mercimek': [
      Ingredient(name: 'Kırmızı Mercimek', amount: '1', unit: 'su bardağı'),
      Ingredient(name: 'Yeşil Mercimek', amount: '1', unit: 'su bardağı'),
    ],
    'makarna': [
      Ingredient(name: 'Penne Makarna', amount: '250', unit: 'gram'),
      Ingredient(name: 'Spagetti', amount: '200', unit: 'gram'),
    ],
    'yogurt': [
      Ingredient(name: 'Süzme Yoğurt', amount: '3', unit: 'yemek kaşığı'),
      Ingredient(name: 'Ev Yoğurdu', amount: '1', unit: 'su bardağı'),
    ],
    'baharat': [
      Ingredient(name: 'Karabiber', amount: '1', unit: 'çay kaşığı'),
      Ingredient(name: 'Pul Biber', amount: '1', unit: 'tatlı kaşığı'),
      Ingredient(name: 'Kuru Nane', amount: '1', unit: 'tatlı kaşığı'),
      Ingredient(name: 'Kekik', amount: '1', unit: 'çay kaşığı'),
      Ingredient(name: 'Kimyon', amount: '0.5', unit: 'çay kaşığı'),
    ],
    'patlican': [
      Ingredient(name: 'Kemer Patlıcan', amount: '2', unit: 'adet'),
      Ingredient(name: 'Bostan Patlıcanı', amount: '1', unit: 'adet'),
    ],
    'balik': [
      Ingredient(name: 'Çipura / Somon Fileto', amount: '2', unit: 'adet'),
      Ingredient(name: 'Levrek Fileto', amount: '2', unit: 'adet'),
    ],
    'et': [
      Ingredient(name: 'Dana Kuşbaşı', amount: '350', unit: 'gram'),
      Ingredient(name: 'Kuzu Eti', amount: '300', unit: 'gram'),
    ],
    'fasulye': [
      Ingredient(name: 'Kuru Fasulye (Haşlanmış)', amount: '2', unit: 'su bardağı'),
      Ingredient(name: 'İspir Kuru Fasulye', amount: '1.5', unit: 'su bardağı'),
    ],
    'nohut': [
      Ingredient(name: 'Haşlanmış Nohut', amount: '2', unit: 'su bardağı'),
      Ingredient(name: 'Koçbaşı Nohut', amount: '1.5', unit: 'su bardağı'),
    ],
    'mantar': [
      Ingredient(name: 'Kültür Mantarı', amount: '250', unit: 'gram'),
      Ingredient(name: 'Kestane Mantarı', amount: '200', unit: 'gram'),
    ],
    'havuc': [
      Ingredient(name: 'Havuç', amount: '2', unit: 'adet'),
    ],
    'limon': [
      Ingredient(name: 'Taze Limon Suyu', amount: '1', unit: 'adet'),
    ],
    'avokado': [
      Ingredient(name: 'Olgun Avokado', amount: '1', unit: 'adet'),
    ],
    'yesillik': [
      Ingredient(name: 'Maydanoz & Dereotu', amount: '0.5', unit: 'demet'),
      Ingredient(name: 'Taze Roka', amount: '1', unit: 'demet'),
    ],
    'kakao': [
      Ingredient(name: 'Kakao', amount: '3', unit: 'yemek kaşığı'),
      Ingredient(name: 'Bitter Çikolata', amount: '80', unit: 'gram'),
    ],
    'ceviz': [
      Ingredient(name: 'Dövülmüş Ceviz İçi', amount: '1', unit: 'çay bardağı'),
    ],
    'sucuk': [
      Ingredient(name: 'Kangal Sucuk', amount: '100', unit: 'gram'),
    ],
    'noodle': [
      Ingredient(name: 'Yumurta Noodle', amount: '200', unit: 'gram'),
    ],
    'tofu': [
      Ingredient(name: 'Soya Tofusu', amount: '200', unit: 'gram'),
    ],
    'lavas': [
      Ingredient(name: 'Lavaş / Tortilla', amount: '2', unit: 'adet'),
    ],
    'bulgur': [
      Ingredient(name: 'Pilavlık / Köftelik Bulgur', amount: '1.5', unit: 'su bardağı'),
    ],
    'irmik': [
      Ingredient(name: 'İrmik', amount: '1', unit: 'su bardağı'),
    ],
    'yufka': [
      Ingredient(name: 'Taze Yufka', amount: '3', unit: 'adet'),
    ],
    'ton baligi': [
      Ingredient(name: 'Konserve Ton Balığı', amount: '1', unit: 'kutu (160g)'),
    ],
  };

  static const List<Substitution> commonSubstitutions = [
    Substitution(
      ingredient: 'un',
      alternative: 'Yulaf unu veya Badem unu',
      tip: 'Glutensiz alternatif için kullanırken bağlayıcılığı artırmak adına 1 yumurta ekleyin.',
    ),
    Substitution(
      ingredient: 'tereyagi',
      alternative: 'Zeytinyağı veya Hindistan cevizi yağı',
      tip: 'Zeytinyağı kullanırken miktarı %15 daha az tutun, lezzet daha hafif olacaktır.',
    ),
    Substitution(
      ingredient: 'sut',
      alternative: 'Badem sütü veya Soya sütü',
      tip: 'Bitkisel sütler benzer kıvam verir, şekersiz olanları tercih edin.',
    ),
    Substitution(
      ingredient: 'seker',
      alternative: 'Bal veya Pekmez',
      tip: 'Fırın ısısını 10 derece düşürün çünkü bal ve pekmez daha hızlı karamelize olup kararabilir.',
    ),
    Substitution(
      ingredient: 'kiyma',
      alternative: 'İnce kıyılmış Mantar veya Yeşil Mercimek',
      tip: 'Mantarları suyunu çekene kadar yüksek ateşte mühürleyerek kıyma dokusu yakalayabilirsiniz.',
    ),
    Substitution(
      ingredient: 'tavuk',
      alternative: 'İstiridye Mantarı veya Tofu',
      tip: 'Yüksek ateşte tavada mühürleyerek tavuksu bir doku elde edebilirsiniz.',
    ),
    Substitution(
      ingredient: 'et',
      alternative: 'Mantar veya Haşlanmış Nohut',
      tip: 'Güveç ve sulu yemeklerde doyurucu bir et alternatifi sunar.',
    ),
    Substitution(
      ingredient: 'balik',
      alternative: 'Tavuk göğsü veya Marine edilmiş Tofu',
      tip: 'Zeytinyağı ve limon sosuyla aynı Akdeniz tazeliğini sağlar.',
    ),
    Substitution(
      ingredient: 'patlican',
      alternative: 'Kabak veya Közlenmiş Biber',
      tip: 'Fırında veya tavada benzer yumuşaklık ve kıvam sağlar.',
    ),
    Substitution(
      ingredient: 'fasulye',
      alternative: 'Nohut veya Barbunya',
      tip: 'Aynı pişirme süresinde güveç lezzetini korur.',
    ),
    Substitution(
      ingredient: 'yogurt',
      alternative: 'Süt + birkaç damla limon suyu',
      tip: 'Kestirilmiş süt yoğurt asiditesini ve yumuşaklığını taklit eder.',
    ),
    Substitution(
      ingredient: 'peynir',
      alternative: 'Besin mayası veya Tofu',
      tip: 'Vegan peynir aroması için besin mayasını baharatlarla harmanlayın.',
    ),
    Substitution(
      ingredient: 'yumurta',
      alternative: '1 yemek kaşığı Chia tohumu + 3 yemek kaşığı su',
      tip: 'Jelleşene kadar 5 dakika bekletin; hamur bağlayıcılığında harika çalışır.',
    ),
  ];

  static const List<Map<String, dynamic>> stepTemplates = [
    {
      'title': 'Ön Hazırlık ve Doğrama',
      'instruction': 'Tüm sebzeleri yıkayıp eşit boyutlarda doğrayın. Malzemeleri pişirme öncesinde elinizin altında hazır bulundurun (Mise en place).',
      'toolIcon': 'knife',
      'timerSeconds': 300,
      'proTip': 'Bıçağı kullanırken parmaklarınızı içeri doğru pençe şeklinde kıvırın, bu şekilde parmaklarınızı güvende tutarsınız.',
    },
    {
      'title': 'Tavayı/Fırını Isıtma',
      'instruction': 'Tavayı orta-yüksek ateşte 2 dakika ısıtın veya fırını 180 dereceye ayarlayın.',
      'toolIcon': 'oven',
      'timerSeconds': 180,
      'proTip': 'Tavanın yeterince ısındığını anlamak için üzerine birkaç damla su serpin; cızırdayıp buharlaşıyorsa hazırdır.',
    },
    {
      'title': 'Soteleme ve Mühürleme',
      'instruction': 'Yağı tavaya ekleyip soğan ve sarımsakları pembeleşene kadar kavurun. Ardından ana malzemeyi ekleyip mühürleyin.',
      'toolIcon': 'pan',
      'timerSeconds': 420,
      'proTip': 'Tavayı aşırı doldurmayın! Malzemeler üst üste binerse kızarmak yerine buharda haşlanır.',
    },
    {
      'title': 'Sos ve Baharat Harmanlama',
      'instruction': 'Baharatları, salçayı veya sosu ekleyip kokusu çıkana kadar 1 dakika karıştırın, ardından ılık sıvıyı ilave edin.',
      'toolIcon': 'spoon',
      'timerSeconds': 240,
      'proTip': 'Baharatları yağa doğrudan hafifçe kavurarak eklemek aromatik yağların serbest kalmasını sağlar.',
    },
    {
      'title': 'Kısık Ateşte Demleme / Pişirme',
      'instruction': 'Tencerenin kapağını kapatın, ocağı en kısık seviyeye getirip belirtilen süre boyunca kendi buharında pişmeye bırakın.',
      'toolIcon': 'pot',
      'timerSeconds': 900,
      'proTip': 'Yemek pişerken kapağı sürekli açmayın; ısı ve buhar kaybı pişme süresini uzatır ve lezzeti azaltır.',
    },
    {
      'title': 'Çırpma ve Kıvam Alma',
      'instruction': 'Karıştırma kabında malzemeleri pürüzsüz homojen bir kıvam elde edene kadar ritmik hareketlerle çırpın.',
      'toolIcon': 'whisk',
      'timerSeconds': 300,
      'proTip': 'Çırpıcıyı daireler çizmek yerine 8 rakamı çizer gibi hareket ettirirseniz hava kabarcıkları daha hızlı oluşur.',
    },
    {
      'title': 'Dinlendirme ve Servis',
      'instruction': 'Yemeği ocaktan aldıktan sonra kapağı kapalı olarak 5 dakika dinlendirin, taze otlarla süsleyerek sıcak servis yapın.',
      'toolIcon': 'plate',
      'timerSeconds': 300,
      'proTip': 'Pişen et ve yemekleri dinlendirmek suların eşit dağılmasını ve lezzetin derinleşmesini sağlar.',
    },
  ];

  static const Map<String, String> categoryDefaultImages = {
    'Ana Yemek': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    'Tatlı': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',
    'Çorba': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'Kahvaltılık': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
    'Pratik': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
    'Hamur İşi': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Salata': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    'Vegan': 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?auto=format&fit=crop&w=800&q=80',
  };

  static const Map<String, String> dishImageUrls = {
    // Ana Yemek (16 dishes)
    'Güveçte Kuru Fasulye': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    'Fırında Tavuk Pirzola': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?auto=format&fit=crop&w=800&q=80',
    'Karnıyarık': 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?auto=format&fit=crop&w=800&q=80',
    'Hünkar Beğendi': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    'Izgara Kasap Köfte': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
    'Tas Kebabı': 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?auto=format&fit=crop&w=800&q=80',
    'Fırında Çipura': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
    'Mantarlı Tavuk Sote': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    'Kıymalı Biber Dolması': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
    'Orman Kebabı': 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?auto=format&fit=crop&w=800&q=80',
    'Terbiyeli Köfte': 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    'İmam Bayıldı': 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?auto=format&fit=crop&w=800&q=80',
    'Etli Nohut Yemeği': 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?auto=format&fit=crop&w=800&q=80',
    'Fırında Sebzeli Somon': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80',
    'Ali Nazik Kebabı': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
    'Kuzu İncik': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',

    // Tatlı (16 dishes)
    'Fırın Sütlaç': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80',
    'Kakaolu Islak Kek': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Kazandibi': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    'Tereyağlı İrmik Helvası': 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=800&q=80',
    'Şekerpare': 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?auto=format&fit=crop&w=800&q=80',
    'Çilekli Magnolia': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=800&q=80',
    'Cevizli Revani': 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=800&q=80',
    'Çikolatalı Supangle': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=800&q=80',
    'Karamelli Trileçe': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    'Havuçlu Tarçınlı Kek': 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?auto=format&fit=crop&w=800&q=80',
    'Saray Muhallebisi': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80',
    'Profiterol': 'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=800&q=80',
    'Baklava Dilimli Revani': 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=800&q=80',
    'Limonlu Cheesecake': 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=800&q=80',
    'Mozaik Pasta': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
    'Vişneli Ekmek Kadayıfı': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',

    // Çorba (12 dishes)
    'Süzme Kırmızı Mercimek': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Ezogelin': 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=800&q=80',
    'Naneli Yayla Çorbası': 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    'Kremalı Dağ Mantarı': 'https://images.unsplash.com/photo-1546069901-d5bfd2cbfb1f?auto=format&fit=crop&w=800&q=80',
    'Terbiyeli Tavuk Çorbası': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=800&q=80',
    'Ev Yapımı Tarhana': 'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?auto=format&fit=crop&w=800&q=80',
    'Fesleğenli Domates Çorbası': 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=800&q=80',
    'Düğün Çorbası': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=800&q=80',
    'Sebzeli Minestrone': 'https://images.unsplash.com/photo-1613844237701-8f3664fc2eff?auto=format&fit=crop&w=800&q=80',
    'Kelle Paça Usulü Çorba': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'Arpa Şehriyeli Çorba': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'Köz Kırmızı Biber Çorbası': 'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?auto=format&fit=crop&w=800&q=80',

    // Kahvaltılık (12 dishes)
    'Geleneksel Menemen': 'https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80',
    'Kayseri Sucuklu Yumurta': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
    'Kaşarlı Peynirli Krep': 'https://images.unsplash.com/photo-1519676867240-f03562e64548?auto=format&fit=crop&w=800&q=80',
    'Patatesli Köy Omleti': 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80',
    'Karadeniz Mıhlaması': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
    'Fırında Yumurtalı Kaşarlı Ekmek': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
    'Peynirli Sigara Böreği': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
    'Yulaflı Pankek': 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80',
    'Çılbır (Yoğurtlu Poşe Yumurta)': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
    'Simit & Kaşar Tostu': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'Zeytin Ezmeli Bruschetta': 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?auto=format&fit=crop&w=800&q=80',
    'Avokadolu Poşe Yumurta': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',

    // Pratik (12 dishes)
    'Sarımsaklı Domatesli Makarna': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
    'Tavuklu Fajita Wrap': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'Ton Balıklı Akdeniz Sandviç': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'Soya Soslu Sebzeli Noodle': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
    '5 Dakikalık Peynirli Quesadilla': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
    'Fırında Baharatlı Elma Dilim Patates': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=800&q=80',
    'Kremalı Tavuklu Penne': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
    'Mug Cake (Fincanda Kek)': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
    'Köz Sebzeli Lavaş Dürüm': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'Fasulye Piyazı Sandviç': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'Kremalı Mantarlı Ekmek Üstü': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'Pratik Tavada Pizza': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',

    // Hamur İşi (12 dishes)
    'Peynirli Tepsi Böreği': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Mayasız Puf Poğaça': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Kıymalı Kol Böreği': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
    'Taş Fırın Bazlama': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Susamlı Çıtır Simit': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Gözleme (Ispanaklı Peynirli)': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
    'Ev Yapımı Fındık Lahmacun': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    'Zeytinli Açma': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Kıymalı Pide': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    'Karaköy Poğaçası': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Otlu Çörek': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'Kuru Mayalı Peynirli Pide': 'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?auto=format&fit=crop&w=800&q=80',

    // Salata (12 dishes)
    'Geleneksel Çoban Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Cevizli Gavurdağı Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Akdeniz Yeşillikleri Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Roka & Parmesan Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Antalya Usulü Tahinli Piyaz': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Kinoa & Avokado Salatası': 'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?auto=format&fit=crop&w=800&q=80',
    'Hellim Peynirli Yeşil Salata': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    'Fırın Pancar & Keçi Peynirli Salata': 'https://images.unsplash.com/photo-1529059997568-3d847b1154f0?auto=format&fit=crop&w=800&q=80',
    'Semizotu & Yoğurt Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Köz Patlıcan Salatası': 'https://images.unsplash.com/photo-1529059997568-3d847b1154f0?auto=format&fit=crop&w=800&q=80',
    'Tavuklu Sezar Salata': 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=80',
    'Tabule (Bulgur Salatası)': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',

    // Vegan (12 dishes)
    'Kıtır Nohutlu Mercimek Bowl': 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?auto=format&fit=crop&w=800&q=80',
    'Zeytinyağlı Enginar Kalbi': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Fırında Baharatlı Karnabahar Steak': 'https://images.unsplash.com/photo-1568584711271-6c929fb49b60?auto=format&fit=crop&w=800&q=80',
    'Tahinli Humus & Fırın Sebzeler': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Mercimek Köftesi': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    'Mantarlı Tofu Sote': 'https://images.unsplash.com/photo-1546069901-d5bfd2cbfb1f?auto=format&fit=crop&w=800&q=80',
    'Fıstık Soslu Sebze Yahnisi': 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?auto=format&fit=crop&w=800&q=80',
    'Falafel Tabağı': 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?auto=format&fit=crop&w=800&q=80',
    'Fırın Tatlı Patates Dolması': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
    'Zeytinyağlı Kereviz': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Közlenmiş Sebze Güveci': 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?auto=format&fit=crop&w=800&q=80',
    'Buharda Edamame & Pirinç': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',

    // Yeni Zenginleştirilmiş Dünya Mutfakları Görselleri
    'Klasik Fırın Lazanya': 'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?auto=format&fit=crop&w=800&q=80',
    'Kremalı Mantarlı Risotto': 'https://images.unsplash.com/photo-1633964913295-ceb43826e7c9?auto=format&fit=crop&w=800&q=80',
    'Tavuklu Japon Rameni': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Pad Thai': 'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=800&q=80',
    'Tatlı Ekşi Soslu Tavuk': 'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=800&q=80',
    'Kıymalı Çıtır Taco': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80',
    'Tavuklu Fırın Enchilada': 'https://images.unsplash.com/photo-1534352956036-cd81e27dd615?auto=format&fit=crop&w=800&q=80',
    'Meksika Usulü Chili con Carne': 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=800&q=80',
    'Deniz Mahsullü Paella': 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Fırın Ratatouille': 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?auto=format&fit=crop&w=800&q=80',
    'Bursa İskender Kebabı': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    'Bodrum Çökertme Kebabı': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Tiramisu': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=800&q=80',
    'Sıcak Çikolatalı Sufle': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
    'Tarçınlı Meksika Churros': 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?auto=format&fit=crop&w=800&q=80',
    'Vanilyalı Panna Cotta': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80',
    'Antep Fıstıklı Katmer': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',
    'Meyveli Çıtır Tartalet': 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Miso Çorbası': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=800&q=80',
    'Fransız Karamelize Soğan Çorbası': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80',
    'Tom Yum Usulü Tavuk Çorbası': 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?auto=format&fit=crop&w=800&q=80',
    'Beyran Usulü Et Çorbası': 'https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?auto=format&fit=crop&w=800&q=80',
    'Yumurtalı Fried Rice': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
    'Taze Kruvasan Sandviç': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80',
    'Menemen Usulü Shakshuka': 'https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80',
    'Peynirli Çıtır Gözleme': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'İtalyan Pizza Margherita': 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=800&q=80',
    'Çıtır Ev Yapımı Smash Burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    'Özel Soslu Islak Burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    'Çıtır Tavuk Dürüm': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'Guacamole & Çıtır Nachos': 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?auto=format&fit=crop&w=800&q=80',
    'Etli Burrito Dürüm': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'Sebzeli Tavuklu Wok': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
    'Patatesli Gnocchi': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
    'Gyoza (Japon Mantısı)': 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=800&q=80',
    'Çıtır Sebzeli Spring Roll': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    'Kayseri Yağ Mantısı': 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=800&q=80',
    'Tavuklu & Pırasalı Quiche': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    'Geleneksel Grek Salatası': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
    'Köz Patlıcanlı Babagannuş': 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=800&q=80',
    'Tavuklu Chipotle Bowl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    'İzmir Usulü Kumru Sandviç': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    'Sebzeli Sushi Roll': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=800&q=80',
    'Körili Sebzeli Noodle': 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=800&q=80',
    'Falafel Dürüm': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'Zeytinyağlı Yaprak Sarma': 'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?auto=format&fit=crop&w=800&q=80',
  };

  static const List<String> cuisines = [
    'Tümü',
    'Türk Mutfağı',
    'İtalyan Mutfağı',
    'Asya & Uzak Doğu',
    'Meksika Mutfağı',
    'Akdeniz Mutfağı',
    'Fransız & Dünya',
    'Pratik & Sokak',
  ];

  static const Map<String, String> dishCuisines = {
    // Ana Yemek (28)
    'Güveçte Kuru Fasulye': 'Türk Mutfağı',
    'Fırında Tavuk Pirzola': 'Türk Mutfağı',
    'Karnıyarık': 'Türk Mutfağı',
    'Hünkar Beğendi': 'Türk Mutfağı',
    'Izgara Kasap Köfte': 'Türk Mutfağı',
    'Tas Kebabı': 'Türk Mutfağı',
    'Fırında Çipura': 'Akdeniz Mutfağı',
    'Mantarlı Tavuk Sote': 'Türk Mutfağı',
    'Kıymalı Biber Dolması': 'Türk Mutfağı',
    'Orman Kebabı': 'Türk Mutfağı',
    'Terbiyeli Köfte': 'Türk Mutfağı',
    'İmam Bayıldı': 'Türk Mutfağı',
    'Etli Nohut Yemeği': 'Türk Mutfağı',
    'Fırında Sebzeli Somon': 'Akdeniz Mutfağı',
    'Ali Nazik Kebabı': 'Türk Mutfağı',
    'Kuzu İncik': 'Türk Mutfağı',
    'Klasik Fırın Lazanya': 'İtalyan Mutfağı',
    'Kremalı Mantarlı Risotto': 'İtalyan Mutfağı',
    'Tavuklu Japon Rameni': 'Asya & Uzak Doğu',
    'Geleneksel Pad Thai': 'Asya & Uzak Doğu',
    'Tatlı Ekşi Soslu Tavuk': 'Asya & Uzak Doğu',
    'Kıymalı Çıtır Taco': 'Meksika Mutfağı',
    'Tavuklu Fırın Enchilada': 'Meksika Mutfağı',
    'Meksika Usulü Chili con Carne': 'Meksika Mutfağı',
    'Deniz Mahsullü Paella': 'Akdeniz Mutfağı',
    'Geleneksel Fırın Ratatouille': 'Fransız & Dünya',
    'Bursa İskender Kebabı': 'Türk Mutfağı',
    'Bodrum Çökertme Kebabı': 'Türk Mutfağı',

    // Tatlı (22)
    'Fırın Sütlaç': 'Türk Mutfağı',
    'Kakaolu Islak Kek': 'Fransız & Dünya',
    'Geleneksel Kazandibi': 'Türk Mutfağı',
    'Tereyağlı İrmik Helvası': 'Türk Mutfağı',
    'Şekerpare': 'Türk Mutfağı',
    'Çilekli Magnolia': 'Fransız & Dünya',
    'Cevizli Revani': 'Türk Mutfağı',
    'Çikolatalı Supangle': 'Fransız & Dünya',
    'Karamelli Trileçe': 'Fransız & Dünya',
    'Havuçlu Tarçınlı Kek': 'Fransız & Dünya',
    'Saray Muhallebisi': 'Türk Mutfağı',
    'Profiterol': 'Fransız & Dünya',
    'Baklava Dilimli Revani': 'Türk Mutfağı',
    'Limonlu Cheesecake': 'Fransız & Dünya',
    'Mozaik Pasta': 'Pratik & Sokak',
    'Vişneli Ekmek Kadayıfı': 'Türk Mutfağı',
    'Geleneksel Tiramisu': 'İtalyan Mutfağı',
    'Sıcak Çikolatalı Sufle': 'Fransız & Dünya',
    'Tarçınlı Meksika Churros': 'Meksika Mutfağı',
    'Vanilyalı Panna Cotta': 'İtalyan Mutfağı',
    'Antep Fıstıklı Katmer': 'Türk Mutfağı',
    'Meyveli Çıtır Tartalet': 'Fransız & Dünya',

    // Çorba (16)
    'Süzme Kırmızı Mercimek': 'Türk Mutfağı',
    'Geleneksel Ezogelin': 'Türk Mutfağı',
    'Naneli Yayla Çorbası': 'Türk Mutfağı',
    'Kremalı Dağ Mantarı': 'Fransız & Dünya',
    'Terbiyeli Tavuk Çorbası': 'Türk Mutfağı',
    'Ev Yapımı Tarhana': 'Türk Mutfağı',
    'Fesleğenli Domates Çorbası': 'İtalyan Mutfağı',
    'Düğün Çorbası': 'Türk Mutfağı',
    'Sebzeli Minestrone': 'İtalyan Mutfağı',
    'Kelle Paça Usulü Çorba': 'Türk Mutfağı',
    'Arpa Şehriyeli Çorba': 'Türk Mutfağı',
    'Köz Kırmızı Biber Çorbası': 'Akdeniz Mutfağı',
    'Geleneksel Miso Çorbası': 'Asya & Uzak Doğu',
    'Fransız Karamelize Soğan Çorbası': 'Fransız & Dünya',
    'Tom Yum Usulü Tavuk Çorbası': 'Asya & Uzak Doğu',
    'Beyran Usulü Et Çorbası': 'Türk Mutfağı',

    // Kahvaltılık (16)
    'Geleneksel Menemen': 'Türk Mutfağı',
    'Kayseri Sucuklu Yumurta': 'Türk Mutfağı',
    'Kaşarlı Peynirli Krep': 'Fransız & Dünya',
    'Patatesli Köy Omleti': 'Pratik & Sokak',
    'Karadeniz Mıhlaması': 'Türk Mutfağı',
    'Fırında Yumurtalı Kaşarlı Ekmek': 'Pratik & Sokak',
    'Peynirli Sigara Böreği': 'Türk Mutfağı',
    'Yulaflı Pankek': 'Fransız & Dünya',
    'Çılbır (Yoğurtlu Poşe Yumurta)': 'Türk Mutfağı',
    'Simit & Kaşar Tostu': 'Pratik & Sokak',
    'Zeytin Ezmeli Bruschetta': 'İtalyan Mutfağı',
    'Avokadolu Poşe Yumurta': 'Akdeniz Mutfağı',
    'Yumurtalı Fried Rice': 'Asya & Uzak Doğu',
    'Taze Kruvasan Sandviç': 'Fransız & Dünya',
    'Menemen Usulü Shakshuka': 'Akdeniz Mutfağı',
    'Peynirli Çıtır Gözleme': 'Türk Mutfağı',

    // Pratik (20)
    'Sarımsaklı Domatesli Makarna': 'İtalyan Mutfağı',
    'Tavuklu Fajita Wrap': 'Meksika Mutfağı',
    'Ton Balıklı Akdeniz Sandviç': 'Akdeniz Mutfağı',
    'Soya Soslu Sebzeli Noodle': 'Asya & Uzak Doğu',
    '5 Dakikalık Peynirli Quesadilla': 'Meksika Mutfağı',
    'Fırında Baharatlı Elma Dilim Patates': 'Pratik & Sokak',
    'Kremalı Tavuklu Penne': 'İtalyan Mutfağı',
    'Mug Cake (Fincanda Kek)': 'Pratik & Sokak',
    'Köz Sebzeli Lavaş Dürüm': 'Türk Mutfağı',
    'Fasulye Piyazı Sandviç': 'Türk Mutfağı',
    'Kremalı Mantarlı Ekmek Üstü': 'Fransız & Dünya',
    'Pratik Tavada Pizza': 'İtalyan Mutfağı',
    'İtalyan Pizza Margherita': 'İtalyan Mutfağı',
    'Çıtır Ev Yapımı Smash Burger': 'Pratik & Sokak',
    'Özel Soslu Islak Burger': 'Pratik & Sokak',
    'Çıtır Tavuk Dürüm': 'Pratik & Sokak',
    'Guacamole & Çıtır Nachos': 'Meksika Mutfağı',
    'Etli Burrito Dürüm': 'Meksika Mutfağı',
    'Sebzeli Tavuklu Wok': 'Asya & Uzak Doğu',
    'Patatesli Gnocchi': 'İtalyan Mutfağı',

    // Hamur İşi (16)
    'Peynirli Tepsi Böreği': 'Türk Mutfağı',
    'Mayasız Puf Poğaça': 'Türk Mutfağı',
    'Kıymalı Kol Böreği': 'Türk Mutfağı',
    'Taş Fırın Bazlama': 'Türk Mutfağı',
    'Susamlı Çıtır Simit': 'Türk Mutfağı',
    'Gözleme (Ispanaklı Peynirli)': 'Türk Mutfağı',
    'Ev Yapımı Fındık Lahmacun': 'Türk Mutfağı',
    'Zeytinli Açma': 'Türk Mutfağı',
    'Kıymalı Pide': 'Türk Mutfağı',
    'Karaköy Poğaçası': 'Türk Mutfağı',
    'Otlu Çörek': 'Türk Mutfağı',
    'Kuru Mayalı Peynirli Pide': 'Türk Mutfağı',
    'Gyoza (Japon Mantısı)': 'Asya & Uzak Doğu',
    'Çıtır Sebzeli Spring Roll': 'Asya & Uzak Doğu',
    'Kayseri Yağ Mantısı': 'Türk Mutfağı',
    'Tavuklu & Pırasalı Quiche': 'Fransız & Dünya',

    // Salata (16)
    'Geleneksel Çoban Salatası': 'Türk Mutfağı',
    'Cevizli Gavurdağı Salatası': 'Türk Mutfağı',
    'Akdeniz Yeşillikleri Salatası': 'Akdeniz Mutfağı',
    'Roka & Parmesan Salatası': 'İtalyan Mutfağı',
    'Antalya Usulü Tahinli Piyaz': 'Türk Mutfağı',
    'Kinoa & Avokado Salatası': 'Akdeniz Mutfağı',
    'Hellim Peynirli Yeşil Salata': 'Akdeniz Mutfağı',
    'Fırın Pancar & Keçi Peynirli Salata': 'Fransız & Dünya',
    'Semizotu & Yoğurt Salatası': 'Akdeniz Mutfağı',
    'Köz Patlıcan Salatası': 'Türk Mutfağı',
    'Tavuklu Sezar Salata': 'Fransız & Dünya',
    'Tabule (Bulgur Salatası)': 'Akdeniz Mutfağı',
    'Geleneksel Grek Salatası': 'Akdeniz Mutfağı',
    'Köz Patlıcanlı Babagannuş': 'Akdeniz Mutfağı',
    'Tavuklu Chipotle Bowl': 'Meksika Mutfağı',
    'İzmir Usulü Kumru Sandviç': 'Pratik & Sokak',

    // Vegan (16)
    'Kıtır Nohutlu Mercimek Bowl': 'Akdeniz Mutfağı',
    'Zeytinyağlı Enginar Kalbi': 'Akdeniz Mutfağı',
    'Fırında Baharatlı Karnabahar Steak': 'Fransız & Dünya',
    'Tahinli Humus & Fırın Sebzeler': 'Akdeniz Mutfağı',
    'Geleneksel Mercimek Köftesi': 'Türk Mutfağı',
    'Mantarlı Tofu Sote': 'Asya & Uzak Doğu',
    'Fıstık Soslu Sebze Yahnisi': 'Asya & Uzak Doğu',
    'Falafel Tabağı': 'Akdeniz Mutfağı',
    'Fırın Tatlı Patates Dolması': 'Fransız & Dünya',
    'Zeytinyağlı Kereviz': 'Türk Mutfağı',
    'Közlenmiş Sebze Güveci': 'Akdeniz Mutfağı',
    'Buharda Edamame & Pirinç': 'Asya & Uzak Doğu',
    'Sebzeli Sushi Roll': 'Asya & Uzak Doğu',
    'Körili Sebzeli Noodle': 'Asya & Uzak Doğu',
    'Falafel Dürüm': 'Pratik & Sokak',
    'Zeytinyağlı Yaprak Sarma': 'Türk Mutfağı',
  };

  static const Map<String, List<String>> dishIngredientKeys = {
    // Ana Yemek (28)
    'Güveçte Kuru Fasulye': ['fasulye', 'sogan', 'domates', 'tereyagi', 'biber'],
    'Fırında Tavuk Pirzola': ['tavuk', 'patates', 'biber', 'zeytinyagi', 'baharat'],
    'Karnıyarık': ['patlican', 'kiyma', 'sogan', 'domates', 'biber', 'sarimsak'],
    'Hünkar Beğendi': ['et', 'patlican', 'sut', 'un', 'tereyagi', 'peynir'],
    'Izgara Kasap Köfte': ['kiyma', 'sogan', 'sarimsak', 'baharat', 'tuz'],
    'Tas Kebabı': ['et', 'patates', 'sogan', 'domates', 'havuc', 'sarimsak'],
    'Fırında Çipura': ['balik', 'zeytinyagi', 'sarimsak', 'limon', 'baharat'],
    'Mantarlı Tavuk Sote': ['tavuk', 'mantar', 'sogan', 'biber', 'domates', 'zeytinyagi'],
    'Kıymalı Biber Dolması': ['biber', 'kiyma', 'pirinc', 'sogan', 'domates', 'zeytinyagi'],
    'Orman Kebabı': ['et', 'patates', 'havuc', 'sogan', 'tereyagi', 'baharat'],
    'Terbiyeli Köfte': ['kiyma', 'pirinc', 'patates', 'havuc', 'yumurta', 'yogurt'],
    'İmam Bayıldı': ['patlican', 'sogan', 'domates', 'sarimsak', 'biber', 'zeytinyagi'],
    'Etli Nohut Yemeği': ['nohut', 'et', 'sogan', 'domates', 'tereyagi', 'biber'],
    'Fırında Sebzeli Somon': ['balik', 'patates', 'havuc', 'zeytinyagi', 'limon', 'sarimsak'],
    'Ali Nazik Kebabı': ['kiyma', 'patlican', 'yogurt', 'sarimsak', 'tereyagi'],
    'Kuzu İncik': ['et', 'sogan', 'havuc', 'patates', 'sarimsak', 'tereyagi'],
    'Klasik Fırın Lazanya': ['kiyma', 'makarna', 'domates', 'sut', 'peynir'],
    'Kremalı Mantarlı Risotto': ['pirinc', 'mantar', 'tereyagi', 'peynir', 'sarimsak'],
    'Tavuklu Japon Rameni': ['noodle', 'tavuk', 'yumurta', 'sarimsak', 'sut'],
    'Geleneksel Pad Thai': ['noodle', 'tavuk', 'yumurta', 'biber', 'limon'],
    'Tatlı Ekşi Soslu Tavuk': ['tavuk', 'biber', 'havuc', 'seker', 'zeytinyagi'],
    'Kıymalı Çıtır Taco': ['lavas', 'kiyma', 'domates', 'biber', 'peynir'],
    'Tavuklu Fırın Enchilada': ['lavas', 'tavuk', 'domates', 'peynir', 'biber'],
    'Meksika Usulü Chili con Carne': ['kiyma', 'fasulye', 'domates', 'biber', 'sogan'],
    'Deniz Mahsullü Paella': ['pirinc', 'balik', 'domates', 'biber', 'limon'],
    'Geleneksel Fırın Ratatouille': ['patlican', 'domates', 'biber', 'sarimsak', 'zeytinyagi'],
    'Bursa İskender Kebabı': ['et', 'tereyagi', 'domates', 'yogurt'],
    'Bodrum Çökertme Kebabı': ['et', 'patates', 'yogurt', 'tereyagi', 'domates'],

    // Tatlı (22)
    'Fırın Sütlaç': ['sut', 'pirinc', 'seker', 'yumurta'],
    'Kakaolu Islak Kek': ['un', 'seker', 'kakao', 'sut', 'yumurta', 'zeytinyagi'],
    'Geleneksel Kazandibi': ['sut', 'seker', 'pirinc', 'un', 'tereyagi'],
    'Tereyağlı İrmik Helvası': ['irmik', 'tereyagi', 'seker', 'sut', 'ceviz'],
    'Şekerpare': ['un', 'irmik', 'seker', 'tereyagi', 'yumurta'],
    'Çilekli Magnolia': ['sut', 'seker', 'un', 'yumurta', 'tereyagi'],
    'Cevizli Revani': ['irmik', 'un', 'yumurta', 'seker', 'ceviz', 'yogurt'],
    'Çikolatalı Supangle': ['sut', 'seker', 'kakao', 'un', 'tereyagi'],
    'Karamelli Trileçe': ['un', 'yumurta', 'seker', 'sut'],
    'Havuçlu Tarçınlı Kek': ['un', 'havuc', 'seker', 'yumurta', 'ceviz', 'zeytinyagi'],
    'Saray Muhallebisi': ['sut', 'un', 'tereyagi', 'seker'],
    'Profiterol': ['un', 'tereyagi', 'yumurta', 'sut', 'seker', 'kakao'],
    'Baklava Dilimli Revani': ['irmik', 'un', 'seker', 'yumurta', 'tereyagi'],
    'Limonlu Cheesecake': ['peynir', 'seker', 'yumurta', 'limon', 'tereyagi', 'un'],
    'Mozaik Pasta': ['kakao', 'sut', 'tereyagi', 'seker'],
    'Vişneli Ekmek Kadayıfı': ['seker', 'tereyagi', 'un'],
    'Geleneksel Tiramisu': ['peynir', 'seker', 'kakao', 'yumurta', 'sut'],
    'Sıcak Çikolatalı Sufle': ['kakao', 'tereyagi', 'yumurta', 'seker', 'un'],
    'Tarçınlı Meksika Churros': ['un', 'tereyagi', 'seker', 'kakao'],
    'Vanilyalı Panna Cotta': ['sut', 'seker', 'cilek'],
    'Antep Fıstıklı Katmer': ['yufka', 'tereyagi', 'seker', 'sut'],
    'Meyveli Çıtır Tartalet': ['un', 'tereyagi', 'seker', 'sut', 'yumurta'],

    // Çorba (16)
    'Süzme Kırmızı Mercimek': ['mercimek', 'sogan', 'havuc', 'patates', 'tereyagi', 'tuz'],
    'Geleneksel Ezogelin': ['mercimek', 'bulgur', 'pirinc', 'sogan', 'domates', 'tereyagi'],
    'Naneli Yayla Çorbası': ['yogurt', 'pirinc', 'yumurta', 'un', 'tereyagi', 'baharat'],
    'Kremalı Dağ Mantarı': ['mantar', 'sut', 'un', 'tereyagi', 'sogan', 'sarimsak'],
    'Terbiyeli Tavuk Çorbası': ['tavuk', 'un', 'yogurt', 'yumurta', 'limon', 'tereyagi'],
    'Ev Yapımı Tarhana': ['tereyagi', 'domates', 'baharat', 'sarimsak'],
    'Fesleğenli Domates Çorbası': ['domates', 'un', 'sut', 'tereyagi', 'sarimsak'],
    'Düğün Çorbası': ['et', 'un', 'yogurt', 'yumurta', 'tereyagi', 'limon'],
    'Sebzeli Minestrone': ['makarna', 'domates', 'havuc', 'sarimsak', 'zeytinyagi'],
    'Kelle Paça Usulü Çorba': ['et', 'sarimsak', 'un', 'tereyagi', 'baharat'],
    'Arpa Şehriyeli Çorba': ['tavuk', 'domates', 'tereyagi', 'baharat'],
    'Köz Kırmızı Biber Çorbası': ['biber', 'domates', 'sogan', 'sarimsak', 'zeytinyagi', 'sut'],
    'Geleneksel Miso Çorbası': ['tofu', 'yesillik', 'sarimsak'],
    'Fransız Karamelize Soğan Çorbası': ['sogan', 'tereyagi', 'un', 'peynir'],
    'Tom Yum Usulü Tavuk Çorbası': ['tavuk', 'mantar', 'limon', 'biber', 'sarimsak'],
    'Beyran Usulü Et Çorbası': ['et', 'pirinc', 'sarimsak', 'tereyagi', 'baharat'],

    // Kahvaltılık (16)
    'Geleneksel Menemen': ['yumurta', 'domates', 'biber', 'tereyagi', 'tuz'],
    'Kayseri Sucuklu Yumurta': ['sucuk', 'yumurta', 'tereyagi', 'baharat'],
    'Kaşarlı Peynirli Krep': ['un', 'sut', 'yumurta', 'peynir', 'tereyagi'],
    'Patatesli Köy Omleti': ['patates', 'yumurta', 'sogan', 'zeytinyagi', 'peynir'],
    'Karadeniz Mıhlaması': ['un', 'tereyagi', 'peynir', 'tuz'],
    'Fırında Yumurtalı Kaşarlı Ekmek': ['yumurta', 'peynir', 'tereyagi', 'domates'],
    'Peynirli Sigara Böreği': ['yufka', 'peynir', 'yesillik', 'zeytinyagi'],
    'Yulaflı Pankek': ['un', 'yumurta', 'sut', 'seker'],
    'Çılbır (Yoğurtlu Poşe Yumurta)': ['yumurta', 'yogurt', 'sarimsak', 'tereyagi', 'baharat'],
    'Simit & Kaşar Tostu': ['peynir', 'domates', 'tereyagi', 'sucuk'],
    'Zeytin Ezmeli Bruschetta': ['domates', 'sarimsak', 'zeytinyagi', 'peynir'],
    'Avokadolu Poşe Yumurta': ['avokado', 'yumurta', 'limon', 'zeytinyagi'],
    'Yumurtalı Fried Rice': ['pirinc', 'yumurta', 'havuc', 'zeytinyagi'],
    'Taze Kruvasan Sandviç': ['un', 'tereyagi', 'peynir', 'domates'],
    'Menemen Usulü Shakshuka': ['domates', 'biber', 'yumurta', 'sarimsak', 'zeytinyagi'],
    'Peynirli Çıtır Gözleme': ['yufka', 'peynir', 'tereyagi', 'yesillik'],

    // Pratik (20)
    'Sarımsaklı Domatesli Makarna': ['makarna', 'domates', 'sarimsak', 'zeytinyagi', 'baharat'],
    'Tavuklu Fajita Wrap': ['tavuk', 'biber', 'sogan', 'lavas', 'baharat', 'zeytinyagi'],
    'Ton Balıklı Akdeniz Sandviç': ['ton baligi', 'domates', 'yesillik', 'zeytinyagi', 'limon'],
    'Soya Soslu Sebzeli Noodle': ['noodle', 'havuc', 'biber', 'sarimsak', 'zeytinyagi'],
    '5 Dakikalık Peynirli Quesadilla': ['lavas', 'peynir', 'biber', 'domates', 'tereyagi'],
    'Fırında Baharatlı Elma Dilim Patates': ['patates', 'zeytinyagi', 'baharat', 'sarimsak', 'tuz'],
    'Kremalı Tavuklu Penne': ['makarna', 'tavuk', 'mantar', 'sut', 'sarimsak', 'peynir'],
    'Mug Cake (Fincanda Kek)': ['un', 'seker', 'kakao', 'sut', 'zeytinyagi'],
    'Köz Sebzeli Lavaş Dürüm': ['lavas', 'patlican', 'biber', 'domates', 'peynir'],
    'Fasulye Piyazı Sandviç': ['fasulye', 'sogan', 'yumurta', 'yesillik', 'zeytinyagi'],
    'Kremalı Mantarlı Ekmek Üstü': ['mantar', 'sut', 'sarimsak', 'tereyagi', 'peynir'],
    'Pratik Tavada Pizza': ['un', 'domates', 'peynir', 'sucuk', 'zeytinyagi'],
    'İtalyan Pizza Margherita': ['un', 'domates', 'peynir', 'zeytinyagi'],
    'Çıtır Ev Yapımı Smash Burger': ['kiyma', 'peynir', 'sogan', 'tereyagi'],
    'Özel Soslu Islak Burger': ['kiyma', 'domates', 'sarimsak', 'tereyagi'],
    'Çıtır Tavuk Dürüm': ['tavuk', 'lavas', 'patates', 'domates'],
    'Guacamole & Çıtır Nachos': ['avokado', 'domates', 'sogan', 'limon', 'lavas'],
    'Etli Burrito Dürüm': ['lavas', 'et', 'fasulye', 'pirinc', 'peynir'],
    'Sebzeli Tavuklu Wok': ['tavuk', 'havuc', 'biber', 'sarimsak', 'zeytinyagi'],
    'Patatesli Gnocchi': ['patates', 'un', 'yumurta', 'domates', 'peynir'],

    // Hamur İşi (16)
    'Peynirli Tepsi Böreği': ['yufka', 'peynir', 'sut', 'yumurta', 'tereyagi'],
    'Mayasız Puf Poğaça': ['un', 'yogurt', 'zeytinyagi', 'peynir', 'yumurta'],
    'Kıymalı Kol Böreği': ['yufka', 'kiyma', 'sogan', 'tereyagi', 'baharat'],
    'Taş Fırın Bazlama': ['un', 'tuz', 'yogurt', 'zeytinyagi'],
    'Susamlı Çıtır Simit': ['un', 'seker', 'tuz', 'zeytinyagi'],
    'Gözleme (Ispanaklı Peynirli)': ['yufka', 'peynir', 'sogan', 'tereyagi', 'yesillik'],
    'Ev Yapımı Fındık Lahmacun': ['un', 'kiyma', 'domates', 'biber', 'sogan', 'sarimsak'],
    'Zeytinli Açma': ['un', 'sut', 'tereyagi', 'yumurta'],
    'Kıymalı Pide': ['un', 'kiyma', 'sogan', 'domates', 'biber'],
    'Karaköy Poğaçası': ['un', 'tereyagi', 'yumurta', 'peynir'],
    'Otlu Çörek': ['un', 'peynir', 'yesillik', 'yogurt', 'zeytinyagi'],
    'Kuru Mayalı Peynirli Pide': ['un', 'peynir', 'tereyagi', 'yumurta'],
    'Gyoza (Japon Mantısı)': ['un', 'kiyma', 'sarimsak', 'sogan'],
    'Çıtır Sebzeli Spring Roll': ['yufka', 'havuc', 'zeytinyagi'],
    'Kayseri Yağ Mantısı': ['un', 'kiyma', 'sogan', 'yogurt', 'tereyagi'],
    'Tavuklu & Pırasalı Quiche': ['un', 'tereyagi', 'yumurta', 'sut', 'peynir', 'tavuk'],

    // Salata (16)
    'Geleneksel Çoban Salatası': ['domates', 'biber', 'sogan', 'zeytinyagi', 'limon'],
    'Cevizli Gavurdağı Salatası': ['domates', 'ceviz', 'sogan', 'biber', 'zeytinyagi'],
    'Akdeniz Yeşillikleri Salatası': ['yesillik', 'domates', 'peynir', 'zeytinyagi', 'limon'],
    'Roka & Parmesan Salatası': ['yesillik', 'peynir', 'domates', 'zeytinyagi', 'ceviz'],
    'Antalya Usulü Tahinli Piyaz': ['fasulye', 'yumurta', 'sogan', 'domates', 'limon', 'zeytinyagi'],
    'Kinoa & Avokado Salatası': ['avokado', 'domates', 'zeytinyagi', 'limon', 'yesillik'],
    'Hellim Peynirli Yeşil Salata': ['peynir', 'yesillik', 'domates', 'zeytinyagi'],
    'Fırın Pancar & Keçi Peynirli Salata': ['peynir', 'ceviz', 'yesillik', 'zeytinyagi'],
    'Semizotu & Yoğurt Salatası': ['yesillik', 'yogurt', 'sarimsak', 'zeytinyagi', 'tuz'],
    'Köz Patlıcan Salatası': ['patlican', 'biber', 'sarimsak', 'zeytinyagi', 'limon'],
    'Tavuklu Sezar Salata': ['tavuk', 'yesillik', 'peynir', 'zeytinyagi', 'sarimsak'],
    'Tabule (Bulgur Salatası)': ['bulgur', 'yesillik', 'domates', 'zeytinyagi', 'limon'],
    'Geleneksel Grek Salatası': ['domates', 'biber', 'peynir', 'zeytinyagi', 'limon'],
    'Köz Patlıcanlı Babagannuş': ['patlican', 'sarimsak', 'yogurt', 'zeytinyagi'],
    'Tavuklu Chipotle Bowl': ['tavuk', 'pirinc', 'fasulye', 'avokado'],
    'İzmir Usulü Kumru Sandviç': ['sucuk', 'peynir', 'domates', 'tereyagi'],

    // Vegan (16)
    'Kıtır Nohutlu Mercimek Bowl': ['nohut', 'mercimek', 'avokado', 'zeytinyagi', 'limon'],
    'Zeytinyağlı Enginar Kalbi': ['havuc', 'patates', 'zeytinyagi', 'limon', 'sogan'],
    'Fırında Baharatlı Karnabahar Steak': ['zeytinyagi', 'sarimsak', 'baharat', 'limon'],
    'Tahinli Humus & Fırın Sebzeler': ['nohut', 'sarimsak', 'limon', 'zeytinyagi'],
    'Geleneksel Mercimek Köftesi': ['mercimek', 'bulgur', 'sogan', 'domates', 'yesillik', 'zeytinyagi'],
    'Mantarlı Tofu Sote': ['tofu', 'mantar', 'sarimsak', 'biber', 'zeytinyagi'],
    'Fıstık Soslu Sebze Yahnisi': ['havuc', 'biber', 'sarimsak', 'zeytinyagi'],
    'Falafel Tabağı': ['nohut', 'yesillik', 'sarimsak', 'sogan', 'baharat'],
    'Fırın Tatlı Patates Dolması': ['patates', 'nohut', 'zeytinyagi', 'baharat', 'limon'],
    'Zeytinyağlı Kereviz': ['havuc', 'patates', 'zeytinyagi', 'limon', 'sogan'],
    'Közlenmiş Sebze Güveci': ['patlican', 'biber', 'domates', 'sarimsak', 'zeytinyagi'],
    'Buharda Edamame & Pirinç': ['pirinc', 'sarimsak', 'zeytinyagi'],
    'Sebzeli Sushi Roll': ['pirinc', 'avokado', 'zeytinyagi'],
    'Körili Sebzeli Noodle': ['noodle', 'havuc', 'biber', 'baharat'],
    'Falafel Dürüm': ['nohut', 'lavas', 'domates', 'yesillik'],
    'Zeytinyağlı Yaprak Sarma': ['pirinc', 'sogan', 'zeytinyagi', 'baharat', 'limon'],
  };

  /// Realistic culinary timings for each base dish [prepMinutes, cookMinutes]
  static const Map<String, List<int>> dishTimes = {
    // Ana Yemek (28)
    'Güveçte Kuru Fasulye': [20, 60],
    'Fırında Tavuk Pirzola': [15, 40],
    'Karnıyarık': [25, 40],
    'Hünkar Beğendi': [25, 50],
    'Izgara Kasap Köfte': [20, 15],
    'Tas Kebabı': [20, 50],
    'Fırında Çipura': [15, 30],
    'Mantarlı Tavuk Sote': [15, 25],
    'Kıymalı Biber Dolması': [25, 40],
    'Orman Kebabı': [20, 45],
    'Terbiyeli Köfte': [25, 35],
    'İmam Bayıldı': [20, 35],
    'Etli Nohut Yemeği': [20, 55],
    'Fırında Sebzeli Somon': [15, 25],
    'Ali Nazik Kebabı': [25, 30],
    'Kuzu İncik': [20, 85],
    'Klasik Fırın Lazanya': [30, 45],
    'Kremalı Mantarlı Risotto': [15, 25],
    'Tavuklu Japon Rameni': [20, 40],
    'Geleneksel Pad Thai': [15, 15],
    'Tatlı Ekşi Soslu Tavuk': [20, 20],
    'Kıymalı Çıtır Taco': [15, 15],
    'Tavuklu Fırın Enchilada': [20, 35],
    'Meksika Usulü Chili con Carne': [20, 60],
    'Deniz Mahsullü Paella': [20, 40],
    'Geleneksel Fırın Ratatouille': [25, 50],
    'Bursa İskender Kebabı': [25, 30],
    'Bodrum Çökertme Kebabı': [25, 30],

    // Tatlı (22)
    'Fırın Sütlaç': [15, 40],
    'Kakaolu Islak Kek': [20, 35],
    'Geleneksel Kazandibi': [15, 35],
    'Tereyağlı İrmik Helvası': [10, 25],
    'Şekerpare': [25, 30],
    'Çilekli Magnolia': [25, 15],
    'Cevizli Revani': [20, 35],
    'Çikolatalı Supangle': [15, 15],
    'Karamelli Trileçe': [30, 40],
    'Havuçlu Tarçınlı Kek': [20, 40],
    'Saray Muhallebisi': [15, 20],
    'Profiterol': [35, 35],
    'Baklava Dilimli Revani': [25, 35],
    'Limonlu Cheesecake': [30, 60],
    'Mozaik Pasta': [15, 5],
    'Vişneli Ekmek Kadayıfı': [20, 35],
    'Geleneksel Tiramisu': [25, 10],
    'Sıcak Çikolatalı Sufle': [15, 12],
    'Tarçınlı Meksika Churros': [20, 15],
    'Vanilyalı Panna Cotta': [15, 15],
    'Antep Fıstıklı Katmer': [20, 15],
    'Meyveli Çıtır Tartalet': [30, 25],

    // Çorba (16)
    'Süzme Kırmızı Mercimek': [10, 30],
    'Geleneksel Ezogelin': [10, 35],
    'Naneli Yayla Çorbası': [10, 25],
    'Kremalı Dağ Mantarı': [15, 25],
    'Terbiyeli Tavuk Çorbası': [15, 40],
    'Ev Yapımı Tarhana': [10, 25],
    'Fesleğenli Domates Çorbası': [10, 25],
    'Düğün Çorbası': [15, 45],
    'Sebzeli Minestrone': [15, 35],
    'Kelle Paça Usulü Çorba': [20, 55],
    'Arpa Şehriyeli Çorba': [10, 25],
    'Köz Kırmızı Biber Çorbası': [15, 25],
    'Geleneksel Miso Çorbası': [10, 15],
    'Fransız Karamelize Soğan Çorbası': [15, 45],
    'Tom Yum Usulü Tavuk Çorbası': [15, 30],
    'Beyran Usulü Et Çorbası': [20, 65],

    // Kahvaltılık (16)
    'Geleneksel Menemen': [10, 15],
    'Kayseri Sucuklu Yumurta': [5, 10],
    'Kaşarlı Peynirli Krep': [10, 15],
    'Patatesli Köy Omleti': [10, 15],
    'Karadeniz Mıhlaması': [5, 12],
    'Fırında Yumurtalı Kaşarlı Ekmek': [8, 15],
    'Peynirli Sigara Böreği': [15, 15],
    'Yulaflı Pankek': [10, 12],
    'Çılbır (Yoğurtlu Poşe Yumurta)': [10, 10],
    'Simit & Kaşar Tostu': [5, 8],
    'Zeytin Ezmeli Bruschetta': [10, 8],
    'Avokadolu Poşe Yumurta': [10, 8],
    'Yumurtalı Fried Rice': [10, 15],
    'Taze Kruvasan Sandviç': [10, 5],
    'Menemen Usulü Shakshuka': [10, 18],
    'Peynirli Çıtır Gözleme': [15, 12],

    // Pratik (20)
    'Sarımsaklı Domatesli Makarna': [8, 15],
    'Tavuklu Fajita Wrap': [15, 18],
    'Ton Balıklı Akdeniz Sandviç': [10, 5],
    'Soya Soslu Sebzeli Noodle': [10, 15],
    '5 Dakikalık Peynirli Quesadilla': [5, 10],
    'Fırında Baharatlı Elma Dilim Patates': [10, 35],
    'Kremalı Tavuklu Penne': [12, 20],
    'Mug Cake (Fincanda Kek)': [5, 3],
    'Köz Sebzeli Lavaş Dürüm': [10, 12],
    'Fasulye Piyazı Sandviç': [10, 5],
    'Kremalı Mantarlı Ekmek Üstü': [10, 12],
    'Pratik Tavada Pizza': [10, 18],
    'İtalyan Pizza Margherita': [25, 15],
    'Çıtır Ev Yapımı Smash Burger': [15, 12],
    'Özel Soslu Islak Burger': [15, 15],
    'Çıtır Tavuk Dürüm': [15, 18],
    'Guacamole & Çıtır Nachos': [10, 5],
    'Etli Burrito Dürüm': [15, 15],
    'Sebzeli Tavuklu Wok': [12, 15],
    'Patatesli Gnocchi': [25, 15],

    // Hamur İşi (16)
    'Peynirli Tepsi Böreği': [25, 40],
    'Mayasız Puf Poğaça': [20, 30],
    'Kıymalı Kol Böreği': [30, 45],
    'Taş Fırın Bazlama': [20, 15],
    'Susamlı Çıtır Simit': [30, 25],
    'Gözleme (Ispanaklı Peynirli)': [20, 15],
    'Ev Yapımı Fındık Lahmacun': [30, 15],
    'Zeytinli Açma': [30, 30],
    'Kıymalı Pide': [30, 25],
    'Karaköy Poğaçası': [20, 30],
    'Otlu Çörek': [25, 35],
    'Kuru Mayalı Peynirli Pide': [30, 25],
    'Gyoza (Japon Mantısı)': [30, 15],
    'Çıtır Sebzeli Spring Roll': [20, 15],
    'Kayseri Yağ Mantısı': [35, 30],
    'Tavuklu & Pırasalı Quiche': [25, 40],

    // Salata (16)
    'Geleneksel Çoban Salatası': [15, 5],
    'Cevizli Gavurdağı Salatası': [15, 5],
    'Akdeniz Yeşillikleri Salatası': [12, 5],
    'Roka & Parmesan Salatası': [10, 5],
    'Antalya Usulü Tahinli Piyaz': [15, 5],
    'Kinoa & Avokado Salatası': [15, 15],
    'Hellim Peynirli Yeşil Salata': [10, 8],
    'Fırın Pancar & Keçi Peynirli Salata': [15, 40],
    'Semizotu & Yoğurt Salatası': [10, 5],
    'Köz Patlıcan Salatası': [15, 25],
    'Tavuklu Sezar Salata': [15, 15],
    'Tabule (Bulgur Salatası)': [15, 10],
    'Geleneksel Grek Salatası': [12, 5],
    'Köz Patlıcanlı Babagannuş': [15, 25],
    'Tavuklu Chipotle Bowl': [15, 18],
    'İzmir Usulü Kumru Sandviç': [10, 10],

    // Vegan (16)
    'Kıtır Nohutlu Mercimek Bowl': [15, 25],
    'Zeytinyağlı Enginar Kalbi': [20, 40],
    'Fırında Baharatlı Karnabahar Steak': [15, 35],
    'Tahinli Humus & Fırın Sebzeler': [15, 30],
    'Geleneksel Mercimek Köftesi': [25, 20],
    'Mantarlı Tofu Sote': [15, 15],
    'Fıstık Soslu Sebze Yahnisi': [15, 30],
    'Falafel Tabağı': [25, 18],
    'Fırın Tatlı Patates Dolması': [15, 45],
    'Zeytinyağlı Kereviz': [20, 40],
    'Közlenmiş Sebze Güveci': [20, 45],
    'Buharda Edamame & Pirinç': [10, 20],
    'Sebzeli Sushi Roll': [25, 20],
    'Körili Sebzeli Noodle': [12, 15],
    'Falafel Dürüm': [20, 15],
    'Zeytinyağlı Yaprak Sarma': [45, 50],
  };

  static const Map<String, List<int>> categoryDefaultTimes = {
    'Ana Yemek': [20, 45],
    'Tatlı': [20, 30],
    'Çorba': [10, 25],
    'Kahvaltılık': [10, 12],
    'Pratik': [10, 15],
    'Hamur İşi': [25, 30],
    'Salata': [15, 5],
    'Vegan': [15, 25],
  };

  static Recipe generate(int index) {
    final category = categories[index % categories.length];
    final baseDishes = categoryDishBases[category]!;
    final baseDish = baseDishes[(index ~/ categories.length) % baseDishes.length];
    final adjective = titleAdjectives[(index * 7) % titleAdjectives.length];
    final title = '$adjective $baseDish';
    final recipeNumber = index + 1;
    final times = dishTimes[baseDish] ?? categoryDefaultTimes[category] ?? const [15, 30];
    final prepTime = times[0];
    final cookTime = times[1];
    final totalMinutes = prepTime + cookTime;
    final String difficulty;
    if (totalMinutes <= 25) {
      difficulty = 'Kolay';
    } else if (totalMinutes <= 55) {
      difficulty = 'Orta';
    } else {
      difficulty = 'Zor';
    }

    final imageUrl = dishImageUrls[baseDish] ?? categoryDefaultImages[category]!;
    final cuisine = dishCuisines[baseDish] ?? 'Türk Mutfağı';

    final List<String> selectedKeys = pickKeysForDish(baseDish, category);

    final List<Ingredient> ingredients = [];
    for (final key in selectedKeys) {
      final pool = ingredientPool[key] ?? [
        Ingredient(name: key[0].toUpperCase() + key.substring(1), amount: '1', unit: 'porsiyon')
      ];
      final ingredientVariant = pool[index % pool.length];
      ingredients.add(ingredientVariant);
    }

    final List<Substitution> substitutions = [];
    for (final sub in commonSubstitutions) {
      if (selectedKeys.contains(sub.ingredient)) {
        substitutions.add(sub);
      }
    }

    final List<CookingStep> steps = buildStepsForDish(
      baseDish: baseDish,
      category: category,
      ingredients: ingredients,
      prepTime: prepTime,
      cookTime: cookTime,
    );

    return Recipe(
      id: 'rec_${recipeNumber.toString().padLeft(5, '0')}',
      title: title,
      category: category,
      cuisine: cuisine,
      baseDish: baseDish,
      prepTime: prepTime,
      cookTime: cookTime,
      difficulty: difficulty,
      ingredientKeys: selectedKeys,
      ingredients: ingredients,
      substitutions: substitutions,
      steps: steps,
      servings: 2 + (index % 4) * 2,
      imageUrl: imageUrl,
    );
  }

  static List<String> pickKeysForDish(String baseDish, String category) {
    final dishKeys = dishIngredientKeys[baseDish];
    if (dishKeys != null && dishKeys.isNotEmpty) {
      return dishKeys;
    }
    return _pickKeys(category);
  }

  static List<String> _pickKeys(String category) {
    switch (category) {
      case 'Ana Yemek':
        return ['sogan', 'sarimsak', 'tuz', 'zeytinyagi', 'kiyma', 'domates'];
      case 'Tatlı':
        return ['un', 'seker', 'sut', 'yumurta', 'tereyagi'];
      case 'Çorba':
        return ['mercimek', 'sogan', 'tereyagi', 'tuz', 'baharat'];
      case 'Kahvaltılık':
        return ['yumurta', 'domates', 'biber', 'peynir', 'tereyagi'];
      case 'Pratik':
        return ['makarna', 'domates', 'zeytinyagi', 'sarimsak', 'peynir'];
      case 'Hamur İşi':
        return ['un', 'sut', 'yumurta', 'peynir', 'tuz'];
      case 'Salata':
        return ['domates', 'biber', 'zeytinyagi', 'tuz', 'sogan'];
      case 'Vegan':
        return ['mercimek', 'zeytinyagi', 'sarimsak', 'sogan', 'domates'];
      default:
        return ['un', 'tuz', 'zeytinyagi'];
    }
  }

  static String _findIngredientText(
    List<Ingredient> ingredients,
    List<String> keywords,
    String fallback,
  ) {
    for (final kw in keywords) {
      for (final ing in ingredients) {
        if (ing.name.toLowerCase().contains(kw.toLowerCase())) {
          return '${ing.amount} ${ing.unit} ${ing.name}';
        }
      }
    }
    return fallback;
  }

  static List<String> _findIngredientList(
    List<Ingredient> ingredients,
    List<String> keywords,
  ) {
    final results = <String>[];
    for (final kw in keywords) {
      for (final ing in ingredients) {
        if (ing.name.toLowerCase().contains(kw.toLowerCase())) {
          final desc = '${ing.amount} ${ing.unit} ${ing.name}';
          if (!results.contains(desc)) {
            results.add(desc);
          }
        }
      }
    }
    return results;
  }

  /// Builds authentic, dish-specific cooking steps mentioning real ingredients and amounts.
  static List<CookingStep> buildStepsForDish({
    required String baseDish,
    required String category,
    required List<Ingredient> ingredients,
    required int prepTime,
    required int cookTime,
  }) {
    final lowerDish = baseDish.toLowerCase();
    final lowerCat = category.toLowerCase();

    // 1. GÜVEÇ & KURU BAKLİYAT (Kuru Fasulye, Etli Nohut, Güveç, Yahni)
    if (lowerDish.contains('fasulye') ||
        lowerDish.contains('nohut') ||
        lowerDish.contains('güveç') ||
        lowerDish.contains('yahni')) {
      final mainBean = _findIngredientText(ingredients, ['fasulye', 'nohut', 'barbunya'], baseDish);
      final onion = _findIngredientText(ingredients, ['soğan', 'sogan'], '1 adet Kuru Soğan');
      final garlic = _findIngredientText(ingredients, ['sarımsak', 'sarimsak'], '2 diş Sarımsak');
      final butter = _findIngredientText(ingredients, ['tereyağ', 'tereyagi'], '2 yemek kaşığı Tereyağı');
      final oil = _findIngredientText(ingredients, ['zeytinyağ', 'zeytinyagi'], '2 yemek kaşığı Zeytinyağı');
      final paste = _findIngredientText(ingredients, ['salça', 'domates'], '1 yemek kaşığı Domates Salçası');
      final meat = _findIngredientText(ingredients, ['et', 'kuşbaşı', 'kıyma', 'sucuk'], '');
      final spices = _findIngredientText(ingredients, ['pul biber', 'karabiber', 'tuz', 'baharat'], '1 tatlı kaşığı Pul Biber ve Tuz');

      return [
        CookingStep(
          order: 1,
          title: 'Bakliyat Süzme & Sebze Doğrama',
          instruction: 'Önceden ıslatılmış $mainBean\'yi soğuk suyla yıkayıp süzün. $onion ve $garlic\'ı yemeklik ince ince doğrayın.',
          toolIcon: 'knife',
          timerSeconds: 300,
          proTip: 'Kuru bakliyatları ıslatırken suya 1 çay kaşığı karbonat eklemek gazını alır ve pişerken kabuk atmasını engeller.',
          stepIngredients: _findIngredientList(ingredients, ['fasulye', 'nohut', 'barbunya', 'soğan', 'sarımsak']),
        ),
        CookingStep(
          order: 2,
          title: 'Salça ve Aromatikleri Kavurma',
          instruction: 'Tencerede $butter ve $oil\'nı ısıtın. Doğranmış soğanları pembeleşene kadar soteleyin. Ardından $paste\'nı ekleyip kokusu çıkana kadar 2 dakika kavurun.',
          toolIcon: 'pot',
          timerSeconds: 240,
          proTip: 'Salçayı kokusu çıkıp yağa rengini bırakana kadar kavurmak yemeğin ekşi olmasını önler ve zengin bir lezzet katar.',
          stepIngredients: _findIngredientList(ingredients, ['tereyağ', 'zeytinyağ', 'salça', 'domates']),
        ),
        CookingStep(
          order: 3,
          title: 'Malzemeleri Birleştirme ve Mühürleme',
          instruction: meat.isNotEmpty
              ? 'Tencereye $meat\'i ekleyip suyunu çekene kadar soteleyin. Ardından süzülen bakliyatları ve $spices\'ı ilave edip 2 dakika harmanlayın.'
              : 'Süzülen bakliyatları tencereye aktarın. $spices\'ı ekleyip tahta kaşıkla ezmeden 2 dakika nazikçe harmanlayın.',
          toolIcon: 'spoon',
          timerSeconds: 240,
          proTip: 'Fasulye ve nohutları yağda hafifçe çevirmek pişerken kabuklarının dağılmasını engeller.',
          stepIngredients: _findIngredientList(ingredients, ['et', 'kuşbaşı', 'kıyma', 'sucuk', 'pul biber', 'tuz', 'baharat']),
        ),
        CookingStep(
          order: 4,
          title: 'Ağır Ateşte Demleme & Pişirme',
          instruction: 'Tencereye üzerini 2-3 parmak geçecek şekilde yaklaşık 4-5 su bardağı kaynar su veya kemik suyu dökün. Kapağını kapatıp kısık ateşte bakliyatlar lokum gibi yumuşayıp helmelenene kadar yaklaşık $cookTime dakika pişirin.',
          toolIcon: 'pot',
          timerSeconds: cookTime * 60,
          proTip: 'Yemek pişerken suyunu çekerse mutlaka kaynar su ekleyin; soğuk su eklerseniz bakliyatlar anında sertleşir.',
          stepIngredients: const ['4-5 su bardağı Kaynar Su veya Kemik Suyu'],
        ),
        CookingStep(
          order: 5,
          title: 'Dinlendirme ve Pilav Yanında Sunum',
          instruction: 'Ocaktan aldığınız yemeğin kapağını açmadan 15 dakika dinlendirin. Yanında tane tane tereyağlı pirinç pilavı ve turşu ile sıcak servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 900,
          proTip: 'Dinlenen bakliyat yemeğinin sosu koyulaşır ve tüm aromatik lezzetler birbirine tam olarak geçer.',
          stepIngredients: const [],
        ),
      ];
    }

    // 2. DOLMALAR & KARNIYARIK & İMAM BAYILDI (Patlıcan, Biber, Dolma)
    if (lowerDish.contains('karnıyarık') ||
        lowerDish.contains('karniyarik') ||
        lowerDish.contains('imam bayıldı') ||
        lowerDish.contains('dolma') ||
        lowerDish.contains('sarma') ||
        lowerDish.contains('ratatouille')) {
      final veg = _findIngredientText(ingredients, ['patlıcan', 'patlican', 'biber', 'kabak'], 'Kemer Patlıcan');
      final meat = _findIngredientText(ingredients, ['kıyma', 'et', 'kuşbaşı'], 'Dana Kıyma');
      final onion = _findIngredientText(ingredients, ['soğan', 'sogan'], '1 adet Kuru Soğan');
      final tomato = _findIngredientText(ingredients, ['domates', 'salça'], 'Domates ve Salça');
      final spices = _findIngredientText(ingredients, ['tuz', 'baharat', 'karabiber', 'pul biber'], 'Tuz ve Karabiber');

      return [
        CookingStep(
          order: 1,
          title: 'Sebzeleri Hazırlama & Alacalı Soyma',
          instruction: '$veg\'leri yıkayıp temizleyin. Patlıcanları alacalı soyup acısının çıkması için 15 dakika tuzlu suda bekletin, ardından kurulayıp kızgın yağda veya fırında yumuşayana kadar çevirin.',
          toolIcon: 'knife',
          timerSeconds: 420,
          proTip: 'Patlıcanları kızartmadan önce havlu kağıtla iyice kurulamak aşırı yağ çekmelerini ve tencerede sıçramayı önler.',
          stepIngredients: _findIngredientList(ingredients, ['patlıcan', 'patlican', 'biber', 'kabak']),
        ),
        CookingStep(
          order: 2,
          title: 'Nefis İç Harcı Pişirme',
          instruction: 'Tavada zeytinyağında doğranmış $onion ve sarımsakları kavurun. $meat\'i ekleyip suyunu salıp çekene kadar soteleyin. Ardından küp küp $tomato ve $spices\'ı ekleyip 5 dakika pişirin.',
          toolIcon: 'pan',
          timerSeconds: 480,
          proTip: 'Kıymalı harca ocaktan alırken ince kıyılmış taze maydanoz eklemek ferah ve dengeli bir aroma sağlar.',
          stepIngredients: _findIngredientList(ingredients, ['kıyma', 'et', 'soğan', 'domates', 'salça', 'baharat', 'tuz']),
        ),
        CookingStep(
          order: 3,
          title: 'Sebzeleri Doldurma ve Dizme',
          instruction: 'Fırın tepsisine dizilen sebzelerin ortasını boydan yarıp kaşıkla genişletin. Hazırladığınız bol lezzetli iç harcı içlerine cömertçe doldurun. Üzerlerine domates ve biber dilimleri yerleştirin.',
          toolIcon: 'spoon',
          timerSeconds: 300,
          proTip: 'Harcı sebzenin içine fazla bastırmadan koyun, böylece pişerken fırındaki lezzetli sosu içine çeker.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 4,
          title: 'Salçalı Sos & Fırınlama',
          instruction: '1 yemek kaşığı salçayı 1.5 su bardağı sıcak su ve tuzla çırpıp tepsinin tabanına gezdirin. 190°C fırında sebzeler lokum gibi yumuşayıp üzeri nar gibi kızarana kadar yaklaşık $cookTime dakika pişirin.',
          toolIcon: 'oven',
          timerSeconds: cookTime * 60,
          proTip: 'Tepsinin üzerini ilk 15 dakika yağlı kağıtla örtmek sebzelerin kurumasını önler, sonrasında açıp üzerini kızartın.',
          stepIngredients: const ['1 yemek kaşığı Salça', '1.5 su bardağı Sıcak Su'],
        ),
        CookingStep(
          order: 5,
          title: 'Dinlendirme ve Yoğurtla Sunum',
          instruction: 'Fırından çıkardıktan sonra 10 dakika kendi buharında dinlendirin. Yanında sarımsaklı süzme yoğurt veya pilav eşliğinde sıcak servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 600,
          proTip: 'Yemeğin ilk sıcağı çıktığında sebzeler dağılmadan rahatça servis edilir.',
          stepIngredients: const [],
        ),
      ];
    }

    // 3. FIRINDA ET, TAVUK & BALIK (Fırında Tavuk Pirzola, Somon, Çipura, İncik)
    if (lowerDish.contains('tavuk') ||
        lowerDish.contains('pirzola') ||
        lowerDish.contains('somon') ||
        lowerDish.contains('çipura') ||
        lowerDish.contains('cipura') ||
        lowerDish.contains('balık') ||
        lowerDish.contains('balik') ||
        lowerDish.contains('incik') ||
        lowerDish.contains('steak')) {
      final mainMeat = _findIngredientText(ingredients, ['tavuk', 'balık', 'balik', 'somon', 'çipura', 'incik', 'et'], baseDish);
      final yogurt = _findIngredientText(ingredients, ['yoğurt', 'yogurt'], '2 yemek kaşığı Yoğurt');
      final oil = _findIngredientText(ingredients, ['zeytinyağ', 'zeytinyagi'], '3 yemek kaşığı Zeytinyağı');
      final garlic = _findIngredientText(ingredients, ['sarımsak', 'sarimsak'], '2 diş Sarımsak');
      final garnish = _findIngredientText(ingredients, ['patates', 'biber', 'havuç', 'soğan'], 'Patates ve Biber');
      final spices = _findIngredientText(ingredients, ['kekik', 'pul biber', 'baharat', 'tuz'], 'Kekik, Pul Biber ve Tuz');

      return [
        CookingStep(
          order: 1,
          title: 'Özel Marinasyon Sosunun Hazırlanması',
          instruction: 'Geniş bir kapta $yogurt, $oil, ezilmiş $garlic, $spices\'ı çırpıcıyla pürüzsüz kıvama gelene kadar karıştırın.',
          toolIcon: 'whisk',
          timerSeconds: 300,
          proTip: 'Eti marine ederken yoğurt ve zeytinyağı asiditesi etin liflerini yumuşatır ve piştiğinde lokum gibi olmasını sağlar.',
          stepIngredients: _findIngredientList(ingredients, ['yoğurt', 'yogurt', 'zeytinyağ', 'sarımsak', 'baharat', 'tuz']),
        ),
        CookingStep(
          order: 2,
          title: 'Marine Etme & Dinlendirme',
          instruction: '$mainMeat parçalarını hazırladığınız sosa bulayın. İyice harmanlayıp lezzetlerin ete nüfuz etmesi için buzdolabında en az 20 dakika bekletin.',
          toolIcon: 'bowl',
          timerSeconds: 1200,
          proTip: 'Eti pişirmeden önce oda sıcaklığına getirin; soğuk et fırına girerse suyunu salar ve sertleşir.',
          stepIngredients: _findIngredientList(ingredients, ['tavuk', 'balık', 'balik', 'somon', 'çipura', 'incik', 'et']),
        ),
        CookingStep(
          order: 3,
          title: 'Tepsiye Dizme ve Sebzeleri Yerleştirme',
          instruction: 'Fırın tepsisine yağlı kağıt serin. Marine edilmiş etleri yerleştirin. Yanlarına elma dilim doğranmış $garnish\'leri dizin.',
          toolIcon: 'knife',
          timerSeconds: 300,
          proTip: 'Sebzeleri kalan marine sosuna bulayarak tepsiye koyarsanız sebzeler de aynı lezzeti kazanır.',
          stepIngredients: _findIngredientList(ingredients, ['patates', 'biber', 'havuç', 'soğan']),
        ),
        CookingStep(
          order: 4,
          title: 'Nar Gibi Fırınlama',
          instruction: 'Önceden 200°C\'ye ısıtılmış fırında etlerin üzeri altın sarısı nar gibi kızarıp içi sulu kalana kadar yaklaşık $cookTime dakika fırınlayın.',
          toolIcon: 'oven',
          timerSeconds: cookTime * 60,
          proTip: 'Fırının son 5 dakikasında üst ızgara modunu açarak derisinin çıtırlaşmasını sağlayabilirsiniz.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 5,
          title: 'Dinlendirme ve Sıcak Servis',
          instruction: 'Fırından çıkardıktan sonra üzerini alüminyum folyo ile gevşekçe kapatıp 5 dakika dinlendirin. Taze kekik ve limon dilimleriyle sıcak servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 300,
          proTip: 'Pişen eti dinlendirmek hapsolan et sularının liflere eşit dağılmasını sağlar.',
          stepIngredients: const [],
        ),
      ];
    }

    // 4. KÖFTELER, BURGERLER & KEBAPLAR (Kasap Köfte, Terbiyeli Köfte, Smash Burger, vb.)
    if (lowerDish.contains('köfte') ||
        lowerDish.contains('kofte') ||
        lowerDish.contains('burger') ||
        lowerDish.contains('kebap') ||
        lowerDish.contains('kebab') ||
        lowerDish.contains('taco') ||
        lowerDish.contains('fajita')) {
      final meat = _findIngredientText(ingredients, ['kıyma', 'et', 'kuşbaşı'], 'Dana Kıyma');
      final onion = _findIngredientText(ingredients, ['soğan', 'sogan'], '1 adet Kuru Soğan');
      final garlic = _findIngredientText(ingredients, ['sarımsak', 'sarimsak'], '2 diş Sarımsak');
      final egg = _findIngredientText(ingredients, ['yumurta'], '1 adet Yumurta');
      final spices = _findIngredientText(ingredients, ['kimyon', 'karabiber', 'tuz', 'baharat', 'pul biber'], 'Kimyon, Karabiber ve Tuz');

      return [
        CookingStep(
          order: 1,
          title: 'Harcı Yoğurma ve Baharatlama',
          instruction: 'Geniş bir kapta $meat, rendelenip suyu sıkılmış $onion, ezilmiş $garlic, $egg ve $spices\'ı birleştirin.',
          toolIcon: 'bowl',
          timerSeconds: 480,
          proTip: 'Harcı en az 8-10 dakika sakız kıvamına gelene kadar yoğurmak pişerken çatlamasını ve dağılmasını önler.',
          stepIngredients: _findIngredientList(ingredients, ['kıyma', 'et', 'soğan', 'sarımsak', 'yumurta', 'baharat', 'tuz']),
        ),
        CookingStep(
          order: 2,
          title: 'Porsiyonlama & Şekil Verme',
          instruction: 'Ellerinizi hafifçe ıslatarak harçtan ceviz büyüklüğünde parçalar koparıp yassı köfte veya burger formunda şekillendirin. Buzdolabında 20 dakika dinlendirin.',
          toolIcon: 'bowl',
          timerSeconds: 1200,
          proTip: 'Dinlenen köfteler pişerken şeklini mükemmel korur ve yağını tavaya bırakmaz.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 3,
          title: 'Döküm Tavada / Izgarada Mühürleme',
          instruction: 'Döküm tavayı yüksek ateşte iyice kızdırın. Köfteleri tavaya bırakıp her iki yüzünü de 3-4\'er dakika suyunu kaybetmeden mühürleyerek pişirin.',
          toolIcon: 'pan',
          timerSeconds: cookTime * 60,
          proTip: 'Köfteleri tavada pişirirken spatulayla üzerlerine asla bastırmayın; lezzetli et suyu tavanın içine akar.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 4,
          title: 'Garnitür ve Sıcak Servis',
          instruction: 'Kızaran köfteleri közlenmiş domates, biber ve sumaklı soğan salatası eşliğinde sıcak sıcak lavaş veya pide üstünde servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 180,
          proTip: 'Sıcak köftelerin üzerine servis anında tırnak kadar tereyağı bırakmak lezzeti zirveye taşır.',
          stepIngredients: const [],
        ),
      ];
    }

    // 5. ÇORBALAR (Mercimek, Ezogelin, Yayla, Mantar, Tarhana, vb.)
    if (lowerCat == 'çorba' || lowerCat == 'corba' || lowerDish.contains('çorba') || lowerDish.contains('corba')) {
      final mainGrain = _findIngredientText(ingredients, ['mercimek', 'pirinç', 'bulgur', 'mantar', 'tarhana'], baseDish);
      final onion = _findIngredientText(ingredients, ['soğan', 'sogan'], '1 adet Kuru Soğan');
      final carrot = _findIngredientText(ingredients, ['havuç', 'patates'], '1 adet Havuç');
      final butter = _findIngredientText(ingredients, ['tereyağ', 'tereyagi'], '2 yemek kaşığı Tereyağı');
      final oil = _findIngredientText(ingredients, ['zeytinyağ', 'zeytinyagi'], '2 yemek kaşığı Zeytinyağı');
      final spices = _findIngredientText(ingredients, ['nane', 'pul biber', 'tuz', 'baharat'], 'Kuru Nane, Pul Biber ve Tuz');

      return [
        CookingStep(
          order: 1,
          title: 'Bakliyat Süzme ve Sebze Doğrama',
          instruction: '$mainGrain\'ı bol suyla yıkayıp süzün. $onion ve $carrot\'u iri küpler halinde doğrayın.',
          toolIcon: 'knife',
          timerSeconds: 300,
          stepIngredients: _findIngredientList(ingredients, ['mercimek', 'pirinç', 'bulgur', 'mantar', 'tarhana', 'soğan', 'havuç', 'patates']),
        ),
        CookingStep(
          order: 2,
          title: 'Aromatikleri ve Unu Kavurma',
          instruction: 'Çorba tenceresinde $butter ve $oil\'nı ısıtın. Doğranmış soğan ve havuçları 3 dakika soteleyin. Varsa 1 yemek kaşığı un ekleyip kokusu çıkana kadar kavurun.',
          toolIcon: 'pot',
          timerSeconds: 240,
          proTip: 'Unu tereyağında hafifçe kavurmak çorbaya kadife gibi ipeksi bir kıvam ve lezzetli bir fındık aroması kazandırır.',
          stepIngredients: _findIngredientList(ingredients, ['tereyağ', 'zeytinyağ', 'un', 'soğan']),
        ),
        CookingStep(
          order: 3,
          title: 'Kaynatma ve Yumuşatma',
          instruction: 'Yıkanmış bakliyatı, 6 su bardağı sıcak suyu (veya kemik suyunu) ve tuzu tencereye ekleyin. Kaynadıktan sonra kısık ateşte malzemeler dağılana kadar yaklaşık $cookTime dakika pişirin.',
          toolIcon: 'pot',
          timerSeconds: cookTime * 60,
          stepIngredients: _findIngredientList(ingredients, ['tuz', 'baharat']),
        ),
        CookingStep(
          order: 4,
          title: 'Pürüzsüzleştirme (Blender)',
          instruction: 'Pişen çorbayı el blenderı ile tamamen pürüzsüz, ipeksi bir kıvam alana kadar çekin. Kıvamı koyu olursa yarım su bardağı kaynar su ilave edin.',
          toolIcon: 'pot',
          timerSeconds: 180,
          proTip: 'Blenderdan geçirdikten sonra 2 dakika daha kısık ateşte kaynatmak hava kabarcıklarını yok eder ve kıvamı oturtur.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 5,
          title: 'Tereyağlı Sos ve Limonla Sunum',
          instruction: 'Küçük bir tavada 1 yemek kaşığı tereyağında $spices\'ı kızdırıp köpürtün. Çorbanın üzerine cızırdatarak gezdirin ve taze limon dilimiyle servis yapın.',
          toolIcon: 'pan',
          timerSeconds: 120,
          stepIngredients: _findIngredientList(ingredients, ['tereyağ', 'nane', 'pul biber', 'limon']),
        ),
      ];
    }

    // 6. KAHVALTILIKLAR (Menemen, Sucuklu Yumurta, Mıhlama, Omlet, Shakshuka)
    if (lowerCat == 'kahvaltılık' || lowerCat == 'kahvaltilik' || lowerDish.contains('menemen') || lowerDish.contains('yumurta') || lowerDish.contains('omlet')) {
      final pepper = _findIngredientText(ingredients, ['biber', 'yeşil biber'], '2 adet Yeşil Biber');
      final tomato = _findIngredientText(ingredients, ['domates'], '2 adet Domates');
      final butter = _findIngredientText(ingredients, ['tereyağ', 'tereyagi'], '2 yemek kaşığı Tereyağı');
      final eggs = _findIngredientText(ingredients, ['yumurta'], '2 adet Yumurta');
      final cheese = _findIngredientText(ingredients, ['peynir', 'kaşar'], 'Rendelenmiş Kaşar Peyniri');

      return [
        CookingStep(
          order: 1,
          title: 'Tavayı Isıtma & Sebze Doğrama',
          instruction: '$pepper ve $tomato\'i ince ince doğrayın. Tavada $butter\'nı orta ateşte eritin.',
          toolIcon: 'knife',
          timerSeconds: 180,
          stepIngredients: _findIngredientList(ingredients, ['biber', 'domates', 'tereyağ']),
        ),
        CookingStep(
          order: 2,
          title: 'Biberleri Soteleme',
          instruction: 'Eriyen tereyağına doğranmış biberleri ekleyip orta ateşte kokusu çıkıp yumuşayana kadar 3 dakika soteleyin.',
          toolIcon: 'pan',
          timerSeconds: 200,
          proTip: 'Biberleri yakmadan sadece yumuşayana kadar kavurmak menemenin tatlı lezzetini korur.',
          stepIngredients: _findIngredientList(ingredients, ['biber', 'sucuk']),
        ),
        CookingStep(
          order: 3,
          title: 'Domatesleri Pişirip Suyunu Çektirme',
          instruction: 'Doğranmış domatesleri ve 1 çay kaşığı tuzu tavaya ekleyin. Kapağını kapatıp domatesler suyunu salıp çekene kadar yaklaşık $cookTime dakika kısık ateşte pişirin.',
          toolIcon: 'pan',
          timerSeconds: (cookTime * 60 * 0.6).round(),
          stepIngredients: _findIngredientList(ingredients, ['domates', 'tuz', 'baharat']),
        ),
        CookingStep(
          order: 4,
          title: 'Yumurtaları Kırma & Pişirme',
          instruction: 'Tavada boşluklar açıp $eggs\'yı kırın. Beyazları domates sosuyla hafifçe karıştırıp sarılarını tercihinize göre sulu bırakın veya hafifçe dağıtın.',
          toolIcon: 'spoon',
          timerSeconds: 180,
          proTip: 'Yumurtanın beyazı matlaştığı anda ocağı kapatın; tavanın kendi sıcaklığı sarısını mükemmel kıvama getirecektir.',
          stepIngredients: _findIngredientList(ingredients, ['yumurta', 'peynir']),
        ),
        CookingStep(
          order: 5,
          title: 'Tavada Sıcak Servis',
          instruction: 'Üzerine taze kekik veya rendelenmiş $cheese serpip çıtır ekmek eşliğinde tavasıyla doğrudan sıcak servis yapın.',
          toolIcon: 'pan',
          timerSeconds: 60,
          stepIngredients: const [],
        ),
      ];
    }

    // 7. TATLILAR (Sütlaç, Kazandibi, İrmik Helvası, Revani, Kekler, vb.)
    if (lowerCat == 'tatlı' || lowerCat == 'tatli') {
      final milk = _findIngredientText(ingredients, ['süt', 'sut'], '1 litre Süt');
      final sugar = _findIngredientText(ingredients, ['şeker', 'seker'], '1 su bardağı Toz Şeker');
      final flour = _findIngredientText(ingredients, ['un', 'irmik', 'kakao'], 'Un veya İrmik');
      final eggs = _findIngredientText(ingredients, ['yumurta'], '1 adet Yumurta');
      final butter = _findIngredientText(ingredients, ['tereyağ', 'tereyagi'], '2 yemek kaşığı Tereyağı');
      final nuts = _findIngredientText(ingredients, ['ceviz', 'fıstık', 'badem'], 'Dövülmüş Ceviz / Fıstık');

      return [
        CookingStep(
          order: 1,
          title: 'Kuru ve Sıvı Malzemeleri Hazırlama',
          instruction: 'Fırını 180°C\'ye ayarlayın. Geniş bir karıştırma kabında $eggs ve $sugar\'i mikserle beyazlaşıp köpük köpük olana kadar çırpın.',
          toolIcon: 'whisk',
          timerSeconds: 300,
          proTip: 'Yumurta ve süt mutlaka oda sıcaklığında olmalıdır; soğuk malzemeler tatlının kabarmasını ve lezzetini olumsuz etkiler.',
          stepIngredients: _findIngredientList(ingredients, ['yumurta', 'şeker', 'seker']),
        ),
        CookingStep(
          order: 2,
          title: 'Süt ve Aromaları Ekleyip Kıvam Alma',
          instruction: '$milk, $flour, $butter ve vanilyayı ilave ederek spatula ile alttan üste doğru homojen olana kadar karıştırın.',
          toolIcon: 'spoon',
          timerSeconds: 240,
          stepIngredients: _findIngredientList(ingredients, ['süt', 'sut', 'un', 'irmik', 'kakao', 'tereyağ']),
        ),
        CookingStep(
          order: 3,
          title: 'Kalıba / Güveçlere Aktarma',
          instruction: 'Karışımı yağlanmış fırın tepsisine veya toprak güveç kaplarına dökün. Sütlaç ise güveçleri fırın tepsisine dizip tepsiye 2 parmak soğuk su ekleyin.',
          toolIcon: 'bowl',
          timerSeconds: 180,
          proTip: 'Fırın tepsisine su eklemek tatlının tabanının yanmasını önler ve üstünün eşit kızarmasını sağlar.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 4,
          title: 'Fırınlama / Pişirme',
          instruction: 'Önceden ısıtılmış fırında veya ocakta üzeri altın sarısı nar gibi kızarana kadar yaklaşık $cookTime dakika pişirin.',
          toolIcon: 'oven',
          timerSeconds: cookTime * 60,
          proTip: 'Fırının son dakikalarında üst ızgarayı açarak tatlının üzerinin hafif yanık karamelize bir lezzet almasını sağlayabilirsiniz.',
          stepIngredients: const [],
        ),
        CookingStep(
          order: 5,
          title: 'Dinlendirme, Süsleme ve Servis',
          instruction: 'Oda sıcaklığında 15 dakika dinlendirip ardından buzdolabında soğutun. Üzerine $nuts ve tarçın serpip soğuk servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 900,
          stepIngredients: _findIngredientList(ingredients, ['ceviz', 'fıstık', 'badem']),
        ),
      ];
    }

    // 8. HAMUR İŞLERİ (Börek, Poğaça, Lahmacun, Pide, Bazlama, Simit)
    if (lowerCat == 'hamur işi' || lowerCat == 'hamur isi' || lowerDish.contains('börek') || lowerDish.contains('pide') || lowerDish.contains('lahmacun')) {
      final flour = _findIngredientText(ingredients, ['un'], '3 su bardağı Un');
      final milk = _findIngredientText(ingredients, ['süt', 'sut', 'su'], '1 su bardağı Ilık Süt');
      final oil = _findIngredientText(ingredients, ['zeytinyağ', 'tereyağ'], 'Sıvı Yağ');
      final filling = _findIngredientText(ingredients, ['peynir', 'kıyma', 'patates', 'ıspanak'], 'Peynirli / Kıymalı Harç');
      final eggs = _findIngredientText(ingredients, ['yumurta'], '1 adet Yumurta Sarısı');

      return [
        CookingStep(
          order: 1,
          title: 'Hamuru Yoğurma ve Mayalama',
          instruction: 'Yoğurma kabında $milk, $flour, $oil, maya ve tuzu karıştırıp ele yapışmayan yumuşak bir hamur yoğurun. Üzerini kapatıp 35 dakika mayalanmaya bırakın.',
          toolIcon: 'bowl',
          timerSeconds: 2100,
          proTip: 'Kullandığınız sıvının el yakmayacak ılıklıkta olması gerekir; çok sıcak sıvı mayayı öldürür, soğuk sıvı mayalanmayı geciktirir.',
          stepIngredients: _findIngredientList(ingredients, ['un', 'süt', 'sut', 'zeytinyağ', 'tereyağ', 'tuz']),
        ),
        CookingStep(
          order: 2,
          title: 'Nefis İç Harcı Hazırlama',
          instruction: 'Ayrı bir kapta $filling ve baharatları harmanlayıp iç harcı hazır hale getirin.',
          toolIcon: 'bowl',
          timerSeconds: 300,
          stepIngredients: _findIngredientList(ingredients, ['peynir', 'kıyma', 'patates', 'ıspanak', 'soğan', 'baharat']),
        ),
        CookingStep(
          order: 3,
          title: 'Açma, Doldurma ve Şekil Verme',
          instruction: 'Mayalanan hamurdan bezeler koparın. Tezgaha un serpip merdane ile açın. Hazırladığınız iç harcı paylaştırıp rulo veya pide şeklinde kapatın.',
          toolIcon: 'knife',
          timerSeconds: 360,
          stepIngredients: const [],
        ),
        CookingStep(
          order: 4,
          title: 'Fırınlama',
          instruction: 'Tepsiye dizip üzerine $eggs sürün ve susam serpin. 190°C fırında üzeri altın sarısı olana kadar yaklaşık $cookTime dakika pişirin.',
          toolIcon: 'oven',
          timerSeconds: cookTime * 60,
          proTip: 'Fırından çıkarmadan önce üzerine fırça ile birkaç damla eritilmiş tereyağı sürmek kabuğunun yumuşacık kalmasını sağlar.',
          stepIngredients: _findIngredientList(ingredients, ['yumurta']),
        ),
        CookingStep(
          order: 5,
          title: 'Dinlendirme ve Dilimleme',
          instruction: 'Fırından çıktıktan sonra üzerini temiz bir bezle örtüp 5 dakika dinlendirin. Dilimleyerek yanında sıcak çay ile servis yapın.',
          toolIcon: 'plate',
          timerSeconds: 300,
          stepIngredients: const [],
        ),
      ];
    }

    // 9. SALATALAR & KASELER (Çoban, Gavurdağı, Grek, Sezar, vb.)
    if (lowerCat == 'salata' || lowerDish.contains('salata') || lowerDish.contains('piyaz')) {
      final greens = _findIngredientText(ingredients, ['domates', 'biber', 'salatalık', 'yeşillik', 'roka'], 'Taze Sebzeler ve Yeşillikler');
      final oil = _findIngredientText(ingredients, ['zeytinyağ', 'zeytinyagi'], '3 yemek kaşığı Sızma Zeytinyağı');
      final lemon = _findIngredientText(ingredients, ['limon'], '1 adet Taze Limon Suyu');
      final toppings = _findIngredientText(ingredients, ['peynir', 'ceviz', 'ton balığı'], 'Peynir veya Ceviz');

      return [
        CookingStep(
          order: 1,
          title: 'Sebzeleri Yıkama & Kurulama',
          instruction: 'Tüm $greens\'i sirkeli bol suda yıkayıp tamamen kurulayın.',
          toolIcon: 'bowl',
          timerSeconds: 300,
          proTip: 'Yeşilliklerin tamamen kuru olması sosun yaprakların üzerine eşit tutunması için en önemli adımdır.',
          stepIngredients: _findIngredientList(ingredients, ['domates', 'biber', 'yeşillik', 'roka']),
        ),
        CookingStep(
          order: 2,
          title: 'Usta İşi Doğrama',
          instruction: 'Sebzeleri salatanın karakterine göre (küp küp veya ince jülyen) keskin bir bıçakla ezmeden doğrayın.',
          toolIcon: 'knife',
          timerSeconds: 300,
          stepIngredients: _findIngredientList(ingredients, ['domates', 'biber', 'soğan', 'avokado', 'salatalık']),
        ),
        CookingStep(
          order: 3,
          title: 'Özel Emülsiyon Sosu Hazırlama',
          instruction: 'Küçük bir kasede $oil, $lemon, tuz ve baharatları çırpıcıyla koyulaşana kadar hızlıca çırpın.',
          toolIcon: 'whisk',
          timerSeconds: 180,
          stepIngredients: _findIngredientList(ingredients, ['zeytinyağ', 'limon', 'tuz', 'baharat']),
        ),
        CookingStep(
          order: 4,
          title: 'Harmanlama & Üst Malzemeler',
          instruction: 'Doğranmış sebzeleri kaseye alın. Hazırladığınız sosu üzerine döküp hafifçe harmanlayın. Üzerine $toppings serpiştirin.',
          toolIcon: 'bowl',
          timerSeconds: 120,
          stepIngredients: _findIngredientList(ingredients, ['peynir', 'ceviz', 'ton balığı']),
        ),
        CookingStep(
          order: 5,
          title: 'Şık Sunum',
          instruction: 'Salatayı servis tabağına alıp bekletmeden taze olarak servis edin.',
          toolIcon: 'plate',
          timerSeconds: 60,
          stepIngredients: const [],
        ),
      ];
    }

    // 10. PRATİK YEMEKLER, MAKARNALAR & DÜNYA MUTFAKLARI
    final mainFood = _findIngredientText(ingredients, ['makarna', 'noodle', 'tavuk', 'kıyma', 'mantar'], baseDish);
    final sauceVeg = _findIngredientText(ingredients, ['sarımsak', 'soğan', 'domates', 'biber'], 'Sarımsak ve Domates');
    final oil = _findIngredientText(ingredients, ['zeytinyağ', 'tereyağ'], 'Zeytinyağı');
    final cheese = _findIngredientText(ingredients, ['peynir', 'kaşar'], 'Rende Kaşar Peyniri');

    return [
      CookingStep(
        order: 1,
        title: 'Ön Hazırlık & Su Kaynatma',
        instruction: 'Tencereye bol su koyup kaynatın ve 1 tatlı kaşığı tuz ekleyin. Sos için $sauceVeg\'leri ince ince doğrayın.',
        toolIcon: 'knife',
        timerSeconds: 240,
        stepIngredients: _findIngredientList(ingredients, ['sarımsak', 'soğan', 'domates', 'biber']),
      ),
      CookingStep(
        order: 2,
        title: 'Haşlama / Ön Pişirme',
        instruction: 'Kaynayan suya ana malzemeyi ekleyin. Dişe gelir "al dente" kıvamda yaklaşık ${(cookTime * 0.5).round()} dakika haşlayın.',
        toolIcon: 'pot',
        timerSeconds: (cookTime * 60 * 0.5).round(),
        proTip: 'Haşlama suyundan yarım kepçe ayırın; nişastalı su sosun yemeğe yapışmasını ve kremsi olmasını sağlar.',
        stepIngredients: const [],
      ),
      CookingStep(
        order: 3,
        title: 'Sos ve Mühürleme',
        instruction: 'Geniş bir tavada $oil\'nda sarımsak ve $mainFood\'i yüksek ateşte soteleyin. Ardından sosunu ekleyip harmanlayın.',
        toolIcon: 'pan',
        timerSeconds: 300,
        stepIngredients: _findIngredientList(ingredients, ['zeytinyağ', 'tereyağ', 'tavuk', 'kıyma', 'mantar', 'sarımsak']),
      ),
      CookingStep(
        order: 4,
        title: 'Tavada Birleştirme & Mantolama',
        instruction: 'Süzülen malzemeyi tavaya aktarın. Yüksek ateşte sosla birlikte 2 dakika hızlıca çevirerek mantolayın.',
        toolIcon: 'pan',
        timerSeconds: 150,
        proTip: 'Mantolama işlemi sosun malzemenin her tarafına kusursuz yapışmasını ve lezzet patlaması yaşatmasını sağlar.',
        stepIngredients: const [],
      ),
      CookingStep(
        order: 5,
        title: 'Peynir ve Baharatla Sıcak Servis',
        instruction: 'Tabağa alıp üzerine rendelenmiş $cheese ve baharat serpip sıcak sıcak servis yapın.',
        toolIcon: 'plate',
        timerSeconds: 60,
        stepIngredients: _findIngredientList(ingredients, ['peynir', 'baharat']),
      ),
    ];
  }
}
