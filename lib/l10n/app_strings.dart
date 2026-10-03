class AppStrings {
  final String locale;

  const AppStrings(this.locale);

  bool get isTurkish => locale == 'tr';

  // Navigation
  String get tabDiscover => isTurkish ? 'Keşfet' : 'Discover';
  String get tabPantry => isTurkish ? 'Kilerim' : 'Pantry';
  String get tabAccount => isTurkish ? 'Hesabım' : 'Account';

  // App Header
  String get appTitle => 'AreWeCookin';
  String get appSubtitle => isTurkish ? '10.000+ Acemi Dostu Tarif' : '10,000+ Beginner-Friendly Recipes';

  // Search
  String get searchPlaceholder => isTurkish
      ? '10.000+ tarif ara (örn: çorba, kek, pirzola)...'
      : 'Search 10,000+ recipes (e.g. soup, cake)...';

  // Cuisines Header & Names
  String get worldCuisines => isTurkish ? 'Dünya Mutfakları' : 'World Cuisines';
  String get cuisineAll => isTurkish ? 'Tümü' : 'All';
  String get cuisineTurkish => isTurkish ? 'Türk Mutfağı' : 'Turkish';
  String get cuisineItalian => isTurkish ? 'İtalyan' : 'Italian';
  String get cuisineAsian => isTurkish ? 'Asya & Uzak Doğu' : 'Asian';
  String get cuisineMexican => isTurkish ? 'Meksika' : 'Mexican';
  String get cuisineMediterranean => isTurkish ? 'Akdeniz' : 'Mediterranean';
  String get cuisineFrenchWorld => isTurkish ? 'Fransız & Dünya' : 'French & World';
  String get cuisineStreet => isTurkish ? 'Pratik & Sokak' : 'Street & Quick';

  // Categories
  String get catAll => isTurkish ? 'Tümü' : 'All';
  String get catMain => isTurkish ? 'Ana Yemek' : 'Main Dish';
  String get catDessert => isTurkish ? 'Tatlı' : 'Dessert';
  String get catSoup => isTurkish ? 'Çorba' : 'Soup';
  String get catBreakfast => isTurkish ? 'Kahvaltılık' : 'Breakfast';
  String get catQuick => isTurkish ? 'Pratik' : 'Quick & Easy';
  String get catBakery => isTurkish ? 'Hamur İşi' : 'Pastry & Bakery';
  String get catSalad => isTurkish ? 'Salata' : 'Salad';
  String get catVegan => isTurkish ? 'Vegan' : 'Vegan';

  // Recipe Details
  String get minutes => isTurkish ? 'dk' : 'min';
  String get servings => isTurkish ? 'Kişilik' : 'Servings';
  String get ingredients => isTurkish ? 'Malzeme' : 'Ingredients';
  String get prepTime => isTurkish ? 'Hazırlık' : 'Prep Time';
  String get cookTime => isTurkish ? 'Pişirme' : 'Cook Time';
  String get totalTime => isTurkish ? 'Toplam Süre' : 'Total Time';
  String get difficulty => isTurkish ? 'Zorluk' : 'Difficulty';
  String get diffEasy => isTurkish ? 'Kolay' : 'Easy';
  String get diffMedium => isTurkish ? 'Orta' : 'Medium';
  String get diffHard => isTurkish ? 'Zor' : 'Hard';
  String get ingredientsTitle => isTurkish ? 'Gerekli Malzemeler' : 'Required Ingredients';
  String get stepsTitle => isTurkish ? 'Pişirme Adımları' : 'Cooking Steps';
  String get substitutionsTitle => isTurkish ? 'Akıllı Malzeme Değişimleri' : 'Smart Ingredient Substitutions';
  String get startCooking => isTurkish ? 'Pişirme Modunu Başlat' : 'Start Cooking Mode';
  String get proTip => isTurkish ? 'Şefin Püf Noktası' : "Chef's Pro-Tip";
  String get step => isTurkish ? 'Adım' : 'Step';
  String get startTimer => isTurkish ? 'Sayacı Başlat' : 'Start Timer';
  String get pauseTimer => isTurkish ? 'Durdur' : 'Pause';
  String get resetTimer => isTurkish ? 'Sıfırla' : 'Reset';
  String get finishCooking => isTurkish ? 'Pişirmeyi Tamamla' : 'Finish Cooking';
  String get congratulations => isTurkish ? 'Tebrikler Şef!' : 'Congratulations Chef!';

  // Pantry Screen
  String get smartPantry => isTurkish ? 'Akıllı Kiler' : 'Smart Pantry';
  String get pantrySubtitle => isTurkish
      ? 'Dolabındaki malzemeleri seç, sana en uygun yemekleri bulalım.'
      : 'Select items in your kitchen, we will find matching recipes.';
  String get whichCuisineQuestion => isTurkish ? 'Hangi Mutfakta Yemek Pişireceksiniz?' : 'Which cuisine are you cooking today?';
  String get matchingRecipes => isTurkish ? 'Eşleşen Tarifler' : 'Matching Recipes';
  String get matchRate => isTurkish ? 'Eşleşme' : 'Match';
  String get clearAll => isTurkish ? 'Temizle' : 'Clear All';
  String get noRecipesFound => isTurkish ? 'Eşleşen tarif bulunamadı' : 'No matching recipes found';

  // Account & Auth
  String get myAccount => isTurkish ? 'Hesabım' : 'My Account';
  String get loginPrompt => isTurkish ? 'Favorilerini ve kilerini kaydetmek için giriş yap.' : 'Sign in to sync your favorites and pantry.';
  String get googleAutoLogin => isTurkish ? 'Google ile Otomatik Giriş' : 'Continue with Google';
  String get orEmail => isTurkish ? 'veya e-posta ile' : 'or with email';
  String get signIn => isTurkish ? 'Giriş Yap' : 'Sign In';
  String get signUp => isTurkish ? 'Kayıt Ol' : 'Sign Up';
  String get email => isTurkish ? 'E-posta Adresi' : 'Email Address';
  String get password => isTurkish ? 'Şifre' : 'Password';
  String get fullName => isTurkish ? 'Ad Soyad' : 'Full Name';
  String get signOut => isTurkish ? 'Çıkış Yap' : 'Sign Out';
  String get languageSelection => isTurkish ? 'Uygulama Dili' : 'App Language';
  String get welcomeUser => isTurkish ? 'Hoş Geldiniz' : 'Welcome';
  String get guestUser => isTurkish ? 'Misafir Kullanıcı' : 'Guest Cook';
  String get savedRecipes => isTurkish ? 'Favoriler' : 'Favorites';
  String get cookedDishes => isTurkish ? 'Pişirilenler' : 'Cooked';
  String get accountSecurity => isTurkish ? 'Hesap & Güvenlik' : 'Account & Security';
  String get appPreferences => isTurkish ? 'Tercihler' : 'Preferences';
  String get invalidEmail => isTurkish ? 'Geçerli bir e-posta adresi girin' : 'Please enter a valid email';
  String get passwordLength => isTurkish ? 'Şifre en az 6 karakter olmalı' : 'Password must be at least 6 characters';
  String get enterName => isTurkish ? 'Lütfen adınızı girin' : 'Please enter your name';
}
