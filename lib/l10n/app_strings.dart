import 'translations_data.dart';

class AppStrings {
  final String locale;
  final Map<String, String> _strings;

  AppStrings(this.locale) : _strings = _resolveMap(locale);

  static Map<String, String> _resolveMap(String loc) {
    // 1. Exact match (e.g. 'zh_CN', 'pt_BR', 'en', 'tr')
    if (appTranslations.containsKey(loc)) {
      return appTranslations[loc]!;
    }

    // 2. Normalized match (replace hyphen with underscore, case-insensitive)
    final clean = loc.replaceAll('-', '_');
    for (final entry in appTranslations.entries) {
      if (entry.key.toLowerCase() == clean.toLowerCase()) {
        return entry.value;
      }
    }

    // 3. Fallback to base language code (e.g. 'en_US' -> 'en', 'tr_TR' -> 'tr')
    final langPart = clean.split('_').first.toLowerCase();
    for (final entry in appTranslations.entries) {
      if (entry.key.toLowerCase() == langPart) {
        return entry.value;
      }
    }

    // 4. Default fallback: English
    return appTranslations['en']!;
  }

  String _get(String key, [String? fallback]) {
    return _strings[key] ?? appTranslations['en']?[key] ?? fallback ?? key;
  }

  bool get isTurkish => locale.toLowerCase().startsWith('tr');
  bool get isRtl => locale.toLowerCase().startsWith('ar');

  // Navigation
  String get tabDiscover => _get('tabDiscover', 'Discover');
  String get tabPantry => _get('tabPantry', 'Pantry');
  String get tabAccount => _get('tabAccount', 'Account');

  // App Header
  String get appTitle => _get('appTitle', 'AreWeCookin');
  String get appSubtitle => _get('appSubtitle', '10,000+ Beginner-Friendly Recipes');

  // Search
  String get searchPlaceholder => _get('searchPlaceholder', 'Search 10,000+ recipes (e.g. soup, pasta, steak)...');

  // Cuisines Header & Names
  String get worldCuisines => _get('worldCuisines', 'World Cuisines');
  String get cuisineAll => _get('cuisineAll', 'All');
  String get cuisineTurkish => _get('cuisineTurkish', 'Turkish');
  String get cuisineItalian => _get('cuisineItalian', 'Italian');
  String get cuisineAsian => _get('cuisineAsian', 'Asian & Far East');
  String get cuisineMexican => _get('cuisineMexican', 'Mexican');
  String get cuisineMediterranean => _get('cuisineMediterranean', 'Mediterranean');
  String get cuisineFrenchWorld => _get('cuisineFrenchWorld', 'French & World');
  String get cuisineStreet => _get('cuisineStreet', 'Street & Quick');

  // Categories
  String get catAll => _get('catAll', 'All');
  String get catMain => _get('catMain', 'Main Dish');
  String get catDessert => _get('catDessert', 'Dessert');
  String get catSoup => _get('catSoup', 'Soup');
  String get catBreakfast => _get('catBreakfast', 'Breakfast');
  String get catQuick => _get('catQuick', 'Quick & Easy');
  String get catBakery => _get('catBakery', 'Pastry & Bakery');
  String get catSalad => _get('catSalad', 'Salad');
  String get catVegan => _get('catVegan', 'Vegan');

  // Recipe Details
  String get minutes => _get('minutes', 'min');
  String get servings => _get('servings', 'Servings');
  String get ingredients => _get('ingredients', 'Ingredients');
  String get prepTime => _get('prepTime', 'Prep Time');
  String get cookTime => _get('cookTime', 'Cook Time');
  String get totalTime => _get('totalTime', 'Total Time');
  String get difficulty => _get('difficulty', 'Difficulty');
  String get diffEasy => _get('diffEasy', 'Easy');
  String get diffMedium => _get('diffMedium', 'Medium');
  String get diffHard => _get('diffHard', 'Hard');
  String get ingredientsTitle => _get('ingredientsTitle', 'Required Ingredients');
  String get stepsTitle => _get('stepsTitle', 'Cooking Steps');
  String get substitutionsTitle => _get('substitutionsTitle', 'Smart Ingredient Substitutions');
  String get startCooking => _get('startCooking', 'Start Cooking Mode');
  String get proTip => _get('proTip', "Chef's Pro-Tip");
  String get step => _get('step', 'Step');
  String get startTimer => _get('startTimer', 'Start Timer');
  String get pauseTimer => _get('pauseTimer', 'Pause');
  String get resetTimer => _get('resetTimer', 'Reset');
  String get finishCooking => _get('finishCooking', 'Finish Cooking');
  String get congratulations => _get('congratulations', 'Congratulations Chef!');

  // Pantry Screen
  String get smartPantry => _get('smartPantry', 'Smart Pantry');
  String get pantrySubtitle => _get('pantrySubtitle', 'Select items in your kitchen, we will find matching recipes.');
  String get whichCuisineQuestion => _get('whichCuisineQuestion', 'Which cuisine are you cooking today?');
  String get matchingRecipes => _get('matchingRecipes', 'Matching Recipes');
  String get matchRate => _get('matchRate', 'Match');
  String get clearAll => _get('clearAll', 'Clear All');
  String get noRecipesFound => _get('noRecipesFound', 'No matching recipes found');

