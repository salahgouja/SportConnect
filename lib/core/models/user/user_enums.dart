/// User roles in the app
enum UserRole {
  rider,
  driver;

  String get displayName {
    switch (this) {
      case UserRole.rider:
        return 'Rider';
      case UserRole.driver:
        return 'Driver';
    }
  }

  String get description {
    switch (this) {
      case UserRole.rider:
        return 'Find and book rides to sporting events';
      case UserRole.driver:
        return 'Offer rides and earn money';
    }
  }
}

/// User levels based on XP
enum UserLevel {
  bronze(0, 1000, 'Bronze', 1),
  silver(1000, 5000, 'Silver', 2),
  gold(5000, 15000, 'Gold', 3),
  platinum(15000, 35000, 'Platinum', 4),
  diamond(35000, double.infinity, 'Diamond', 5);

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
}

/// Expertise ranks for users
enum Expertise {
  rookie('Rookie'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  expert('Expert');

  final String displayName;

  const Expertise(this.displayName);
}
