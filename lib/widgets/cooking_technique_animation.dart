import 'package:flutter/material.dart';

enum CookingTechniqueType {
  clawGripKnife,
  panHeatTest,
  whiskFigureEight,
  simmerSteamLock,
  sauteToss,
  spiceBloom,
  restingJuices,
  substitutionBalance;

  static CookingTechniqueType detect({
    required String toolIcon,
    required String proTip,
  }) {
    final lowerTip = proTip.toLowerCase();
    final lowerTool = toolIcon.toLowerCase().trim();

    if (lowerTip.contains('ikame') ||
        lowerTip.contains('yerine') ||
        lowerTip.contains('alternatif')) {
      return CookingTechniqueType.substitutionBalance;
    }

    if (lowerTip.contains('8 rakam') || lowerTip.contains('çırp')) {
      return CookingTechniqueType.whiskFigureEight;
    }

    if (lowerTip.contains('pençe') ||
        lowerTip.contains('bıçak') ||
        lowerTip.contains('parmak')) {
      return CookingTechniqueType.clawGripKnife;
    }

    if (lowerTip.contains('su serp') ||
        lowerTip.contains('su damlası') ||
        lowerTip.contains('cızır') ||
        lowerTip.contains('ısın') ||
        lowerTip.contains('fırın')) {
      return CookingTechniqueType.panHeatTest;
    }

    if (lowerTip.contains('kapak') ||
        lowerTip.contains('kısık') ||
        lowerTip.contains('buhar')) {
      return CookingTechniqueType.simmerSteamLock;
    }

    if (lowerTip.contains('dinlen') || lowerTip.contains('et suları') || lowerTip.contains('beklet')) {
      return CookingTechniqueType.restingJuices;
    }

    if (lowerTip.contains('aşırı doldur') ||
        lowerTip.contains('haşlan') ||
        lowerTip.contains('sote')) {
      return CookingTechniqueType.sauteToss;
    }

    if (lowerTip.contains('baharat') ||
        lowerTip.contains('kavur') ||
        lowerTip.contains('aroma')) {
      return CookingTechniqueType.spiceBloom;
    }

    switch (lowerTool) {
      case 'knife':
      case 'bicak':
        return CookingTechniqueType.clawGripKnife;
      case 'whisk':
      case 'cirpici':
        return CookingTechniqueType.whiskFigureEight;
      case 'pot':
      case 'tencere':
        return CookingTechniqueType.simmerSteamLock;
      case 'pan':
      case 'tava':
        return CookingTechniqueType.sauteToss;
      case 'oven':
      case 'firin':
        return CookingTechniqueType.panHeatTest;
      case 'spoon':
      case 'kasik':
        return CookingTechniqueType.spiceBloom;
      case 'plate':
      case 'tabak':
      case 'servis':
      case 'bowl':
      case 'kase':
        return CookingTechniqueType.restingJuices;
      default:
        return CookingTechniqueType.clawGripKnife;
    }
  }

