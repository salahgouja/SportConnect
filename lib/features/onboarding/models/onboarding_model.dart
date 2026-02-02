/// Onboarding page model
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final String? lottieAnimation;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.lottieAnimation,
  });
}

/// Default onboarding pages for SportConnect
class OnboardingPages {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to SportConnect',
      description:
          'Connect with fellow sports enthusiasts and share rides to events, games, and training sessions.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Find Rides Easily',
      description:
          'Search for rides going to your favorite sports venues. Filter by sport type, time, and destination.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Share Your Journey',
      description:
          'Offer rides to others and earn money while reducing carbon footprint. Make new friends along the way!',
      imagePath: 'assets/images/onboarding_3.png',
    ),
    OnboardingPage(
      title: 'Safe & Secure',
      description:
          'Verified profiles, secure payments, and real-time tracking ensure a safe experience for everyone.',
      imagePath: 'assets/images/onboarding_4.png',
    ),
  ];
}