  // Account & Auth
  String get myAccount => _get('myAccount', 'My Account');
  String get loginPrompt => _get('loginPrompt', 'Sign in to sync your favorites and pantry.');
  String get googleAutoLogin => _get('googleAutoLogin', 'Continue with Google');
  String get orEmail => _get('orEmail', 'or with email');
  String get signIn => _get('signIn', 'Sign In');
  String get signUp => _get('signUp', 'Sign Up');
  String get email => _get('email', 'Email Address');
  String get password => _get('password', 'Password');
  String get fullName => _get('fullName', 'Full Name');
  String get signOut => _get('signOut', 'Sign Out');
  String get languageSelection => _get('languageSelection', 'App Language');
  String get welcomeUser => _get('welcomeUser', 'Welcome');
  String get guestUser => _get('guestUser', 'Guest Cook');
  String get savedRecipes => _get('savedRecipes', 'Favorites');
  String get cookedDishes => _get('cookedDishes', 'Cooked');
  String get accountSecurity => _get('accountSecurity', 'Account & Security');
  String get appPreferences => _get('appPreferences', 'Preferences');
  String get invalidEmail => _get('invalidEmail', 'Please enter a valid email');
  String get passwordLength => _get('passwordLength', 'Password must be at least 6 characters');
  String get enterName => _get('enterName', 'Please enter your name');

  // Splash
  String get splashTagline => _get('splashTagline', "What are we cookin' today?");
  String get splashLoading => _get('splashLoading', 'Preparing the kitchen...');

  // Phone Auth
  String get phoneAuth => _get('phoneAuth', 'Phone Sign In');
  String get phoneNumber => _get('phoneNumber', 'Phone Number');
  String get enterPhoneNumber => _get('enterPhoneNumber', 'Enter phone number (+1...)');
  String get sendOtp => _get('sendOtp', 'Send Verification Code');
  String get verificationCode => _get('verificationCode', 'Verification Code');
  String get enterOtp => _get('enterOtp', 'Enter 6-digit SMS code');
  String get verifyOtp => _get('verifyOtp', 'Verify & Sign In');
  String get invalidPhone => _get('invalidPhone', 'Enter a valid phone number');
  String get invalidOtp => _get('invalidOtp', 'Please enter the 6-digit code');

  // Account Management & Security
  String get changePassword => _get('changePassword', 'Change Password');
  String get newPassword => _get('newPassword', 'New Password');
  String get changeEmail => _get('changeEmail', 'Change Email');
  String get newEmail => _get('newEmail', 'New Email Address');
  String get deleteAccount => _get('deleteAccount', 'Delete Account');
  String get deleteAccountTitle => _get('deleteAccountTitle', 'Delete Your Account?');
  String get deleteAccountConfirm => _get('deleteAccountConfirm', 'Your account and all saved recipes will be permanently deleted. This action cannot be undone!');
  String get deleteAccountAction => _get('deleteAccountAction', 'Yes, Delete Account');
  String get cancel => _get('cancel', 'Cancel');
  String get saveChanges => _get('saveChanges', 'Save');
  String get editProfile => _get('editProfile', 'Edit Profile');
  String get updateName => _get('updateName', 'Change Name');
  String get profileUpdated => _get('profileUpdated', 'Profile updated successfully.');
  String get passwordUpdated => _get('passwordUpdated', 'Password updated successfully.');
  String get emailUpdated => _get('emailUpdated', 'Email address updated.');
  String get accountDeleted => _get('accountDeleted', 'Account deleted successfully.');

  // Add Recipe & Recipe Management
  String get addRecipe => _get('addRecipe', 'Add Recipe');
  String get newRecipe => _get('newRecipe', 'Share New Recipe');
  String get recipeTitle => _get('recipeTitle', 'Recipe Title');
  String get enterRecipeTitle => _get('enterRecipeTitle', "e.g. Grandma's Lentil Soup");
  String get recipeCategory => _get('recipeCategory', 'Category');
  String get recipeCuisine => _get('recipeCuisine', 'Cuisine');
  String get prepTimeMinutes => _get('prepTimeMinutes', 'Prep (min)');
  String get cookTimeMinutes => _get('cookTimeMinutes', 'Cook (min)');
  String get servingsCount => _get('servingsCount', 'Servings');
  String get imageUrlOptional => _get('imageUrlOptional', 'Image URL (Optional)');
  String get addIngredient => _get('addIngredient', 'Add Ingredient');
  String get ingredientName => _get('ingredientName', 'Ingredient name (e.g. Olive oil)');
  String get ingredientAmount => _get('ingredientAmount', 'Amount (e.g. 2)');
  String get ingredientUnit => _get('ingredientUnit', 'Unit (tbsp, cup, g)');
  String get addStep => _get('addStep', 'Add Step');
  String get stepInstruction => _get('stepInstruction', 'Step instructions...');
  String get stepTimerOptional => _get('stepTimerOptional', 'Timer (min, optional)');
  String get publishRecipe => _get('publishRecipe', 'Publish Recipe');
  String get recipePublishedSuccess => _get('recipePublishedSuccess', 'Your recipe has been published!');
  String get loginRequiredToPublish => _get('loginRequiredToPublish', 'Sign In to Add Recipes');
  String get loginToPublishMsg => _get('loginToPublishMsg', 'Please sign in or create an account to share your recipes with the community.');
  String get mySavedRecipes => _get('mySavedRecipes', 'Saved Recipes');
  String get myCreatedRecipes => _get('myCreatedRecipes', 'My Recipes');
  String get noSavedRecipesYet => _get('noSavedRecipesYet', 'No saved recipes yet.');
  String get noCreatedRecipesYet => _get('noCreatedRecipesYet', "You haven't added any recipes yet. Share your first recipe!");
  String get exploreRecipes => _get('exploreRecipes', 'Explore Recipes');
  String get removeFavorite => _get('removeFavorite', 'Remove Favorite');
  String get addedToFavorites => _get('addedToFavorites', 'Recipe added to favorites!');
  String get removedFromFavorites => _get('removedFromFavorites', 'Recipe removed from favorites.');
}