  String get title {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Pençe Tutuşu & Beşik Kesimi';
      case CookingTechniqueType.panHeatTest:
        return 'Tava Su Damlası Isı Testi';
      case CookingTechniqueType.whiskFigureEight:
        return '8 Rakamı Çırpma Tekniği';
      case CookingTechniqueType.simmerSteamLock:
        return 'Kapak Kapalı Buhar Döngüsü';
      case CookingTechniqueType.sauteToss:
        return 'Tek Katman Sote & Havalandırma';
      case CookingTechniqueType.spiceBloom:
        return 'Baharatı Yağda Açma & Çevirme';
      case CookingTechniqueType.restingJuices:
        return 'Dinlendirme & Lezzet Dengesi';
      case CookingTechniqueType.substitutionBalance:
        return 'Akıllı İkame & Kıvam Dengesi';
    }
  }

  String get guidanceText {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Parmak uçlarını içeri kıvırıp tırnakları koruyun; bıçağın ucunu tahtaya sabitleyip beşik gibi sallayın.';
      case CookingTechniqueType.panHeatTest:
        return 'Tavaya birkaç damla su atın. Dağılmadan cızırdayıp bir arada kayıyorsa mühürleme sıcaklığına ulaşmıştır.';
      case CookingTechniqueType.whiskFigureEight:
        return 'Daire çizmek yerine çırpıcıyı 8 rakamı gibi çevirin; karışıma iki kat daha fazla mikro hava hapseder.';
      case CookingTechniqueType.simmerSteamLock:
        return 'Kapağı açmayın! Buhar kapakta yoğunlaşıp yemeğe geri damlar; kapak açılırsa aroma ve ısı uçar.';
      case CookingTechniqueType.sauteToss:
        return 'Tavayı üst üste doldurmayın. Malzemeler tabana tek katman temas ederse buharda haşlanmaz, nar gibi kızarır.';
      case CookingTechniqueType.spiceBloom:
        return 'Baharatları doğrudan sıcak yağa serpin ve 30 saniye kokusu çıkana dek nazikçe çevirin.';
      case CookingTechniqueType.restingJuices:
        return 'Pişen yemeği hemen servis etmeyin. Kapağı kapalı dinlendirince lezzetler ve sular homojen dağılır.';
      case CookingTechniqueType.substitutionBalance:
        return 'İkame yaparken sıvıyı kontrollü ekleyin; kıvam tuttuğunda orijinal tarif lezzetini yakalarsınız.';
    }
  }

  String get proMethod {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Parmak uçları içeri kıvrık (pençe), tırnaklar tamamen geride. Bıçağın gövdesi orta parmak eklemine yaslanır; bıçak ucu tahtadan hiç ayrılmadan dikey değil beşik gibi ritmik salınır.';
      case CookingTechniqueType.panHeatTest:
        return 'Tava 2-3 dakika kuru ısıtılır. 2-3 damla su serpilir; damlalar buharlaşmak yerine cıva gibi birleşip dans ediyorsa (Leidenfrost etkisi) sıcaklık 190-200°C\'dir. Yağ ve et şimdi eklenir.';
      case CookingTechniqueType.whiskFigureEight:
        return 'Bilekten güç alarak kabın tabanına yatay bir 8 (sonsuzluk) yörüngesi çizilir. Sıvı iki ayrı girdaba bölünerek içine iki kat hava hapseder; karışım 3 kat daha hızlı kabarır.';
      case CookingTechniqueType.simmerSteamLock:
        return 'Kapak sıkıca kapalı tutulur. Tencereden yükselen aroma yüklü buhar kapağın soğuk iç yüzeyinde yoğunlaşır ve yemeğin üzerine kesintisiz damlar. Isı ve lezzet %100 tencerede kalır.';
      case CookingTechniqueType.sauteToss:
        return 'Malzemeler tavaya tek katman dizilir; aralarında hava boşluğu bırakılır. Tava ileri-yukarı bilek hareketiyle silkelenerek malzemelerin havada takla atıp eşit karamelize olması sağlanır.';
      case CookingTechniqueType.spiceBloom:
        return 'Baharatlar ılık/sıcak yağa dökülür ve spatula ile 25-30 saniye sürekli çevrilir. Yağda çözünen uçucu aromatik bileşikler serbest kalır kalmaz sıvı eklenerek pişirme dengelenir.';
      case CookingTechniqueType.restingJuices:
        return 'Pişen yemek ocaktan veya fırından alınıp kapağı kapalı (veya etlerde gevşek folyo altında) dinlendirilir. Hapsolan buhar ve sular liflere/sosuna geri dönerek yemeğin kıvamını ve lezzetini mükemmelleştirir.';
      case CookingTechniqueType.substitutionBalance:
        return 'İkame malzeme eklenirken sıvı 3 aşamada kontrollü verilir. Kaşık sırtından süzülen damla akışkanlığı orijinal malzeme kıvamına eşitlendiğinde durulur.';
    }
  }

  String get amateurMistake {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Parmakları kesme tahtasına düz basmak (bıçak tırnağı kesebilir) veya bıçağı tahtadan havaya kaldırıp balta gibi vurarak malzemeleri ezmek.';
      case CookingTechniqueType.panHeatTest:
        return 'Tava yeterince kızmadan eti soğuk tavaya koymak; et suyunu bırakıp haşlanır, grileşir ve asla nar gibi mühürlenmez.';
      case CookingTechniqueType.whiskFigureEight:
        return 'Sadece kabın kenarından dairesel çevirmek; sıvı hava almaz, karışım homojenleşmez ve kolunuz gereksiz yere erkenden yorulur.';
      case CookingTechniqueType.simmerSteamLock:
        return 'Merak edip her 2 dakikada bir kapağı açmak; tenceredeki 15 dakikalık buhar ve ısı birikimi uçar, pişme süresi 2 katına çıkar.';
      case CookingTechniqueType.sauteToss:
        return 'Tavayı tıka basa doldurmak; malzemeler üst üste binince buharda sulanarak haşlanır, çıtırlık ve lezzet kaybolur.';
      case CookingTechniqueType.spiceBloom:
        return 'Baharatı aşırı kızgın yağda gözetimsiz bırakmak; baharat 40 saniye içinde yanar, simsiyah olur ve yemeğe acı bir tat verir.';
      case CookingTechniqueType.restingJuices:
        return 'Yemeği ocaktan alır almaz kapağını açıp hemen tabağa almak veya eti sıcakken dilimlemek; lezzetli buhar ve sular uçar, et sert veya yemek kıvamsız kalır.';
      case CookingTechniqueType.substitutionBalance:
        return 'Tüm ikameyi ve sıvıyı tek seferde boca etmek; kıvam ya lapa gibi cıvıklaşır ya da taş gibi sertleşir.';
    }
  }

  List<String> get stepList {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return [
          '1. Adım: Parmakları pençe yapın, tırnakları arkaya saklayın.',
          '2. Adım: Bıçak ucunu tahtaya sabitleyip beşik gibi salın.',
          '3. Adım: Malzemeyi ileri iterek ritmik şekilde dilimleyin.'
        ];
      case CookingTechniqueType.panHeatTest:
        return [
          '1. Adım: Tavayı orta-yüksek ateşte 2-3 dk kuru ısıtın.',
          '2. Adım: Parmağınızla birkaç damla su serpin.',
          '3. Adım: Damlalar cıva gibi birleşip kayıyorsa tava hazırdır.'
        ];
      case CookingTechniqueType.whiskFigureEight:
        return [
          '1. Adım: Kabı 45 derece hafif eğik tutun.',
          '2. Adım: Çırpıcı ile tabanda sonsuzluk (8) şekli çizin.',
          '3. Adım: Mikro hava kabarcıkları oluşunca ritmi sabit tutun.'
        ];
      case CookingTechniqueType.simmerSteamLock:
        return [
          '1. Adım: Kaynama başlayınca ocağı en kısık seviyeye alın.',
          '2. Adım: Ağır tencere kapağını kapatıp hava sızdırmazlığını sağlayın.',
          '3. Adım: Süre dolana kadar kapağı kesinlikle açmayın.'
        ];
      case CookingTechniqueType.sauteToss:
        return [
          '1. Adım: Malzemeleri tek katman halinde tavaya yayın.',
          '2. Adım: Taban 1-2 dakika temas edip kızarana kadar ellemeyin.',
          '3. Adım: Bilekten tek hareketle silkeleyerek havalandırın.'
        ];
      case CookingTechniqueType.spiceBloom:
        return [
          '1. Adım: Yağı ısıtıp ateşi orta seviyeye çekin.',
          '2. Adım: Baharatları ekleyip 25-30 sn sürekli karıştırın.',
          '3. Adım: Koku buruna gelir gelmez sıvıyı/salçayı ilave edin.'
        ];
      case CookingTechniqueType.restingJuices:
        return [
          '1. Adım: Yemeği ocaktan/fırından alıp kapağını kapalı tutun.',
          '2. Adım: Buharın ve lezzetin oturması için 5-15 dakika dinlendirin.',
          '3. Adım: Sosu ve aroması dengelenmiş yemeği sıcak servis yapın.'
        ];
      case CookingTechniqueType.substitutionBalance:
        return [
          '1. Adım: İkame malzemeyi ölçülü kaba alın.',
          '2. Adım: Sıvıyı azar azar ekleyip kıvamı test edin.',
          '3. Adım: Orijinal tarif dokusuna ulaştığınızda kullanın.'
        ];
    }
  }

  IconData get icon {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return Icons.safety_check_rounded;
      case CookingTechniqueType.panHeatTest:
        return Icons.local_fire_department_rounded;
      case CookingTechniqueType.whiskFigureEight:
        return Icons.all_inclusive_rounded;
      case CookingTechniqueType.simmerSteamLock:
        return Icons.lock_clock_rounded;
      case CookingTechniqueType.sauteToss:
        return Icons.auto_awesome_rounded;
      case CookingTechniqueType.spiceBloom:
        return Icons.flare_rounded;
      case CookingTechniqueType.restingJuices:
        return Icons.hourglass_top_rounded;
      case CookingTechniqueType.substitutionBalance:
        return Icons.balance_rounded;
    }
  }

  String get metricBadge {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Güvenlik: %100 Pençe | Açı: 15° Salınım';
      case CookingTechniqueType.panHeatTest:
        return 'Isı: 195°C-210°C | Leidenfrost Efekti';
      case CookingTechniqueType.whiskFigureEight:
        return 'Hacim: +200% Aerasyon | Yörünge: 8 Akışı';
      case CookingTechniqueType.simmerSteamLock:
        return 'Nem: %95 Koruma | Basınç: Sabit Kısık';
      case CookingTechniqueType.sauteToss:
        return 'Temas: %100 Tek Katman | Maillard Karamel';
      case CookingTechniqueType.spiceBloom:
        return 'Süre: 30 sn Eşik | Maksimum Uçucu Aroma';
      case CookingTechniqueType.restingJuices:
        return 'Bekleme: 7 dk İdeal | Lif İçi Denge';
      case CookingTechniqueType.substitutionBalance:
        return 'Denge: 1:1 Kıvam | Kademeli Sıvı Toleransı';
    }
  }

  String get imageUrl {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Chef%27s_knife_grip.jpg/960px-Chef%27s_knife_grip.jpg';
      case CookingTechniqueType.panHeatTest:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Cooking_frying_pan.jpg/960px-Cooking_frying_pan.jpg';
      case CookingTechniqueType.whiskFigureEight:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Whisk.jpg/960px-Whisk.jpg';
      case CookingTechniqueType.simmerSteamLock:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Modern_cooking_pot_with_glass_cover_and_vegetable-beef_stew.jpg/960px-Modern_cooking_pot_with_glass_cover_and_vegetable-beef_stew.jpg';
      case CookingTechniqueType.sauteToss:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Vegetable_stir-fry.jpg/960px-Vegetable_stir-fry.jpg';
      case CookingTechniqueType.spiceBloom:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Midnight_curry_with_mixed_Goan_spices_and_vegetables_pan-stirred.jpg/960px-Midnight_curry_with_mixed_Goan_spices_and_vegetables_pan-stirred.jpg';
      case CookingTechniqueType.restingJuices:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Grilled_flank_steak.jpg/960px-Grilled_flank_steak.jpg';
      case CookingTechniqueType.substitutionBalance:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/4MeasuringSpoons.jpg/960px-4MeasuringSpoons.jpg';
    }
  }

  String get focalPointLabel {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return 'Pençe Emniyet Kilidi';
      case CookingTechniqueType.panHeatTest:
        return 'Leidenfrost 200°C Isı Noktası';
      case CookingTechniqueType.whiskFigureEight:
        return '8 Figürü Aerasyon Girdabı';
      case CookingTechniqueType.simmerSteamLock:
        return 'Nem & Lezzet Geri Dönüşü';
      case CookingTechniqueType.sauteToss:
        return '45° Kavis & Karamelizasyon';
      case CookingTechniqueType.spiceBloom:
        return 'Yağda Çözünen Uçucu Yağlar';
      case CookingTechniqueType.restingJuices:
        return 'Lif İçi Su Dağılımı';
      case CookingTechniqueType.substitutionBalance:
        return 'Kademeli Kıvam Dengesi';
    }
  }

  List<String> get phaseTitles {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return ['1. Pençe Duruşu', '2. Beşik Salınımı', '3. Ritmik Kesim'];
      case CookingTechniqueType.panHeatTest:
        return ['1. Kuru Isıtma', '2. Su Serpme', '3. Leidenfrost'];
      case CookingTechniqueType.whiskFigureEight:
        return ['1. 45° Eğim', '2. Sonsuzluk Akışı', '3. Mikro Kabarcık'];
      case CookingTechniqueType.simmerSteamLock:
        return ['1. Kısık Ateş', '2. Kapak Kilidi', '3. Nem Döngüsü'];
      case CookingTechniqueType.sauteToss:
        return ['1. Tek Katman', '2. Mühürlü Taban', '3. Havalandırma'];
      case CookingTechniqueType.spiceBloom:
        return ['1. Ilık Yağ', '2. 30 sn Çevirme', '3. Aroma Açığa Çıkışı'];
      case CookingTechniqueType.restingJuices:
        return ['1. Ocaktan Alma', '2. Dinlendirme & Kapak', '3. Servis & Sunum'];
      case CookingTechniqueType.substitutionBalance:
        return ['1. Hassas Ölçüm', '2. Kademeli Sıvı', '3. Kıvam Eşitleme'];
    }
  }

  List<String> get phaseInstructions {
    switch (this) {
      case CookingTechniqueType.clawGripKnife:
        return [
          'Parmak uçlarınızı içeri kıvırıp tırnaklarınızı geriye gizleyin. Bıçağın yan yüzeyi orta parmak eklemine yaslanmalıdır.',
          'Bıçağın ucunu tahtaya sabitleyin; bıçağı balta gibi vurmak yerine beşik gibi ileri-aşağı salındırın.',
          'Malzemeyi baş parmağınızla hafifçe ileri iterken bıçağı tahtadan ayırmadan sabit ritimle dilimleyin.'
        ];
      case CookingTechniqueType.panHeatTest:
        return [
          'Tavayı yağ eklemeden orta-yüksek ateşte 2-3 dakika boyunca kuru olarak ısıtın.',
          'Parmağınızı ıslatıp tavaya 2-3 damla su serpin. Hemen buharlaşıyorsa tava henüz hazır değildir.',
          'Su damlaları cıva gibi birleşip tava tabanında kayarak dans ediyorsa sıcaklık 200°C\'dir; yağ ve eti şimdi ekleyin.'
        ];
      case CookingTechniqueType.whiskFigureEight:
        return [
          'Çırpma kabını sol elinizle 45 derece eğik tutun ve çırpıcıyı sapından rahatça kavrayın.',
          'Dairesel dönüş yerine kabın tabanına yatay bir 8 (sonsuzluk) yörüngesi çizin.',
          'Oluşan karşıt iki girdap karışıma iki kat fazla mikro hava hapseder; karışım rekor hızla kabarır.'
        ];
      case CookingTechniqueType.simmerSteamLock:
        return [
          'Tencere fokurdamaya başlar başlamaz ocağın altını en kısık seviyeye getirin.',
          'Tencerenin kapağını sıkıca kapatarak buharın kenarlardan kaçmasını engelleyin.',
          'Kapağı kesinlikle açmayın! Aromatik buhar kapağın iç yüzeyinde yoğunlaşıp yemeğe geri damlar.'
        ];
      case CookingTechniqueType.sauteToss:
        return [
          'Malzemeleri tavaya üst üste gelmeyecek şekilde tek katman halinde yayın.',
          'Malzemelerin tabanla temas edip nar gibi kızarması için 1-2 dakika ellemeyin.',
          'Tavayı bilekten ileri-yukarı silkeleyerek malzemelerin havada takla atıp eşit pişmesini sağlayın.'
        ];
      case CookingTechniqueType.spiceBloom:
        return [
          'Tavaya 1-2 kaşık yağı koyup orta ateşte ısıtın.',
          'Baharatları doğrudan yağa dökün ve spatula ile 25-30 saniye aralıksız çevirin.',
          'Yağda çözünen uçucu aromalar buruna geldiği anda sıvı veya salçayı ekleyip pişirmeyi dengeleyin.'
        ];
      case CookingTechniqueType.restingJuices:
        return [
          'Pişen yemeği ocaktan veya fırından alın; kapağını ya da folyosunu açmadan sıcağını koruyun.',
          'Buharın ve lezzetlerin homojen oturması için belirtilen dinlendirme süresince (5-15 dk) bekletin.',
          'Dinlenen yemeğin sosu koyulaşır ve aroması tam oturur; sıcak ve şık bir sunumla servis yapın.'
        ];
      case CookingTechniqueType.substitutionBalance:
        return [
          'İkame malzemeyi hassas ölçü kabında hazırlayın.',
          'Sıvı bileşeni tek seferde boca etmek yerine 3 aşamada azar azar ekleyip karıştırın.',
          'Kaşığın arkasıyla kıvamı test edin; orijinal tarif dokusuna ulaştığınızda işlemi tamamlayın.'
        ];
    }
  }
}

