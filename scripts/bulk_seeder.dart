// ignore_for_file: avoid_print
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arewecookin/firebase_options.dart';
import 'package:arewecookin/models/models.dart';

/// Bulk Recipe Generator & Firestore Seeder for 10,000+ Recipes.
/// Handles Firestore WriteBatch constraints (max 500 writes per batch).
class BulkRecipeSeeder {
  static const int batchLimit = 500;

  final FirebaseFirestore? firestore;

  BulkRecipeSeeder({this.firestore});

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
    ],
    'Tatlı': [
      'Fırın Sütlaç', 'Kakaolu Islak Kek', 'Geleneksel Kazandibi', 'Tereyağlı İrmik Helvası',
      'Şekerpare', 'Çilekli Magnolia', 'Cevizli Revani', 'Çikolatalı Supangle',
      'Karamelli Trileçe', 'Havuçlu Tarçınlı Kek', 'Saray Muhallebisi', 'Profiterol',
      'Baklava Dilimli Revani', 'Limonlu Cheesecake', 'Mozaik Pasta', 'Vişneli Ekmek Kadayıfı',
    ],
    'Çorba': [
      'Süzme Kırmızı Mercimek', 'Geleneksel Ezogelin', 'Naneli Yayla Çorbası',
      'Kremalı Dağ Mantarı', 'Terbiyeli Tavuk Çorbası', 'Ev Yapımı Tarhana',
      'Fesleğenli Domates Çorbası', 'Düğün Çorbası', 'Sebzeli Minestrone', 'Kelle Paça Usulü Çorba',
      'Arpa Şehriyeli Çorba', 'Köz Kırmızı Biber Çorbası',
    ],
    'Kahvaltılık': [
      'Geleneksel Menemen', 'Kayseri Sucuklu Yumurta', 'Kaşarlı Peynirli Krep',
      'Patatesli Köy Omleti', 'Karadeniz Mıhlaması', 'Fırında Yumurtalı Kaşarlı Ekmek',
      'Peynirli Sigara Böreği', 'Yulaflı Pankek', 'Çılbır (Yoğurtlu Poşe Yumurta)',
      'Simit & Kaşar Tostu', 'Zeytin Ezmeli Bruschetta', 'Avokadolu Poşe Yumurta',
    ],
    'Pratik': [
      'Sarımsaklı Domatesli Makarna', 'Tavuklu Fajita Wrap', 'Ton Balıklı Akdeniz Sandviç',
      'Soya Soslu Sebzeli Noodle', '5 Dakikalık Peynirli Quesadilla', 'Fırında Baharatlı Elma Dilim Patates',
      'Kremalı Tavuklu Penne', 'Mug Cake (Fincanda Kek)', 'Köz Sebzeli Lavaş Dürüm',
      'Fasulye Piyazı Sandviç', 'Kremalı Mantarlı Ekmek Üstü', 'Pratik Tavada Pizza',
    ],
    'Hamur İşi': [
      'Peynirli Tepsi Böreği', 'Mayasız Puf Poğaça', 'Kıymalı Kol Böreği',
      'Taş Fırın Bazlama', 'Susamlı Çıtır Simit', 'Gözleme (Ispanaklı Peynirli)',
      'Ev Yapımı Fındık Lahmacun', 'Zeytinli Açma', 'Kıymalı Pide', 'Karaköy Poğaçası',
      'Otlu Çörek', 'Kuru Mayalı Peynirli Pide',
    ],
    'Salata': [
      'Geleneksel Çoban Salatası', 'Cevizli Gavurdağı Salatası', 'Akdeniz Yeşillikleri Salatası',
      'Roka & Parmesan Salatası', 'Antalya Usulü Tahinli Piyaz', 'Kinoa & Avokado Salatası',
      'Hellim Peynirli Yeşil Salata', 'Fırın Pancar & Keçi Peynirli Salata', 'Semizotu & Yoğurt Salatası',
      'Köz Patlıcan Salatası', 'Tavuklu Sezar Salata', 'Tabule (Bulgur Salatası)',
    ],
    'Vegan': [
      'Kıtır Nohutlu Mercimek Bowl', 'Zeytinyağlı Enginar Kalbi', 'Fırında Baharatlı Karnabahar Steak',
      'Tahinli Humus & Fırın Sebzeler', 'Geleneksel Mercimek Köftesi', 'Mantarlı Tofu Sote',
      'Fıstık Soslu Sebze Yahnisi', 'Falafel Tabağı', 'Fırın Tatlı Patates Dolması',
      'Zeytinyağlı Kereviz', 'Közlenmiş Sebze Güveci', 'Buharda Edamame & Pirinç',
    ],
  };

  static const List<String> titleAdjectives = [
    'Özel', 'Pratik', 'Fırında', 'Geleneksel', 'Acemi Dostu', 'Hızlı',
    'Hafif', 'Köy Usulü', 'Bol Baharatlı', 'Kremalı', 'Anne Eli Değmiş',
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
      'instruction': 'Yemeği ocaktan aldıktan sonra kapağı kapalı olarak 5-10 dakika dinlendirin, taze otlarla süsleyerek sıcak servis yapın.',
      'toolIcon': 'bowl',
      'timerSeconds': 300,
      'proTip': 'Pişen et ve yemekleri dinlendirmek suların eşit dağılmasını ve lezzetin derinleşmesini sağlar.',
    },
  ];

  /// Generates a single deterministic or pseudo-random Recipe at index [index].
  Recipe generateRecipe(int index) {
    final category = categories[index % categories.length];
    final baseDishes = categoryDishBases[category]!;
    final baseDish = baseDishes[(index ~/ categories.length) % baseDishes.length];
    final adjective = titleAdjectives[(index * 7) % titleAdjectives.length];
    final recipeNumber = index + 1;

    final title = '$adjective $baseDish #$recipeNumber';
    final prepTime = 5 + ((index * 3) % 40);
    final cookTime = 10 + ((index * 7) % 75);
    final difficulty = difficulties[(index + (index ~/ 3)) % difficulties.length];

    // Pick 3-6 ingredient keys depending on recipe type
    final List<String> selectedKeys = _pickIngredientKeysForCategory(category, index);

    final List<Ingredient> ingredients = [];
    for (final key in selectedKeys) {
      final pool = ingredientPool[key] ?? [
        Ingredient(name: key[0].toUpperCase() + key.substring(1), amount: '1', unit: 'porsiyon')
      ];
      final ingredientVariant = pool[index % pool.length];
      ingredients.add(ingredientVariant);
    }

    // Pick 1-2 applicable substitutions
    final List<Substitution> substitutions = [];
    for (final sub in commonSubstitutions) {
      if (selectedKeys.contains(sub.ingredient)) {
        substitutions.add(sub);
      }
    }

    // Select 3 to 4 cooking steps
    final List<CookingStep> steps = [];
    final stepIndices = [0, 2, 4, 6];
    if (category == 'Tatlı' || category == 'Kahvaltılık') {
      stepIndices[1] = 5; // whisk
    }
    for (int i = 0; i < stepIndices.length; i++) {
      final template = stepTemplates[stepIndices[i]];
      steps.add(
        CookingStep(
          order: i + 1,
          title: template['title'] as String,
          instruction: template['instruction'] as String,
          toolIcon: template['toolIcon'] as String,
          timerSeconds: template['timerSeconds'] as int,
          proTip: template['proTip'] as String,
        ),
      );
    }

    return Recipe(
      id: 'rec_${recipeNumber.toString().padLeft(5, '0')}',
      title: title,
      category: category,
      prepTime: prepTime,
      cookTime: cookTime,
      difficulty: difficulty,
      ingredientKeys: selectedKeys,
      ingredients: ingredients,
      substitutions: substitutions,
      steps: steps,
      servings: 2 + (index % 4) * 2,
    );
  }

  List<String> _pickIngredientKeysForCategory(String category, int seed) {
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
        return ['nohut' == 'nohut' ? 'mercimek' : 'patates', 'zeytinyagi', 'sarimsak', 'sogan', 'domates'];
      default:
        return ['un', 'tuz', 'zeytinyagi'];
    }
  }

  /// Bulk seed recipes in batches of max 500.
  /// If [dryRun] is true, it does not contact Firestore but tests batch slicing and generation.
  Future<int> seedRecipes({
    int totalCount = 10000,
    int chunkSize = batchLimit,
    bool dryRun = false,
    void Function(int processed, int total)? onProgress,
  }) async {
    assert(chunkSize <= 500, 'Firestore WriteBatch supports a maximum of 500 operations.');

    int totalCommitted = 0;

    for (int batchStart = 0; batchStart < totalCount; batchStart += chunkSize) {
      final batchEnd = min(batchStart + chunkSize, totalCount);
      final currentChunkLength = batchEnd - batchStart;

      if (dryRun) {
        for (int i = batchStart; i < batchEnd; i++) {
          final recipe = generateRecipe(i);
          assert(recipe.id.isNotEmpty);
          assert(recipe.title.isNotEmpty);
          assert(recipe.ingredientKeys.isNotEmpty);
        }
      } else {
        if (firestore == null) {
          throw StateError('FirebaseFirestore instance must be provided when dryRun is false.');
        }

        WriteBatch batch = firestore!.batch();
        for (int i = batchStart; i < batchEnd; i++) {
          final recipe = generateRecipe(i);
          final docRef = firestore!.collection('recipes').doc(recipe.id);
          batch.set(docRef, recipe.toMap());
        }
        await batch.commit();
      }

      totalCommitted += currentChunkLength;
      onProgress?.call(totalCommitted, totalCount);
    }

    return totalCommitted;
  }
}

Future<void> main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');
  final countArg = args.firstWhere((a) => a.startsWith('--count='), orElse: () => '--count=10000');
  final totalCount = int.tryParse(countArg.split('=').last) ?? 10000;

  print('=== AreWeCookin Bulk Recipe Seeder ===');
  print('Target recipes: $totalCount');
  print('Dry run mode: $isDryRun');
  print('Batch size: ${BulkRecipeSeeder.batchLimit} (Firestore max constraint)');

  FirebaseFirestore? firestore;
  if (!isDryRun) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firestore = FirebaseFirestore.instance;
  }

  final seeder = BulkRecipeSeeder(firestore: firestore);
  final stopwatch = Stopwatch()..start();

  final written = await seeder.seedRecipes(
    totalCount: totalCount,
    dryRun: isDryRun,
    onProgress: (done, total) {
      final pct = (done / total * 100).toStringAsFixed(1);
      print('Progress: $done / $total ($pct%) in ${stopwatch.elapsedMilliseconds}ms');
    },
  );

  stopwatch.stop();
  print('Successfully processed $written recipes in ${stopwatch.elapsed.inSeconds} seconds.');
}
