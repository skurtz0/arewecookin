import '../models/recipe.dart';
import 'app_strings.dart';

class RecipeLocalization {
  RecipeLocalization._();

  static bool isTurkish(String locale) {
    return locale.toLowerCase().startsWith('tr');
  }

  // ==========================================
  // Category & Cuisine & Difficulty
  // ==========================================

  static String localizeCategory(String category, AppStrings strings) {
    switch (category.trim()) {
      case 'Tümü':
      case 'Hepsi':
        return strings.catAll;
      case 'Ana Yemek':
        return strings.catMain;
      case 'Tatlı':
        return strings.catDessert;
      case 'Çorba':
        return strings.catSoup;
      case 'Kahvaltılık':
      case 'Kahvaltı':
        return strings.catBreakfast;
      case 'Pratik':
        return strings.catQuick;
      case 'Hamur İşi':
        return strings.catBakery;
      case 'Salata':
      case 'Salata & Meze':
        return strings.catSalad;
      case 'Vegan':
        return strings.catVegan;
      default:
        return category;
    }
  }

  static String localizeCuisine(String cuisine, AppStrings strings) {
    final clean = cuisine.replaceAll('Mutfağı', '').trim();
    switch (clean) {
      case 'Tümü':
        return strings.cuisineAll;
      case 'Türk':
        return strings.cuisineTurkish;
      case 'İtalyan':
        return strings.cuisineItalian;
      case 'Asya & Uzak Doğu':
      case 'Asya':
      case 'Uzak Doğu':
        return strings.cuisineAsian;
      case 'Meksika':
        return strings.cuisineMexican;
      case 'Akdeniz':
        return strings.cuisineMediterranean;
      case 'Fransız & Dünya':
      case 'Fransız':
        return strings.cuisineFrenchWorld;
      case 'Pratik & Sokak':
      case 'Pratik':
      case 'Sokak':
        return strings.cuisineStreet;
      default:
        return cuisine;
    }
  }

  static String localizeDifficulty(String difficulty, AppStrings strings) {
    switch (difficulty.trim()) {
      case 'Kolay':
        return strings.diffEasy;
      case 'Orta':
        return strings.diffMedium;
      case 'Zor':
        return strings.diffHard;
      default:
        return difficulty;
    }
  }

  // ==========================================
  // Dish Title & Base Dish Mapping
  // ==========================================

