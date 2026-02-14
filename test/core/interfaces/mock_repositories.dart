import 'package:mockito/annotations.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_user_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_chat_repository.dart';
import 'package:sport_connect/core/interfaces/services/i_firebase_service.dart';
import 'package:sport_connect/core/interfaces/services/i_location_service.dart';

/// Generate mocks for testing repository and service interfaces
///
/// Run: flutter pub run build_runner build
///
/// This will generate mock_repositories.mocks.dart with:
/// - MockIAuthRepository
/// - MockIUserRepository
/// - MockIRideRepository
/// - MockIChatRepository
/// - MockIFirebaseService
/// - MockILocationService
@GenerateMocks([
  IAuthRepository,
  IUserRepository,
  IRideRepository,
  IChatRepository,
  IFirebaseService,
  ILocationService,
])
void main() {}
