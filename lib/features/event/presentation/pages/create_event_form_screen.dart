import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/presentation/state/event_viewmodel.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:event_planner/features/venues/domain/usecases/get_venues_usecase.dart';

final recommendedVenuesProvider = FutureProvider.autoDispose
    .family<List<VenueEntity>, String>((ref, categoryKey) async {
      final usecase = ref.read(getVenuesUsecaseProvider);
      final result = await usecase(
        GetVenuesParams(recommendedCategory: categoryKey),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (venues) => venues.where((venue) => venue.isActive).toList(),
      );
    });

class CreateEventFormScreen extends ConsumerStatefulWidget {
  final String? category;
  final String? categoryKey;

  const CreateEventFormScreen({super.key, this.category, this.categoryKey});

  @override
  ConsumerState<CreateEventFormScreen> createState() =>
      _CreateEventFormScreenState();
}

class _CreateEventFormScreenState extends ConsumerState<CreateEventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _ticketPriceController;
  late final TextEditingController _desiredVenueController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedCategoryKey;
  int _currentStep = 0;
  String? _selectedVenueId;
  String _eventType = 'free';
  bool _isPublic = true;

  static const String _othersVenueValue = '__others__';

  static const List<Map<String, String>> _eventCategories = [
    {'label': 'Birthday', 'key': 'birthday'},
    {'label': 'Anniversary', 'key': 'anniversary'},
    {'label': 'Wedding', 'key': 'wedding'},
    {'label': 'Engagement', 'key': 'engagement'},
    {'label': 'Workshop', 'key': 'workshop'},
    {'label': 'Conference', 'key': 'conference'},
    {'label': 'Graduation', 'key': 'graduation'},
    {'label': 'Fundraisers', 'key': 'fundraisers'},
  ];

  static const List<String> _stepTitles = [
    'Basic Info',
    'Date & Time',
    'Venue, Pricing & Visibility',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _capacityController = TextEditingController(text: '100');
    _ticketPriceController = TextEditingController();
    _desiredVenueController = TextEditingController();
    _startDate = DateTime.now().add(const Duration(days: 7));
    _endDate = _startDate.add(const Duration(hours: 3));

    final requestedCategory = (widget.categoryKey ?? '').trim().toLowerCase();
    final normalizedCategory = requestedCategory == 'other'
        ? 'graduation'
        : requestedCategory;
    final isAllowed = _eventCategories.any(
      (item) => item['key'] == normalizedCategory,
    );
    _selectedCategoryKey = isAllowed
        ? normalizedCategory
        : _eventCategories.first['key']!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _ticketPriceController.dispose();
    _desiredVenueController.dispose();
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

    if (_selectedVenueId == _othersVenueValue) {
      final desiredVenue = _desiredVenueController.text.trim();
      if (desiredVenue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your desired venue')),
        );
        return;
      }

      if (_locationController.text.trim().isEmpty) {
        _locationController.text = desiredVenue;
      }
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose a recommended venue or select Others and enter your desired venue',
          ),
        ),
      );
      return;
    }

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid capacity')),
      );
      return;
    }

    final ticketPrice =
        double.tryParse(_ticketPriceController.text.trim()) ?? 0;
    if (_eventType == 'paid' && ticketPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter paid amount per person in rupees'),
        ),
      );
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final organizerId = authState.user?.authId ?? '';

    final event = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategoryKey,
      location: _locationController.text,
      startDate: _startDate,
      endDate: _endDate,
      capacity: capacity,
      organizerId: organizerId,
      status: 'draft',
      eventType: _eventType,
      ticketPrice: _eventType == 'paid' ? ticketPrice : 0,
      isPublic: _isPublic,
    );

    // Create the event using notifier
    ref.read(eventViewModelProvider.notifier).createEvent(event);
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter event title')),
        );
        return false;
      }
      return true;
    }

    if (step == 1) {
      if (_endDate.isBefore(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date/time must be after start date/time'),
          ),
        );
        return false;
      }
      return true;
    }

    if (step == 2) {
      if (_selectedVenueId == _othersVenueValue) {
        final desiredVenue = _desiredVenueController.text.trim();
        if (desiredVenue.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your desired venue')),
          );
          return false;
        }

        if (_locationController.text.trim().isEmpty) {
          _locationController.text = desiredVenue;
        }
      }

      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please choose a recommended venue or select Others and enter your desired venue',
            ),
          ),
        );
        return false;
      }

      final capacity = int.tryParse(_capacityController.text.trim());
      if (capacity == null || capacity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid capacity')),
        );
        return false;
      }

      final ticketPrice =
          double.tryParse(_ticketPriceController.text.trim()) ?? 0;
      if (_eventType == 'paid' && ticketPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter paid amount per person in rupees'),
          ),
        );
        return false;
      }
      return true;
    }

    return true;
  }

  bool _validateCurrentStep() => _validateStep(_currentStep);

  void _tryGoToStep(int targetStep) {
    if (targetStep <= _currentStep) {
      setState(() {
        _currentStep = targetStep;
      });
      return;
    }

    for (int step = _currentStep; step < targetStep; step++) {
      if (!_validateStep(step)) {
        return;
      }
    }

    setState(() {
      _currentStep = targetStep;
    });
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      if (!_validateCurrentStep()) return;
      setState(() {
        _currentStep += 1;
      });
      return;
    }
    _createEvent();
  }

  void _onStepCancel() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentStep -= 1;
    });
  }

  List<Step> _buildSteps(AsyncValue<List<VenueEntity>> venuesAsync) {
    return [
      Step(
        title: const Text('Basic Info'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryKey,
              decoration: InputDecoration(
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
              items: _eventCategories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category['key'],
                      child: Text(category['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategoryKey = value;
                  _selectedVenueId = null;
                  _desiredVenueController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Event Title',
              controller: _titleController,
              hint: 'Enter event title',
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Describe your event',
              maxLines: 4,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Date & Time'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
      Step(
        title: const Text('Venue & Pricing'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Venue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            venuesAsync.when(
              data: (venues) {
                final venueItems = [
                  ...venues,
                  const VenueEntity(id: _othersVenueValue, name: 'Others'),
                ];

                final selectedValue =
                    venueItems.any((venue) => venue.id == _selectedVenueId)
                    ? _selectedVenueId
                    : null;

                return DropdownButtonFormField<String>(
                  value: selectedValue,
                  decoration: InputDecoration(
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
                  hint: const Text('Choose recommended venue'),
                  items: venueItems
                      .map(
                        (venue) => DropdownMenuItem<String>(
                          value: venue.id,
                          child: Text(
                            venue.id == _othersVenueValue
                                ? 'Others'
                                : '${venue.name} • ${venue.city}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVenueId = value;
                    });

                    if (value == null) return;
                    if (value == _othersVenueValue) {
                      _locationController.clear();
                      return;
                    }

                    final selected = venues.firstWhere(
                      (venue) => venue.id == value,
                    );
                    _desiredVenueController.clear();
                    _locationController.text =
                        '${selected.name}, ${selected.address}, ${selected.city}';
                  },
                );
              },
              loading: () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Loading recommended venues...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  'Could not load venues. You can still type location manually.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (_selectedVenueId == _othersVenueValue) ...[
              const SizedBox(height: 12),
              _buildFormField(
                label: 'Your Desired Venue',
                controller: _desiredVenueController,
                hint: 'Enter your preferred venue name',
              ),
            ],
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Capacity',
              controller: _capacityController,
              hint: 'Number of attendees',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'free',
                  label: Text('Free'),
                  icon: Icon(Icons.money_off),
                ),
                ButtonSegment<String>(
                  value: 'paid',
                  label: Text('Paid'),
                  icon: Icon(Icons.payments),
                ),
              ],
              selected: {_eventType},
              onSelectionChanged: (selection) {
                final selected = selection.first;
                setState(() {
                  _eventType = selected;
                  if (_eventType == 'free') {
                    _ticketPriceController.clear();
                  }
                });
              },
            ),
            if (_eventType == 'paid') ...[
              const SizedBox(height: 12),
              _buildFormField(
                label: 'Price Per Person (NPR)',
                controller: _ticketPriceController,
                hint: 'Enter amount in rupees',
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Visibility',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Public'),
                  icon: Icon(Icons.public),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Private'),
                  icon: Icon(Icons.lock),
                ),
              ],
              selected: {_isPublic},
              onSelectionChanged: (selection) {
                setState(() {
                  _isPublic = selection.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              _isPublic
                  ? 'Public events are visible to other users.'
                  : 'Private events are visible only to you/attendees you invite.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Review'),
        isActive: _currentStep >= 3,
        state: StepState.indexed,
        content: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewItem('Category', _selectedCategoryLabel()),
              _buildReviewItem('Title', _titleController.text.trim()),
              _buildReviewItem(
                'Description',
                _descriptionController.text.trim().isEmpty
                    ? 'No description'
                    : _descriptionController.text.trim(),
              ),
              _buildReviewItem(
                'Start',
                '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
              ),
              _buildReviewItem(
                'End',
                '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
              ),
              _buildReviewItem('Venue', _locationController.text.trim()),
              _buildReviewItem('Capacity', _capacityController.text.trim()),
              _buildReviewItem(
                'Pricing',
                _eventType == 'paid' ? 'Paid' : 'Free',
              ),
              if (_eventType == 'paid')
                _buildReviewItem(
                  'Ticket Price',
                  'NPR ${_ticketPriceController.text.trim()}',
                ),
              _buildReviewItem('Visibility', _isPublic ? 'Public' : 'Private'),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(
      recommendedVenuesProvider(_selectedCategoryKey),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildStepProgressHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildSteps(venuesAsync)[_currentStep].content,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.5,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: state.isLoading && _currentStep == 3
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(_currentStep == 3 ? 'Create Event' : 'Next'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: state.isLoading ? null : _onStepCancel,
                    child: Text(_currentStep == 0 ? 'Close' : 'Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of ${_stepTitles.length}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_stepTitles.length * 2 - 1, (i) {
            if (i.isOdd) {
              final leftStep = i ~/ 2;
              final isComplete = leftStep < _currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: isComplete ? AppColors.primary : Colors.grey.shade300,
                ),
              );
            }

            final step = i ~/ 2;
            final isActive = step == _currentStep;
            final isComplete = step < _currentStep;

            return GestureDetector(
              onTap: () {
                _tryGoToStep(step);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete || isActive
                      ? AppColors.primary
                      : Colors.white,
                  border: Border.all(
                    color: isComplete || isActive
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : Text(
                          '${step + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          _stepTitles[_currentStep],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    final display = value.trim().isEmpty ? 'Not provided' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            display,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _selectedCategoryLabel() {
    return _eventCategories.firstWhere(
          (item) => item['key'] == _selectedCategoryKey,
          orElse: () => _eventCategories.first,
        )['label'] ??
        'General';
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