  static const Map<String, String> _dishBaseTranslations = {
    // Ana Yemek (Main Dish)
    'Güveçte Kuru Fasulye': 'Clay Pot White Bean Stew',
    'Fırında Tavuk Pirzola': 'Baked Chicken Chops',
    'Karnıyarık': 'Stuffed Eggplant with Minced Meat',
    'Hünkar Beğendi': "Sultan's Delight (Beef & Smoked Eggplant)",
    'Izgara Kasap Köfte': 'Grilled Butcher Meatballs',
    'Tas Kebabı': 'Traditional Beef Stew (Tas Kebab)',
    'Fırında Çipura': 'Baked Sea Bream with Herbs',
    'Mantarlı Tavuk Sote': 'Sautéed Chicken with Mushrooms',
    'Kıymalı Biber Dolması': 'Stuffed Bell Peppers with Minced Meat',
    'Orman Kebabı': 'Forest Stew with Lamb & Vegetables',
    'Terbiyeli Köfte': 'Meatball Soup with Lemon Liaison',
    'İmam Bayıldı': 'Braised Eggplant with Onion & Tomato',
    'Etli Nohut Yemeği': 'Chickpea & Beef Stew',
    'Fırında Sebzeli Somon': 'Baked Herb Salmon with Vegetables',
    'Ali Nazik Kebabı': 'Ali Nazik Kebab over Garlic Eggplant',
    'Kuzu İncik': 'Slow-Cooked Lamb Shank',
    'Klasik Fırın Lazanya': 'Classic Baked Lasagna',
    'Kremalı Mantarlı Risotto': 'Creamy Mushroom Risotto',
    'Tavuklu Japon Rameni': 'Japanese Chicken Ramen',
    'Geleneksel Pad Thai': 'Traditional Pad Thai',
    'Tatlı Ekşi Soslu Tavuk': 'Sweet & Sour Chicken',
    'Kıymalı Çıtır Taco': 'Crispy Beef Tacos',
    'Tavuklu Fırın Enchilada': 'Baked Chicken Enchiladas',
    'Meksika Usulü Chili con Carne': 'Mexican Chili con Carne',
    'Deniz Mahsullü Paella': 'Seafood Paella',
    'Geleneksel Fırın Ratatouille': 'Baked French Ratatouille',
    'Bursa İskender Kebabı': 'Bursa Iskender Kebab',
    'Bodrum Çökertme Kebabı': 'Bodrum Cokertme Kebab',

    // Tatlı (Dessert)
    'Fırın Sütlaç': 'Baked Rice Pudding',
    'Kakaolu Islak Kek': 'Chocolate Lava Wet Cake',
    'Geleneksel Kazandibi': 'Caramelized Milk Pudding (Kazandibi)',
    'Tereyağlı İrmik Helvası': 'Buttery Semolina Halva',
    'Şekerpare': 'Syrup-Soaked Almond Cookies',
    'Çilekli Magnolia': 'Strawberry Magnolia Pudding',
    'Cevizli Revani': 'Walnut Semolina Syrup Cake',
    'Çikolatalı Supangle': 'Chocolate Pudding with Sponge Cake',
    'Karamelli Trileçe': 'Caramel Tres Leches Cake',
    'Havuçlu Tarçınlı Kek': 'Carrot Cinnamon Spiced Cake',
    'Saray Muhallebisi': 'Ottoman Palace Milk Pudding',
    'Profiterol': 'Chocolate Covered Profiteroles',
    'Baklava Dilimli Revani': 'Baklava-Cut Syrup Cake',
    'Limonlu Cheesecake': 'Lemon Zest Cheesecake',
    'Mozaik Pasta': 'Chocolate Mosaic Biscuit Cake',
    'Vişneli Ekmek Kadayıfı': 'Sour Cherry Bread Pudding',
    'Geleneksel Tiramisu': 'Classic Italian Tiramisu',
    'Sıcak Çikolatalı Sufle': 'Warm Molten Chocolate Soufflé',
    'Tarçınlı Meksika Churros': 'Cinnamon Sugar Churros',
    'Vanilyalı Panna Cotta': 'Vanilla Bean Panna Cotta',
    'Antep Fıstıklı Katmer': 'Pistachio Crispy Katmer',
    'Meyveli Çıtır Tartalet': 'Crispy Fresh Fruit Tartlets',

    // Çorba (Soup)
    'Süzme Kırmızı Mercimek': 'Creamy Red Lentil Soup',
    'Geleneksel Ezogelin': 'Spiced Ezogelin Lentil Soup',
    'Naneli Yayla Çorbası': 'Mint Yogurt & Rice Soup',
    'Kremalı Dağ Mantarı': 'Cream of Wild Mountain Mushroom Soup',
    'Terbiyeli Tavuk Çorbası': 'Chicken Soup with Lemon-Egg Liaison',
    'Ev Yapımı Tarhana': 'Artisan Sun-Dried Tarhana Soup',
    'Fesleğenli Domates Çorbası': 'Roasted Tomato Soup with Fresh Basil',
    'Düğün Çorbası': 'Traditional Wedding Lamb Soup',
    'Sebzeli Minestrone': 'Rustic Vegetable Minestrone',
    'Kelle Paça Usulü Çorba': 'Garlic & Broth Soup',
    'Arpa Şehriyeli Çorba': 'Tomato & Orzo Pasta Soup',
    'Köz Kırmızı Biber Çorbası': 'Roasted Red Pepper Soup',
    'Geleneksel Miso Çorbası': 'Japanese Miso Soup',
    'Fransız Karamelize Soğan Çorbası': 'French Caramelized Onion Soup',
    'Tom Yum Usulü Tavuk Çorbası': 'Tom Yum Style Chicken Soup',
    'Beyran Usulü Et Çorbası': 'Spicy Lamb & Rice Broth (Beyran)',

    // Kahvaltılık (Breakfast)
    'Geleneksel Menemen': 'Traditional Turkish Menemen',
    'Kayseri Sucuklu Yumurta': 'Fried Eggs with Spicy Beef Sucuk',
    'Kaşarlı Peynirli Krep': 'Melted Cheese Breakfast Crepes',
    'Patatesli Köy Omleti': 'Country Potato & Herb Omelette',
    'Karadeniz Mıhlaması': 'Black Sea Cheesy Cornmeal Fondue',
    'Fırında Yumurtalı Kaşarlı Ekmek': 'Baked Cheesy Egg Toast',
    'Peynirli Sigara Böreği': 'Crispy Feta Filo Rolls',
    'Yulaflı Pankek': 'Fluffy Oat Banana Pancakes',
    'Çılbır (Yoğurtlu Poşe Yumurta)': 'Poached Eggs in Garlic Yogurt (Cilbir)',
    'Simit & Kaşar Tostu': 'Toasted Sesame Simit with Kashar',
    'Zeytin Ezmeli Bruschetta': 'Olive Tapenade & Tomato Bruschetta',
    'Avokadolu Poşe Yumurta': 'Avocado Toast with Poached Egg',
    'Yumurtalı Fried Rice': 'Egg & Scallion Fried Rice',
    'Taze Kruvasan Sandviç': 'Fresh Butter Croissant Sandwich',
    'Menemen Usulü Shakshuka': 'Mediterranean Shakshuka',
    'Peynirli Çıtır Gözleme': 'Crispy Cheese & Herb Flatbread (Gozleme)',

    // Pratik (Quick & Easy)
    'Sarımsaklı Domatesli Makarna': 'Garlic Cherry Tomato Pasta',
    'Tavuklu Fajita Wrap': 'Sizzling Chicken Fajita Wrap',
    'Ton Balıklı Akdeniz Sandviç': 'Mediterranean Tuna Sandwich',
    'Soya Soslu Sebzeli Noodle': 'Stir-Fried Vegetable Soy Noodles',
    '5 Dakikalık Peynirli Quesadilla': '5-Minute Crispy Cheese Quesadilla',
    'Fırında Baharatlı Elma Dilim Patates': 'Crispy Spiced Potato Wedges',
    'Kremalı Tavuklu Penne': 'Creamy Garlic Chicken Penne',
    'Mug Cake (Fincanda Kek)': 'Quick 2-Minute Microwave Mug Cake',
    'Köz Sebzeli Lavaş Dürüm': 'Roasted Veggie & Herb Lavash Wrap',
    'Fasulye Piyazı Sandviç': 'White Bean & Sumac Salad Pita',
    'Kremalı Mantarlı Ekmek Üstü': 'Creamy Mushrooms on Sourdough',
    'Pratik Tavada Pizza': 'Quick Skillet Pan Pizza',
    'İtalyan Pizza Margherita': 'Authentic Pizza Margherita',
    'Çıtır Ev Yapımı Smash Burger': 'Juicy Homemade Smash Burger',
    'Özel Soslu Islak Burger': 'Spiced Garlic Wet Burger',
    'Çıtır Tavuk Dürüm': 'Crispy Fried Chicken Wrap',
    'Guacamole & Çıtır Nachos': 'Fresh Guacamole & Crispy Nachos',
    'Etli Burrito Dürüm': 'Hearty Beef & Bean Burrito',
    'Sebzeli Tavuklu Wok': 'Wok-Tossed Chicken & Vegetables',
    'Patatesli Gnocchi': 'Pan-Seared Potato Gnocchi',

    // Hamur İşi (Bakery & Pastry)
    'Peynirli Tepsi Böreği': 'Golden Baked Cheese Tray Borek',
    'Mayasız Puf Poğaça': 'Quick Flaky Breakfast Buns (Pogaca)',
    'Kıymalı Kol Böreği': 'Spiral Minced Meat Filo Borek',
    'Taş Fırın Bazlama': 'Stone-Baked Village Flatbread (Bazlama)',
    'Susamlı Çıtır Simit': 'Crispy Sesame Simit',
    'Gözleme (Ispanaklı Peynirli)': 'Spinach & Feta Stuffed Gozleme',
    'Ev Yapımı Fındık Lahmacun': 'Crispy Thin-Crust Lahmacun',
    'Zeytinli Açma': 'Soft Olive Twisted Pastry (Acma)',
    'Kıymalı Pide': 'Boat-Shaped Minced Meat Pide',
    'Karaköy Poğaçası': 'Crumbly Karakoy Breakfast Buns',
    'Otlu Çörek': 'Fresh Herb & Cheese Savory Loaf',
    'Kuru Mayalı Peynirli Pide': 'Golden Cheese & Egg Pide',
    'Gyoza (Japon Mantısı)': 'Pan-Fried Japanese Pork Gyoza',
    'Çıtır Sebzeli Spring Roll': 'Golden Crispy Spring Rolls',
    'Kayseri Yağ Mantısı': 'Fried Stuffed Kayseri Dumplings',
    'Tavuklu & Pırasalı Quiche': 'Savory Chicken & Leek Quiche',

    // Salata (Salad)
    'Geleneksel Çoban Salatası': "Traditional Shepherd's Salad",
    'Cevizli Gavurdağı Salatası': 'Gavurdagi Tomato & Walnut Salad',
    'Akdeniz Yeşillikleri Salatası': 'Mediterranean Greens with Lemon',
    'Roka & Parmesan Salatası': 'Arugula Salad with Shaved Parmesan',
    'Antalya Usulü Tahinli Piyaz': 'Antalya White Bean Salad with Tahini',
    'Kinoa & Avokado Salatası': 'Avocado & Quinoa Power Salad',
    'Hellim Peynirli Yeşil Salata': 'Warm Seared Halloumi Salad',
    'Fırın Pancar & Keçi Peynirli Salata': 'Roasted Beet & Goat Cheese Salad',
    'Semizotu & Yoğurt Salatası': 'Purslane with Garlic Greek Yogurt',
    'Köz Patlıcan Salatası': 'Smoky Roasted Eggplant Salad',
    'Tavuklu Sezar Salata': 'Crisp Romaine Chicken Caesar Salad',
    'Tabule (Bulgur Salatası)': 'Fresh Parsley & Bulgur Tabbouleh',
    'Geleneksel Grek Salatası': 'Greek Salad with Kalamata Olives & Feta',
    'Köz Patlıcanlı Babagannuş': 'Charred Eggplant Baba Ghanoush',
    'Tavuklu Chipotle Bowl': 'Chipotle Grilled Chicken Bowl',
    'İzmir Usulü Kumru Sandviç': 'Izmir Kumru Grilled Sub',

    // Vegan
    'Kıtır Nohutlu Mercimek Bowl': 'Crispy Chickpea & Lentil Bowl',
    'Zeytinyağlı Enginar Kalbi': 'Braised Artichoke Hearts in Citrus Olive Oil',
    'Fırında Baharatlı Karnabahar Steak': 'Roasted Spiced Cauliflower Steak',
    'Tahinli Humus & Fırın Sebzeler': 'Tahini Hummus with Roasted Vegetables',
    'Geleneksel Mercimek Köftesi': 'Traditional Red Lentil Finger Kofte',
    'Mantarlı Tofu Sote': 'Crispy Tofu & Wild Mushroom Stir-Fry',
    'Fıstık Soslu Sebze Yahnisi': 'Peanut & Root Vegetable Stew',
    'Falafel Tabağı': 'Crispy Herb Falafel Platter',
    'Fırın Tatlı Patates Dolması': 'Stuffed Baked Sweet Potatoes',
    'Zeytinyağlı Kereviz': 'Braised Celeriac with Orange & Olive Oil',
    'Közlenmiş Sebze Güveci': 'Smoky Mediterranean Vegetable Casserole',
    'Buharda Edamame & Pirinç': 'Steamed Edamame with Jasmine Rice',
    'Sebzeli Sushi Roll': 'Fresh Avocado & Cucumber Sushi Rolls',
    'Körili Sebzeli Noodle': 'Yellow Curry Vegetable Noodles',
    'Falafel Dürüm': 'Crispy Falafel Wrap with Tahini',
    'Zeytinyağlı Yaprak Sarma': 'Stuffed Grape Leaves with Pine Nuts',
  };

