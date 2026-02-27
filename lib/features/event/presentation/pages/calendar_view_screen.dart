import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_planner/theme/app_colors.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final _eventMap = <DateTime, List<String>>{
    DateTime(2026, 3, 15): ['Birthday Party', 'Lunch with Jane'],
    DateTime(2026, 3, 20): ['Team Conference'],
    DateTime(2026, 3, 25): ['Anniversary Dinner'],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  List<String> _getEventsForDay(DateTime day) {
    return _eventMap[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  _buildCalendar(),
                  const SizedBox(height: 32),

                  // Events for selected day
                  _buildSelectedDayEvents(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime(2026, 1, 1),
        lastDay: DateTime(2026, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        headerStyle: HeaderStyle(
          formatButtonShowsNext: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(color: AppColors.primary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: AppColors.textSecondary),
        ),
        eventLoader: _getEventsForDay,
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events on ${_formatDate(_selectedDay)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No events scheduled',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _EventListItem(
                eventTitle: events[index],
                time: _getEventTime(index),
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _getEventTime(int index) {
    final times = ['10:00 AM', '2:00 PM', '6:00 PM'];
    return times[index % times.length];
  }
}

class _EventListItem extends StatelessWidget {
  final String eventTitle;
  final String time;

  const _EventListItem({required this.eventTitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
