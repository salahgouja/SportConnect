import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/page_transitions.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/views/create_event_screen.dart';
import 'package:sport_connect/features/events/views/event_attendees_screen.dart';
import 'package:sport_connect/features/events/views/event_detail_screen.dart';
import 'package:sport_connect/features/events/views/edit_event_screen.dart';
import 'package:sport_connect/features/events/views/my_events_screen.dart';

/// Events module routes
class EventsRoutes implements RouteConfig {
  @override
  String get moduleName => 'events';

  @override
  String? get initialRoute => null;

  @override
  List<RouteBase> getRoutes() {
    return [
      // Create Event
      GoRoute(
        path: AppRoutes.createEvent.path,
        name: AppRoutes.createEvent.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const CreateEventScreen(),
        ),
      ),

      // My Events
      GoRoute(
        path: AppRoutes.myEvents.path,
        name: AppRoutes.myEvents.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const MyEventsScreen(),
        ),
      ),

      // Event Detail
      GoRoute(
        path: AppRoutes.eventDetail.path,
        name: AppRoutes.eventDetail.name,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: EventDetailScreen(eventId: eventId),
          );
        },
      ),

      // Event Attendees
      GoRoute(
        path: AppRoutes.eventAttendees.path,
        name: AppRoutes.eventAttendees.name,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: EventAttendeesScreen(eventId: eventId),
          );
        },
      ),

      // Edit Event
      GoRoute(
        path: AppRoutes.editEvent.path,
        name: AppRoutes.editEvent.name,
        pageBuilder: (context, state) {
          final event = state.extra as EventModel;
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: EditEventScreen(event: event),
          );
        },
      ),
    ];
  }
}