  static const Map<String, String> _adjectiveTranslations = {
    'Özel': 'Special',
    'Pratik': 'Quick',
    'Fırında': 'Baked',
    'Geleneksel': 'Traditional',
    'Acemi Dostu': 'Easy',
    'Hızlı': 'Fast',
    'Hafif': 'Light',
    'Bol Baharatlı': 'Spiced',
    'Kremalı': 'Creamy',
    'Anne Eli Değmiş': 'Homestyle',
    'Usta İşi': 'Chef-Style',
    'Köz Kokulu': 'Char-Grilled',
    'Zeytinyağlı': 'Olive Oil Braised',
    'Fesleğenli': 'Basil Infused',
    'Tereyağlı': 'Buttery',
  };

  static String localizeCleanTitle(Recipe recipe, String locale) {
    if (isTurkish(locale)) {
      return recipe.cleanTitle;
    }

    final rawDish = recipe.baseDish?.trim() ?? recipe.cleanTitle;
    if (_dishBaseTranslations.containsKey(rawDish)) {
      return _dishBaseTranslations[rawDish]!;
    }

    // Try finding known base dish within title
    for (final entry in _dishBaseTranslations.entries) {
      if (recipe.title.contains(entry.key)) {
        return entry.value;
      }
    }

    return recipe.cleanTitle;
  }

