import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  EventType _eventType = EventType.other;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventSelectionViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventType>(
                initialValue: _eventType,
                decoration: const InputDecoration(labelText: 'Sport Type'),
                items: EventType.values
                    .map(
                      (type) => DropdownMenuItem<EventType>(
                        value: type,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _eventType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      validator: (value) {
                        if (double.tryParse(value ?? '') == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      validator: (value) {
                        if (double.tryParse(value ?? '') == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Starts At'),
                subtitle: Text(_startsAt.toLocal().toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDateTime,
              ),
              const SizedBox(height: 16),
              if (state.error != null)
                Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _startsAt.isBefore(now) ? now : _startsAt,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    final location = LocationPoint(
      latitude: double.parse(_latController.text.trim()),
      longitude: double.parse(_lngController.text.trim()),
      address: _addressController.text.trim(),
    );

    final eventId = await ref
        .read(eventSelectionViewModelProvider.notifier)
        .createEvent(
          creatorId: user.uid,
          title: _titleController.text,
          type: _eventType,
          location: location,
          startsAt: _startsAt,
          description: _descriptionController.text,
        );

    if (eventId == null || !mounted) return;

    Navigator.of(context).pop(eventId);
  }
}
