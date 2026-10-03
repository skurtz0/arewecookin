class UserProfile {
  final String id;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final String authProvider; // 'google', 'password', 'phone', 'guest'
  final bool isLoggedIn;
  final int savedRecipesCount;
  final int cookedCount;

  const UserProfile({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    required this.authProvider,
    required this.isLoggedIn,
    this.savedRecipesCount = 0,
    this.cookedCount = 0,
  });

  static const guest = UserProfile(
    id: 'guest_user',
    email: '',
    phoneNumber: null,
    displayName: 'Misafir Aşçı',
    authProvider: 'guest',
    isLoggedIn: false,
    savedRecipesCount: 0,
    cookedCount: 0,
  );

  UserProfile copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    String? authProvider,
    bool? isLoggedIn,
    int? savedRecipesCount,
    int? cookedCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      savedRecipesCount: savedRecipesCount ?? this.savedRecipesCount,
      cookedCount: cookedCount ?? this.cookedCount,
    );
  }
}