  static String localizeTitle(Recipe recipe, String locale) {
    if (isTurkish(locale)) {
      return recipe.title;
    }

    final clean = localizeCleanTitle(recipe, locale);

    // Extract adjective if present at the start of original title
    for (final adjEntry in _adjectiveTranslations.entries) {
      if (recipe.title.startsWith(adjEntry.key)) {
        // Avoid duplicating words like 'Baked Baked'
        if (clean.toLowerCase().contains(adjEntry.value.toLowerCase())) {
          return clean;
        }
        return '${adjEntry.value} $clean';
      }
    }

    return clean;
  }

  // ==========================================
  // Ingredient Names & Units
  // ==========================================

  static const Map<String, String> _ingredientTranslations = {
    'Un': 'All-Purpose Flour',
    'Toz Şeker': 'Granulated Sugar',
    'Esmer Şeker': 'Brown Sugar',
    'Tuz': 'Fine Salt',
    'Kaya Tuzu': 'Sea Salt',
    'Zeytinyağı': 'Olive Oil',
    'Sızma Zeytinyağı': 'Extra Virgin Olive Oil',
    'Tereyağı': 'Butter',
    'Yumurta': 'Egg',
    'Yumurta Sarısı': 'Egg Yolk',
    'Süt': 'Whole Milk',
    'Ilık Süt': 'Warm Milk',
    'Domates': 'Tomatoes',
    'Domates Salçası': 'Tomato Paste',
    'Rende Domates': 'Crushed Tomatoes',
    'Yeşil Biber': 'Green Bell Pepper',
    'Kapya Biber': 'Red Sweet Pepper',
    'Kuru Soğan': 'Yellow Onion',
    'Arpacık Soğan': 'Shallots',
    'Sarımsak': 'Garlic',
    'Dana Kıyma': 'Ground Beef',
    'Kuzu Kıyma': 'Ground Lamb',
    'Tavuk Göğsü': 'Chicken Breast',
    'Tavuk But': 'Chicken Thighs',
    'Rende Kaşar Peyniri': 'Shredded Cheese (Mozzarella/Kashar)',
    'Beyaz Peynir': 'Feta Cheese',
    'Lor Peyniri': 'Ricotta / Curd Cheese',
    'Patates': 'Potatoes',
    'Baldo Pirinç': 'White Rice',
    'Kırık Pirinç': 'Short-Grain Rice',
    'Kırmızı Mercimek': 'Red Lentils',
    'Yeşil Mercimek': 'Green Lentils',
    'Penne Makarna': 'Penne Pasta',
    'Spagetti': 'Spaghetti',
    'Süzme Yoğurt': 'Greek Yogurt',
    'Ev Yoğurdu': 'Plain Yogurt',
    'Karabiber': 'Black Pepper',
    'Pul Biber': 'Red Pepper Flakes',
    'Kuru Nane': 'Dried Mint',
    'Kekik': 'Dried Oregano / Thyme',
    'Kimyon': 'Ground Cumin',
    'Kemer Patlıcan': 'Eggplant',
    'Bostan Patlıcanı': 'Globe Eggplant',
    'Çipura / Somon Fileto': 'Fish Fillet (Sea Bream / Salmon)',
    'Levrek Fileto': 'Sea Bass Fillet',
    'Dana Kuşbaşı': 'Beef Cubes',
    'Kuzu Eti': 'Diced Lamb',
    'Kuru Fasulye (Haşlanmış)': 'Cooked White Beans',
    'İspir Kuru Fasulye': 'White Cannellini Beans',
    'Haşlanmış Nohut': 'Cooked Chickpeas',
    'Koçbaşı Nohut': 'Chickpeas',
    'Kültür Mantarı': 'Button Mushrooms',
    'Kestane Mantarı': 'Cremini Mushrooms',
    'Havuç': 'Carrots',
    'Taze Limon Suyu': 'Fresh Lemon Juice',
    'Olgun Avokado': 'Ripe Avocado',
    'Maydanoz & Dereotu': 'Parsley & Fresh Dill',
    'Taze Roka': 'Fresh Baby Arugula',
    'Kakao': 'Cocoa Powder',
    'Bitter Çikolata': 'Dark Chocolate',
    'Dövülmüş Ceviz İçi': 'Crushed Walnuts',
    'Kangal Sucuk': 'Spicy Beef Sausage (Sucuk)',
    'Yumurta Noodle': 'Egg Noodles',
    'Soya Tofusu': 'Firm Tofu',
    'Lavaş / Tortilla': 'Flour Tortilla / Flatbread',
    'Pilavlık / Köftelik Bulgur': 'Bulgur Wheat',
    'İrmik': 'Semolina',
    'Taze Yufka': 'Fresh Filo Dough',
    'Konserve Ton Balığı': 'Canned Chunk Tuna',
  };

