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
  String get tabSocial => _get('tabSocial', 'Community');
  String get socialNewPost => _get('socialNewPost', 'Share a recipe');
  String get socialEmpty => _get('socialEmpty', 'No posts yet. Be the first to share a recipe!');
  String get socialSignInToShare => _get('socialSignInToShare', 'Sign in from the Account tab to share, like or comment');
  String get socialPostTitleHint => _get('socialPostTitleHint', 'Recipe name');
  String get socialPostTextHint => _get('socialPostTextHint', 'Tell us about it');
  String get socialPublish => _get('socialPublish', 'Share');
  String get socialLike => _get('socialLike', 'Like');
  String get socialComments => _get('socialComments', 'Comments');
  String get socialCommentHint => _get('socialCommentHint', 'Write a comment');
  String get socialUnavailable => _get('socialUnavailable', 'Community is unavailable right now');
  String get tabAccount => _get('tabAccount', 'Account');
  String get shoppingListTitle => _get('shoppingListTitle', 'Shopping list');
  String get shoppingClearDone => _get('shoppingClearDone', 'Clear checked');
  String get savedSortQuick => _get('savedSortQuick', 'Quickest first');
  String get mealPlanRemove => _get('mealPlanRemove', 'Remove from plan');
  String get servingsReset => _get('servingsReset', 'Original servings');
  String get pantryFullOnly => _get('pantryFullOnly', 'Full matches only');
  String get todayInPlan => _get('todayInPlan', 'Planned for today');
  String get shoppingDeleteItem => _get('shoppingDeleteItem', 'Delete item');
  String get cookTextSize => _get('cookTextSize', 'Text size');
  String timerLeft(int mins) => _get('timerLeftFmt', '~{n} min of timers left').replaceAll('{n}', '$mins');
  String get savedSortRating => _get('savedSortRating', 'My top rated');
  String get mealPlanMove => _get('mealPlanMove', 'Move to another day');
  String resumeCooking(int step) => _get('resumeCookingFmt', 'Resume cooking (step {n})').replaceAll('{n}', '$step');
  String get listCleared => _get('listCleared', 'List cleared');
  String get shoppingEditItem => _get('shoppingEditItem', 'Edit item (e.g. 2 kg milk)');
  String get shoppingHint => _get('shoppingHint', 'Long-press to edit, swipe to delete');
  String plannedOn(String days) => _get('plannedOnFmt', 'Planned: {days}').replaceAll('{days}', days);
  String get doneTitle => _get('doneTitle', 'Well done! 🎉');
  String doneBody(String title) => _get('doneBodyFmt', 'You finished {title}. Enjoy your meal!').replaceAll('{title}', title);
  String get doneBack => _get('doneBack', 'Back to recipes');
  String get doneRate => _get('doneRate', 'How was it? Rate it');
  String get needIngredient => _get('needIngredient', 'Please add at least one ingredient.');
  String get needStep => _get('needStep', 'Please add at least one preparation step.');
  String get pantryCustomHint => _get('pantryCustomHint', 'Add another ingredient (e.g. mushroom, eggplant)...');
  String get phoneInvalid => _get('phoneInvalid', 'Please enter a valid phone number.');
  String get codeInvalid => _get('codeInvalid', 'Please enter the 6-digit verification code.');
  String get masterScore => _get('masterScore', 'Cook score');
  String get editNameHint => _get('editNameHint', 'Edit your visible profile name');
  String get securityHint => _get('securityHint', 'Keep your account secure');
  String get deleteDataHint => _get('deleteDataHint', 'Delete the account and all data');
  String get noEmail => _get('noEmail', 'No email set');
  String get orOtherOptions => _get('orOtherOptions', 'or other options');
  String codeSent(String phone) => _get('codeSentFmt', 'A code was sent to {phone}.').replaceAll('{phone}', phone);
  String get changeLabel => _get('changeLabel', 'Change');
  String get notifTitle => _get('notifTitle', 'Cooking notifications');
  String get notifDesc => _get('notifDesc', 'Step timers and recipe tips');
  String get shoppingToggleAll => _get('shoppingToggleAll', 'Check / uncheck all');
  String get similarRecipes => _get('similarRecipes', 'Similar recipes');
  String nextStepPreview(String title) => _get('nextStepFmt', 'Next: {title}').replaceAll('{title}', title);
  String get shoppingToPantry => _get('shoppingToPantry', 'Add checked to pantry');
  String pantryAdded(int n) => _get('pantryAddedFmt', '{n} ingredients added to pantry').replaceAll('{n}', '$n');
  String get quickEasy => _get('quickEasy', 'Quick & easy');
  String get planFromSaved => _get('planFromSaved', 'Add from favorites');
  String get planFromSavedEmpty => _get('planFromSavedEmpty', 'Save a recipe to favorites first.');
  String get togglePassword => _get('togglePassword', 'Show / hide password');
  String get timerSoundOn => _get('timerSoundOn', 'Timer sound on');
  String get timerSoundOff => _get('timerSoundOff', 'Timer sound off');
  String get cookedFilterEmpty => _get('cookedFilterEmpty', 'You have not cooked anything yet. Finish cooking mode and it shows up here.');
  String get tickPantryIngredients => _get('tickPantryIngredients', 'Tick what is in my pantry');
  String pantryCoverage(int n, int total) => _get('pantryCoverageFmt', '{n} of {total} ingredients in your pantry').replaceAll('{n}', '$n').replaceAll('{total}', '$total');
  String get inPantryLabel => _get('inPantryLabel', 'In your pantry');
  String get shoppingManual => _get('shoppingManual', 'Added by hand');
  String get shoppingClearAll => _get('shoppingClearAll', 'Clear list');
  String get shoppingClearAllConfirm => _get('shoppingClearAllConfirm', 'Remove all items from the shopping list?');
  String get shoppingEmptyTitle => _get('shoppingEmptyTitle', 'Your list is empty');
  String get shoppingEmptyHint => _get('shoppingEmptyHint', 'Open a recipe and add ingredients to your list.');
  String get shoppingAdd => _get('shoppingAdd', 'Add to shopping list');
  String get shoppingNothingNew => _get('shoppingNothingNew', 'Everything is already on your list');
  String get timeAny => _get('timeAny', 'Any time');
  String timeUpTo(int n) => _get('timeUpTo', '{n} min').replaceAll('{n}', '$n');
  String get mealPlanTitle => _get('mealPlanTitle', 'Meal plan');
  String get mealPlanClearDay => _get('mealPlanClearDay', 'Clear this day');
  String get mealPlanCopyDay => _get('mealPlanCopyDay', 'Copy this day to another day');
  String get mealPlanDayToList => _get('mealPlanDayToList', 'Add this day\'s ingredients to shopping list');
  String get mealPlanToList => _get('mealPlanToList', 'Add all ingredients to shopping list');
  String get mealPlanEmptyTitle => _get('mealPlanEmptyTitle', 'No meals planned');
  String get mealPlanEmptyHint => _get('mealPlanEmptyHint', 'Open a recipe and add it to your meal plan.');
  String get mealPlanAdd => _get('mealPlanAdd', 'Add to meal plan');
  String get mealPlanPickDay => _get('mealPlanPickDay', 'Pick a day');
  String get mealPlanAlready => _get('mealPlanAlready', 'Already planned for that day');
  String mealPlanAddedTo(String day) => _get('mealPlanAddedTo', 'Added to {day}').replaceAll('{day}', day);
  String weekdayName(int d) => _get('wd$d', const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][(d - 1) % 7]);
  String get shoppingAddHint => _get('shoppingAddHint', 'Add an item');
  String get shoppingCopy => _get('shoppingCopy', 'Copy list');
  String get shoppingCopied => _get('shoppingCopied', 'List copied to clipboard');
  String get surpriseMe => _get('surpriseMe', 'Surprise me');
  String get recentlyViewed => _get('recentlyViewed', 'Recently viewed');
  String get a11ySave => _get('a11ySave', 'Save recipe');
  String get a11yFewer => _get('a11yFewer', 'Fewer servings');
  String get a11yMore => _get('a11yMore', 'More servings');
  String get a11yClear => _get('a11yClear', 'Clear search');
  String get a11yClose => _get('a11yClose', 'Close');
  String timerDoneFor(int n) => _get('timerDone', 'Step {n} timer finished!').replaceAll('{n}', '$n');
  String timersElsewhere(int n) => _get('timersRunningElsewhere', 'Timers running in other steps: {n}').replaceAll('{n}', '$n');
  String get copyRecipe => _get('copyRecipe', 'Copy recipe as text');
  String get recipeCopied => _get('recipeCopied', 'Recipe copied to clipboard');
  String get todayLabel => _get('todayLabel', 'Today');
  String get mealPlanClear => _get('mealPlanClear', 'Clear plan');
  String get mealPlanClearConfirm => _get('mealPlanClearConfirm', 'Remove all planned meals?');
  String pantryHeader(int n) => _get('pantryHeaderFmt', 'What is in your kitchen? ({n} selected)').replaceAll('{n}', '$n');
  String get pantryHint => _get('pantryHint', 'Select or add the ingredients you have. Filter by cuisine to instantly find recipes you can make.');
  String get savedOnly => _get('savedOnly', 'Saved');
  String get savedFilterEmpty => _get('savedFilterEmpty', 'No saved recipes yet. Tap the bookmark on a recipe to save it.');
  String get shoppingAddMissing => _get('shoppingAddMissing', 'Add missing to shopping list');
  String get diffFilterEasy => _get('diffFilterEasy', 'Easy');
  String get diffFilterMedium => _get('diffFilterMedium', 'Medium');
  String get diffFilterHard => _get('diffFilterHard', 'Hard');
  String get myNotes => _get('myNotes', 'My notes');
  String get myNotesHint => _get('myNotesHint', 'Your tweaks, tips, who liked it...');
  String rateStarFor(int n) => _get('rateStar', 'Rate {n} stars').replaceAll('{n}', '$n');
  String get unitMetric => _get('unitMetric', 'Metric');
  String get unitImperial => _get('unitImperial', 'US units');
  String get planCopy => _get('planCopy', 'Copy plan as text');
  String get planCopied => _get('planCopied', 'Plan copied to clipboard');
  String get recentSearches => _get('recentSearches', 'Recent searches');
  String get clearHistory => _get('clearHistory', 'Clear history');
  String get cookedOnce => _get('cookedOnce', 'Cooked once');
  String cookedTimes(int n) => n == 1 ? cookedOnce : _get('cookedTimesFmt', 'Cooked {n} times').replaceAll('{n}', '$n');
  String get undoLabel => _get('undoLabel', 'Undo');
  String get itemRemoved => _get('itemRemoved', 'Item removed');
  String get shoppingOpen => _get('shoppingOpen', 'Open');
  String shoppingAdded(int n) => _get('shoppingAdded', '{n} items added to your list').replaceAll('{n}', '$n');

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
  String minutesShort(int mins) => '$mins $minutes';
  String servingsFormat(int count) => '$count $servings';
  String ingredientsCountFormat(int count) => '$count $ingredients';
  String get prepTime => _get('prepTime', 'Prep Time');
  String get cookTime => _get('cookTime', 'Cook Time');
  String get totalTime => _get('totalTime', 'Total Time');
  String get difficulty => _get('difficulty', 'Difficulty');
  String get diffVeryEasy => _get('diffVeryEasy', 'Very Easy');
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
  String get stepTimer => _get('stepTimer', 'Step Timer');
  String get stepFreePrep => _get('stepFreePrep', 'This step is untimed preparation, no timer needed.');
  String get nextStep => _get('nextStep', 'Next Step');
  String get prevStep => _get('prevStep', 'Previous Step');
  String get stepIngredientsUsed => _get('stepIngredientsUsed', 'Ingredients For This Step:');
  String get ready => _get('ready', 'ready');
  String get selectAll => _get('selectAll', 'Select All');
  String get add => _get('add', 'Add');
  String get insteadOf => _get('insteadOf', 'instead of');
  String get loadingMoreRecipes => _get('loadingMoreRecipes', 'Loading more recipes...');
  String get resetFilters => _get('resetFilters', 'Reset Filters');
  String get tryDifferentFilter => _get('tryDifferentFilter', 'Try a different search term or reset filters.');

  // Pantry Screen
  String get smartPantry => _get('smartPantry', 'Smart Pantry');
  String get pantrySubtitle => _get('pantrySubtitle', 'Select items in your kitchen, we will find matching recipes.');
  String get whichCuisineQuestion => _get('whichCuisineQuestion', 'Which cuisine are you cooking today?');
  String get matchingRecipes => _get('matchingRecipes', 'Matching Recipes');
  String get matchRate => _get('matchRate', 'Match');
  String get clearAll => _get('clearAll', 'Clear All');
  String get loadErrorTitle => _get('loadErrorTitle', 'Could not load recipes');
  String get retry => _get('retry', 'Try again');
  String get discardRecipeTitle => _get('discardRecipeTitle', 'Discard this recipe draft?');
  String get discardRecipeAction => _get('discardRecipeAction', 'Discard');
  String get recipeTitleRequired => _get('recipeTitleRequired', 'Please enter a recipe name');
  String get amountHint => _get('amountHint', 'Amount');
  String get householdServings => _get('householdServings', 'Default servings');
  String get householdOff => _get('householdOff', 'Use each recipe\'s own');
  String get avoidedTitle => _get('avoidedTitle', 'Ingredients I avoid');
  String get avoidedHint => _get('avoidedHint', 'Recipes with these never show up in Discover.');
  String get avoidedField => _get('avoidedField', 'e.g. peanut, milk');
  String avoidedWarning(String words) => _get('avoidedWarningFmt', 'Contains something you avoid: {w}').replaceAll('{w}', words);
  String mealsCount(int n) => _get('mealsCountFmt', 'Meals: {n}').replaceAll('{n}', '$n');
  String get shoppingCheckGroup => _get('shoppingCheckGroup', 'Check off this group');
  String get allSteps => _get('allSteps', 'All steps');
  String resultsCount(int n, bool more) => _get('resultsCountFmt', '{n} recipes').replaceAll('{n}', more ? '$n+' : '$n');
  String get shoppingEdited => _get('shoppingEdited', 'Item updated');
  String tryWord(String w) => _get('tryWordFmt', 'Try only “{w}”').replaceAll('{w}', w);
  String get ingredientHoldHint => _get('ingredientHoldHint', 'Tip: long-press an ingredient to avoid it');
  String get savedSearchHint => _get('savedSearchHint', 'Search saved recipes');
  String get pantryNothingNew => _get('pantryNothingNew', 'Already in your pantry');
  String get searchTip => _get('searchTip', 'Tip: separate ingredients with commas (tomato, onion) and exclude one with a minus (-milk).');
  String get noRecipesFound => _get('noRecipesFound', 'No matching recipes found');
  String get pantryEmptyTitle => _get('pantryEmptyTitle', 'Your pantry looks empty');
  String get pantryEmptyDesc => _get('pantryEmptyDesc', 'Select ingredients from above. Matching dishes will be listed instantly according to your cuisine preference.');
  String get onlyFullMatches => _get('onlyFullMatches', '100% Match Only');
  String get allIngredientsReady => _get('allIngredientsReady', 'All ingredients ready in your pantry! You can cook now.');
  String get missingIngredients => _get('missingIngredients', 'Missing');
  String get substitutionSuggestion => _get('substitutionSuggestion', 'Substitution Suggestion');

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
  String get ticksCleared => _get('ticksCleared', 'Ticks cleared');
  String get ratedDishes => _get('ratedDishes', 'Rated');
  String get ratedFilterEmpty => _get('ratedFilterEmpty', 'You have not rated any recipe yet. Give stars on a recipe page and it shows up here.');
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
  String get editRecipe => _get('editRecipe', 'Edit recipe');
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
