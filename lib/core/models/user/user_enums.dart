/// User roles in the app
enum UserRole {
  rider,
  driver,
  pending
  ;

  String get displayName {
    switch (this) {
      case UserRole.rider:
        return 'Rider';
      case UserRole.driver:
        return 'Driver';
      case UserRole.pending:
        return 'Pending';
    }
  }

  String get description {
    switch (this) {
      case UserRole.rider:
        return 'Find and book rides to sporting events';
      case UserRole.driver:
        return 'Offer rides and earn money';
      case UserRole.pending:
        return 'Your application is under review';
    }
  }
}

/// User levels based on XP
enum UserLevel {
  bronze(0, 1000, 'Bronze', 1),
  silver(1000, 5000, 'Silver', 2),
  gold(5000, 15000, 'Gold', 3),
  platinum(15000, 35000, 'Platinum', 4),
  diamond(35000, double.infinity, 'Diamond', 5)
  ;

  final double minXP;
  final double maxXP;
  final String name;
  final int level;

  const UserLevel(this.minXP, this.maxXP, this.name, this.level);

  static UserLevel fromXP(int xp) {
    for (final level in UserLevel.values.reversed) {
      if (xp >= level.minXP) return level;
    }
    return UserLevel.bronze;
  }

  String get displayName => name;

  String get description {
    switch (this) {
      case UserLevel.bronze:
        return 'Bronze level user';
      case UserLevel.silver:
        return 'Silver level user';
      case UserLevel.gold:
        return 'Gold level user';
      case UserLevel.platinum:
        return 'Platinum level user';
      case UserLevel.diamond:
        return 'Diamond level user';
    }
  }
}

/// Expertise ranks for users
enum Expertise {
  rookie('Rookie'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  expert('Expert')
  ;

  final String displayName;

  const Expertise(this.displayName);

  String get displayValue => displayName;
}

enum AppLocale {
  english('en'),
  french('fr')
  ;

  final String code;

  const AppLocale(this.code);
}