  static const Map<String, String> _unitTranslations = {
    'su bardağı': 'cups',
    'çay bardağı': 'small cups',
    'yemek kaşığı': 'tbsp',
    'tatlı kaşığı': 'tsp',
    'çay kaşığı': 'tsp',
    'adet': 'pcs',
    'orta boy': 'medium',
    'diş': 'cloves',
    'demet': 'bunch',
    'tutam': 'pinch',
    'dilim': 'slices',
    'paket': 'pack',
    'kutu': 'can',
    'kutu (160g)': 'can (160g)',
    'porsiyon': 'servings',
    'gram': 'g',
    'gr': 'g',
    'kilo': 'kg',
    'kg': 'kg',
    'ml': 'ml',
    'litre': 'L',
    'adet (küp doğranmış)': 'pcs (diced)',
    'adet (haşlanmış)': 'pcs (boiled)',
    'diş (ezilmiş)': 'cloves (minced)',
    'gram (kuşbaşı)': 'g (diced)',
  };

  static String localizeIngredientName(String name, String locale) {
    if (isTurkish(locale)) return name;
    return _ingredientTranslations[name.trim()] ?? name;
  }

  static String localizeUnit(String unit, String locale) {
    if (isTurkish(locale)) return unit;
    return _unitTranslations[unit.trim()] ?? unit;
  }