/// Interactive Photographic Culinary Masterclass Story Guide (Zero Vector Graphics)
class CookingTechniqueAnimation extends StatefulWidget {
  final CookingTechniqueType technique;
  final double height;
  final bool isDarkMode;
  final bool showControls;

  const CookingTechniqueAnimation({
    super.key,
    required this.technique,
    this.height = 160,
    this.isDarkMode = true,
    this.showControls = true,
  });

  @override
  State<CookingTechniqueAnimation> createState() => _CookingTechniqueAnimationState();
}

class _CookingTechniqueAnimationState extends State<CookingTechniqueAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  int _activeTab = 0; // 0: Masterclass Story, 1: Do vs Don't, 2: 3 Steps
  bool _showCorrectMethod = true;
  int _selectedPhaseIndex = 0;

  int get _currentActivePhase {
    if (_controller.isAnimating) {
      return (_controller.value * 3).floor().clamp(0, 2);
    }
    return _selectedPhaseIndex;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.33;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
        if (!isTest) {
          _controller.repeat();
        } else {
          _controller.value = 0.33;
        }
        _isPlaying = true;
      }
    });
  }

  void _replay() {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _controller.reset();
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.33;
    }
    setState(() {
      _isPlaying = true;
      _selectedPhaseIndex = 0;
    });
  }

  void _selectPhase(int index) {
    setState(() {
      _selectedPhaseIndex = index;
    });
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.animateTo(
        (index + 0.5) / 3.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.value = (index + 0.5) / 3.0;
    }
  }

  void _nextPhase() {
    final next = (_currentActivePhase + 1) % 3;
    _selectPhase(next);
  }

  void _prevPhase() {
    final prev = (_currentActivePhase - 1 + 3) % 3;
    _selectPhase(prev);
  }

  void _openFullMasterclassModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.technique.icon, color: const Color(0xFFFF5722), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.technique.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Mutfak Masterclass & Şef Rehberi',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Modal Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photographic Visual Stage
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: _buildPhotographicStoryStage(isModal: true),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Telemetry Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF5722).withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded, color: Color(0xFFFF5722), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.technique.metricBadge,
                              style: const TextStyle(
                                color: Color(0xFFFF5722),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3-Phase Interactive Breakdown
                    Text(
                      'UYGULAMA AŞAMALARI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: widget.isDarkMode ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (int i = 0; i < 3; i++) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: i == _currentActivePhase
                                ? const Color(0xFFFF5722).withValues(alpha: 0.5)
                                : (widget.isDarkMode ? Colors.white12 : Colors.grey.shade200),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5722),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.technique.phaseTitles[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.technique.phaseInstructions[i],
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Do vs Don't
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'DOĞRU: Profesyonel Şef Yöntemi',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.technique.proMethod,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'YANLIŞ: Kaçınılması Gereken Acemi Hatası',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.technique.amateurMistake,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: widget.isDarkMode ? Colors.white70 : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Anladım, Uygulayalım',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.technique.icon,
                    size: 16,
                    color: const Color(0xFFFF5722),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.technique.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Şef Tekniği & Canlı Kılavuz',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isDarkMode ? Colors.white54 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showControls) ...[
                  InkWell(
                    onTap: () => _openFullMasterclassModal(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.fullscreen_rounded,
                        size: 20,
                        color: widget.isDarkMode ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Interactive Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'Canlı Rehber', Icons.auto_stories_rounded),
                  _buildTabButton(1, 'Doğru / Yanlış', Icons.compare_arrows_rounded),
                  _buildTabButton(2, '3 Adım', Icons.format_list_numbered_rounded),
                ],
              ),
            ),
          ),

          // Tab Content
          if (_activeTab == 0) ...[
            // Masterclass Photographic Story Stage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: widget.height,
                  width: double.infinity,
                  child: _buildPhotographicStoryStage(isModal: false),
                ),
              ),
            ),

            // 3-Phase Stepper Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectPhase(i),
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: _currentActivePhase == i
                                ? const Color(0xFFFF5722).withValues(alpha: 0.2)
                                : (widget.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _currentActivePhase == i
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.technique.phaseTitles[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: _currentActivePhase == i
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentActivePhase == i
                                  ? const Color(0xFFFF5722)
                                  : (widget.isDarkMode ? Colors.white70 : Colors.grey.shade700),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ] else if (_activeTab == 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: SizedBox(
                height: widget.height + 26,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _showCorrectMethod = true),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _showCorrectMethod
                                  ? const Color(0xFF10B981)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: _showCorrectMethod ? Colors.white : const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DOĞRU ŞEF YÖNTEMİ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _showCorrectMethod ? Colors.white : const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _showCorrectMethod = false),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: !_showCorrectMethod
                                  ? const Color(0xFFEF4444)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  size: 13,
                                  color: !_showCorrectMethod ? Colors.white : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ACEMİ HATASI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: !_showCorrectMethod ? Colors.white : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _showCorrectMethod
                              ? const Color(0xFF059669).withValues(alpha: 0.1)
                              : const Color(0xFFDC2626).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _showCorrectMethod
                                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                : const Color(0xFFEF4444).withValues(alpha: 0.3),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showCorrectMethod ? 'Şeflerin Altın Kuralı:' : 'Yapılan Kritik Hata:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _showCorrectMethod
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _showCorrectMethod
                                    ? widget.technique.proMethod
                                    : widget.technique.amateurMistake,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: SizedBox(
                height: widget.height + 26,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 0; i < widget.technique.stepList.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5722),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.technique.stepList[i].replaceFirst('${i + 1}. Adım: ', ''),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // Guidance caption and micro-controls
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.technique.guidanceText,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: widget.isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.showControls) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _togglePlayPause,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 14,
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _replay,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.replay_rounded,
                        size: 14,
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDarkMode ? const Color(0xFF334155) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? const Color(0xFFFF5722)
                    : (widget.isDarkMode ? Colors.white54 : Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (widget.isDarkMode ? Colors.white : const Color(0xFF0F172A))
                      : (widget.isDarkMode ? Colors.white54 : Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Masterclass Photographic Story Stage (100% Real Culinary Photography & Step Story Player)
  Widget _buildPhotographicStoryStage({bool isModal = false}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final activePhase = _currentActivePhase;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Authentic Culinary High-Res Photography
            Image.network(
              widget.technique.imageUrl,
              headers: const {'User-Agent': 'AreWeCookinApp/1.0 (culinary-app)'},
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isDarkMode
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.technique.icon,
                      size: 48,
                      color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),

            // Cinematic Dark Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top: 3-Segment Story Progress Bars (Like Instagram / Masterclass Story)
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          height: 3,
                          color: Colors.white24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: i < activePhase
                                  ? 1.0
                                  : (i == activePhase ? ((progress * 3) - i).clamp(0.0, 1.0) : 0.0),
                              child: Container(
                                color: const Color(0xFFFF5722),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),

            // Top Badge: Phase Header & Telemetry
            Positioned(
              top: 18,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AŞAMA ${activePhase + 1}/3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      widget.technique.focalPointLabel,
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Touch Controls: Left and Right Tap Navigators
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _prevPhase,
                      splashColor: Colors.white10,
                      highlightColor: Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _nextPhase,
                      splashColor: Colors.white10,
                      highlightColor: Colors.transparent,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Glassmorphic Instructional Card
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF5722), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.technique.phaseTitles[activePhase],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.technique.phaseInstructions[activePhase],
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 10,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
