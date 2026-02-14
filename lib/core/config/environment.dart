import 'package:envied/envied.dart';

part 'environment.g.dart';

@Envied(path: '.env')
final class Environment {
  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  static const String stripePublishableKey = _Environment.stripePublishableKey;
}