  // ==========================================
  // Cooking Steps & Pro Tips
  // ==========================================

  static const Map<String, String> _stepTitleTranslations = {
    'Ön Hazırlık & Malzemeler': 'Prep & Mise en Place',
    'Hazırlık': 'Preparation',
    'Soteleme / Mühürleme': 'Sautéing & Searing',
    'Soteleme': 'Sautéing',
    'Pişirme': 'Cooking & Simmering',
    'Fırınlama / Pişirme': 'Baking & Roasting',
    'Fırınlama': 'Baking in Oven',
    'Kıvam Verme & Sos': 'Sauce & Seasoning',
    'Kıvam Verme': 'Thickening',
    'Dinlendirme & Servis': 'Resting & Plating',
    'Servis': 'Plating & Presentation',
    'Karıştırma': 'Mixing & Whisking',
    'Yoğurma': 'Kneading Dough',
    'Doğrama & Karıştırma': 'Chopping & Tossing',
  };

  static String localizeStepTitle(String title, String locale) {
    if (isTurkish(locale)) return title;
    return _stepTitleTranslations[title.trim()] ?? title;
  }

  static String localizeStepInstruction(String instruction, String locale, [String? dishName]) {
    if (isTurkish(locale)) return instruction;

    final lower = instruction.toLowerCase();

    if (lower.contains('yıkayın') || lower.contains('doğrayın') || lower.contains('hazırlayın')) {
      return 'Wash, clean, and chop all ingredients into uniform pieces. Keep everything ready in prep bowls.';
    }
    if (lower.contains('ısıtın') || lower.contains('kızdırın') || lower.contains('tavayı')) {
      return 'Heat olive oil or butter in a skillet over medium heat until sizzling hot.';
    }
    if (lower.contains('soteleyin') || lower.contains('mühürleyin')) {
      return 'Add ingredients to the pan; sauté until lightly browned and fragrant, stirring gently.';
    }
    if (lower.contains('fırın') || lower.contains('180') || lower.contains('200')) {
      return 'Transfer into a baking dish and bake in a preheated oven at 190°C (375°F) until cooked through and golden.';
    }
    if (lower.contains('kısık ateş') || lower.contains('kaynamaya') || lower.contains('pişirin')) {
      return 'Reduce to a gentle simmer, cover with lid, and cook on low heat until tender and rich in flavor.';
    }
    if (lower.contains('dinlendirin') || lower.contains('servis')) {
      return 'Remove from heat, rest for 5-10 minutes, garnish with fresh herbs, and serve warm.';
    }

    return instruction;
  }

  static String localizeProTip(String proTip, String locale) {
    if (isTurkish(locale) || proTip.trim().isEmpty) return proTip;

    final lower = proTip.toLowerCase();

    if (lower.contains('oda sıcaklığı')) {
      return 'Chef Tip: Bring dairy and eggs to room temperature for silky blending and optimal texture.';
    }
    if (lower.contains('fırın')) {
      return 'Chef Tip: Keep the oven door closed during early baking to retain consistent heat and rise.';
    }
    if (lower.contains('mühür') || lower.contains('tava')) {
      return 'Chef Tip: Do not overcrowd the pan; sear in batches to achieve a rich golden crust.';
    }
    if (lower.contains('taze')) {
      return 'Chef Tip: Add delicate herbs at the very end to retain their peak aroma and vibrant green color.';
    }
    if (lower.contains('dinlen')) {
      return 'Chef Tip: Resting before serving lets natural moisture redistribute evenly for juicy results.';
    }

    return 'Chef Tip: Taste and adjust seasoning right before serving for the most balanced flavor.';
  }
}
