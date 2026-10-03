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

  // Splash
  String get splashTagline => isTurkish ? 'Bugün ne pişiriyoruz?' : 'What are we cookin\' today?';
  String get splashLoading => isTurkish ? 'Mutfak hazırlanıyor...' : 'Preparing the kitchen...';

  // Phone Auth
  String get phoneAuth => isTurkish ? 'Telefon ile Giriş' : 'Phone Sign In';
  String get phoneNumber => isTurkish ? 'Telefon Numarası' : 'Phone Number';
  String get enterPhoneNumber => isTurkish ? 'Telefon numaranızı girin (+90...)' : 'Enter phone number (+1...)';
  String get sendOtp => isTurkish ? 'Doğrulama Kodu Gönder' : 'Send Verification Code';
  String get verificationCode => isTurkish ? 'Doğrulama Kodu' : 'Verification Code';
  String get enterOtp => isTurkish ? '6 haneli SMS kodunu girin' : 'Enter 6-digit SMS code';
  String get verifyOtp => isTurkish ? 'Kodu Onayla ve Giriş Yap' : 'Verify & Sign In';
  String get invalidPhone => isTurkish ? 'Geçerli bir telefon numarası girin' : 'Enter a valid phone number';
  String get invalidOtp => isTurkish ? 'Lütfen 6 haneli kodu eksiksiz girin' : 'Please enter the 6-digit code';

  // Account Management & Security
  String get changePassword => isTurkish ? 'Şifre Değiştir' : 'Change Password';
  String get newPassword => isTurkish ? 'Yeni Şifre' : 'New Password';
  String get changeEmail => isTurkish ? 'E-posta Değiştir' : 'Change Email';
  String get newEmail => isTurkish ? 'Yeni E-posta Adresi' : 'New Email Address';
  String get deleteAccount => isTurkish ? 'Hesabı Sil' : 'Delete Account';
  String get deleteAccountTitle => isTurkish ? 'Hesabınızı Silmek İstiyor Musunuz?' : 'Delete Your Account?';
  String get deleteAccountConfirm => isTurkish
      ? 'Hesabınız ve tüm kaydedilen tarifleriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz!'
      : 'Your account and all saved recipes will be permanently deleted. This action cannot be undone!';
  String get deleteAccountAction => isTurkish ? 'Evet, Hesabımı Sil' : 'Yes, Delete Account';
  String get cancel => isTurkish ? 'İptal' : 'Cancel';
  String get saveChanges => isTurkish ? 'Kaydet' : 'Save';
  String get editProfile => isTurkish ? 'Profili Düzenle' : 'Edit Profile';
  String get updateName => isTurkish ? 'İsim Değiştir' : 'Change Name';
  String get profileUpdated => isTurkish ? 'Profil başarıyla güncellendi.' : 'Profile updated successfully.';
  String get passwordUpdated => isTurkish ? 'Şifreniz başarıyla güncellendi.' : 'Password updated successfully.';
  String get emailUpdated => isTurkish ? 'E-posta adresiniz güncellendi.' : 'Email address updated.';
  String get accountDeleted => isTurkish ? 'Hesabınız başarıyla silindi.' : 'Account deleted successfully.';

  // Add Recipe & Recipe Management
  String get addRecipe => isTurkish ? 'Tarif Ekle' : 'Add Recipe';
  String get newRecipe => isTurkish ? 'Yeni Tarif Paylaş' : 'Share New Recipe';
  String get recipeTitle => isTurkish ? 'Tarif Adı' : 'Recipe Title';
  String get enterRecipeTitle => isTurkish ? 'Örn: Anne Usulü Mercimek Çorbası' : 'e.g. Grandma\'s Lentil Soup';
  String get recipeCategory => isTurkish ? 'Kategori' : 'Category';
  String get recipeCuisine => isTurkish ? 'Mutfak' : 'Cuisine';
  String get prepTimeMinutes => isTurkish ? 'Hazırlık (dk)' : 'Prep (min)';
  String get cookTimeMinutes => isTurkish ? 'Pişirme (dk)' : 'Cook (min)';
  String get servingsCount => isTurkish ? 'Porsiyon' : 'Servings';
  String get imageUrlOptional => isTurkish ? 'Fotoğraf URL (İsteğe Bağlı)' : 'Image URL (Optional)';
  String get addIngredient => isTurkish ? 'Malzeme Ekle' : 'Add Ingredient';
  String get ingredientName => isTurkish ? 'Malzeme adı (örn: Zeytinyağı)' : 'Ingredient name (e.g. Olive oil)';
  String get ingredientAmount => isTurkish ? 'Miktar (örn: 2)' : 'Amount (e.g. 2)';
  String get ingredientUnit => isTurkish ? 'Birim (kaşık, bardak, gr)' : 'Unit (tbsp, cup, g)';
  String get addStep => isTurkish ? 'Adım Ekle' : 'Add Step';
  String get stepInstruction => isTurkish ? 'Adım açıklaması / talimatı...' : 'Step instructions...';
  String get stepTimerOptional => isTurkish ? 'Zamanlayıcı (dk, isteğe bağlı)' : 'Timer (min, optional)';
  String get publishRecipe => isTurkish ? 'Tarifi Yayınla' : 'Publish Recipe';
  String get recipePublishedSuccess => isTurkish ? 'Tarifiniz başarıyla yayınlandı!' : 'Your recipe has been published!';
  String get loginRequiredToPublish => isTurkish ? 'Tarif Eklemek İçin Giriş Yapın' : 'Sign In to Add Recipes';
  String get loginToPublishMsg => isTurkish
      ? 'Kendi lezzetli tariflerinizi toplulukla paylaşmak için lütfen giriş yapın veya kayıt olun.'
      : 'Please sign in or create an account to share your recipes with the community.';
  String get mySavedRecipes => isTurkish ? 'Kaydettiğim Tarifler' : 'Saved Recipes';
  String get myCreatedRecipes => isTurkish ? 'Eklediğim Tarifler' : 'My Recipes';
  String get noSavedRecipesYet => isTurkish ? 'Henüz kaydedilmiş bir tarifiniz yok.' : 'No saved recipes yet.';
  String get noCreatedRecipesYet => isTurkish ? 'Henüz eklediğiniz bir tarif yok. İlk tarifinizi hemen paylaşın!' : 'You haven\'t added any recipes yet. Share your first recipe!';
  String get exploreRecipes => isTurkish ? 'Tarifleri Keşfet' : 'Explore Recipes';
  String get removeFavorite => isTurkish ? 'Favorilerden Çıkar' : 'Remove Favorite';
  String get addedToFavorites => isTurkish ? 'Tarif favorilerinize eklendi!' : 'Recipe added to favorites!';
  String get removedFromFavorites => isTurkish ? 'Tarif favorilerden çıkarıldı.' : 'Recipe removed from favorites.';
}

