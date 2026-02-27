import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/presentation/state/event_viewmodel.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';

class CreateEventFormScreen extends ConsumerStatefulWidget {
  final String category;
  final String categoryKey;

  const CreateEventFormScreen({
    super.key,
    required this.category,
    required this.categoryKey,
  });

  @override
  ConsumerState<CreateEventFormScreen> createState() =>
      _CreateEventFormScreenState();
}

class _CreateEventFormScreenState extends ConsumerState<CreateEventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _capacityController = TextEditingController(text: '100');
    _startDate = DateTime.now().add(const Duration(days: 7));
    _endDate = _startDate.add(const Duration(hours: 3));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 3));
          }
        } else {
          _endDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(hours: 3));
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartDate
          ? TimeOfDay.fromDateTime(_startDate)
          : TimeOfDay.fromDateTime(_endDate),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _endDate = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  void _createEvent() {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter event title')));
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event location')),
      );
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final organizerId = authState.user?.authId ?? '';

    final event = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      category: widget.categoryKey,
      location: _locationController.text,
      startDate: _startDate,
      endDate: _endDate,
      capacity: int.tryParse(_capacityController.text) ?? 100,
      organizerId: organizerId,
      status: 'draft',
    );

    // Create the event using notifier
    ref.read(eventViewModelProvider.notifier).createEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(eventViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Error creating event'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(eventViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              _buildFormField(
                label: 'Event Title',
                controller: _titleController,
                hint: 'Enter event title',
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildFormField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Describe your event',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Location Field
              _buildFormField(
                label: 'Location',
                controller: _locationController,
                hint: 'Enter event location',
              ),
              const SizedBox(height: 16),

              // Start Date & Time
              const Text(
                'Start Date & Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          '${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // End Date & Time
              const Text(
                'End Date & Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          '${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Capacity Field
              _buildFormField(
                label: 'Capacity',
                controller: _capacityController,
                hint: 'Number of attendees',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
