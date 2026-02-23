import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/views/event_picker_sheet.dart';

/// Legacy wrapper kept for backward-compatibility with existing routes.
///
/// Delegates to [EventPickerSheet] which provides the richer UI.
class EventSelectionScreen extends ConsumerWidget {
  const EventSelectionScreen({super.key, required this.onEventSelected});

  final ValueChanged<EventModel> onEventSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Open the picker sheet immediately and pop when done.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final picked = await EventPickerSheet.show(context);
      if (picked != null && context.mounted) {
        onEventSelected(picked);
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
