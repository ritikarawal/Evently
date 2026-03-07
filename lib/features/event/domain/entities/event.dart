class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int capacity;
  final List<String> attendeeIds;
  final String organizerId;
  final String status;
  final String? imageUrl;
  final String eventType;
  final double ticketPrice;
  final bool isPublic;

  Event({
    this.id = '',
    this.title = '',
    this.description = '',
    this.category = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.capacity = 0,
    this.attendeeIds = const [],
    this.organizerId = '',
    this.status = 'draft',
    this.imageUrl,
    this.eventType = 'free',
    this.ticketPrice = 0,
    this.isPublic = true,
  });
}
