# Event Planner - Professional Event Management Application

## 📱 App Overview

Event Planner is a comprehensive Flutter-based event management application following industry-standard clean architecture principles. The app enables users to discover, create, manage, and attend events with a professional, user-centric interface.

---

## 🏗️ Architecture Overview

### Clean Architecture Structure
```
lib/
├── core/                          # Core & Shared Functionality
│   ├── api/                       # API Client & Endpoints
│   │   ├── api_client.dart       # HTTP client with fallback logic
│   │   └── api_endpoints.dart    # Centralized API routes
│   ├── services/                  # Cross-platform services
│   └── theme/                     # App theming (colors, styles)
│
├── features/                      # Feature Modules (Clean Architecture)
│   ├── auth/                      # User Authentication Feature
│   │   ├── domain/               # Business logic
│   │   │   └── repositories/     # Abstract interfaces
│   │   ├── data/                 # Data layer
│   │   │   ├── models/           # DTO classes
│   │   │   └── repositories/     # Implementations
│   │   └── presentation/         # UI Layer
│   │       ├── pages/            # Screen widgets
│   │       └── view_model/       # State management
│   │
│   ├── dashboard/                # Dashboard Feature
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── home_screen.dart
│   │   │       └── enhanced_dashboard_screen.dart
│   │   └── view_model/
│   │
│   ├── event/                    # Event Management Feature
│   │   ├── domain/
│   │   │   ├── entities/         # Event, EventCategory
│   │   │   └── repositories/     # EventRepository interface
│   │   ├── data/
│   │   │   ├── models/           # EventDTO
│   │   │   └── repositories/     # EventRepositoryImpl
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── quick_create_event_screen.dart         # Category selection
│   │       │   ├── create_event_form_screen.dart          # Event form
│   │       │   ├── event_discovery_screen.dart            # Browse events
│   │       │   ├── event_details_screen.dart              # Event details
│   │       │   └── calendar_view_screen.dart              # Calendar view
│   │       ├── state/
│   │       │   └── event_viewmodel.dart                   # Event state management
│   │       └── components/
│   │
│   ├── user/                     # User Profile Feature
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │       └── pages/
│   │           └── user_profile_screen.dart               # User profile
│   │
│   └── navigation/               # Navigation Management
│       └── presentation/
│           └── pages/
│               └── main_navigation_screen.dart            # Tab navigation
│
├── widget/                        # Shared Widgets
│   ├── event_categories_grid.dart # Reusable category grid
│   └── other_shared_widgets.dart
│
└── main.dart                      # App entry point
```

---

## 🎯 Core Features

### 1. **Dashboard/Home Screen** 📊
**File:** `enhanced_dashboard_screen.dart`
- **Welcome Message** - Personalized greeting with user name
- **Statistics Cards** - Quick overview of:
  - Upcoming events
  - Events created
  - Number of attendees
- **Quick Actions** - Fast access to:
  - Discover events
  - Calendar view
  - User profile
- **Upcoming Events List** - Shows next 2-3 upcoming events
- **Popular Categories** - Quick access to event templates
- **FAB Button** - "Create Event" floating action button

**UI Components:**
- Gradient header with custom AppBar
- Stat cards with icons and colors
- Action buttons with visual feedback
- Event tiles with attendee counts

---

### 2. **Event Creation** ✨
**Files:** 
- `quick_create_event_screen.dart` - Category selection
- `create_event_form_screen.dart` - Event details form

**Workflow:**
1. User taps FAB or category → QuickCreateEventScreen
2. Browse & select event category (Birthday, Wedding, Conference, etc.)
3. Form opens with category pre-filled
4. Fill in details:
   - Title (required)
   - Description
   - Location (required)
   - Start Date & Time
   - End Date & Time
   - Capacity
5. Submit → API call → Success/Error feedback

**Features:**
- Date and time pickers
- Form validation
- Category-based templates
- Loading states during submission

---

### 3. **Event Discovery** 🔍
**File:** `event_discovery_screen.dart`

**Features:**
- **Search Bar** - Search events by title/keyword
- **Filter Chips** - Filter by:
  - Event category (Birthday, Wedding, Conference, Workshop, etc.)
  - Could be extended: date range, location, attendee count
- **Grid View** - Display events in 2-column grid
- **Event Cards** - Show:
  - Event image/thumbnail
  - Title
  - Category badge
  - Date
  - Attendee count
- **Lazy Loading** - Load more events on scroll

---

### 4. **Event Details** 📍
**File:** `event_details_screen.dart`

**Displays:**
- Hero image with customizable gradient
- Event title and category
- Quick info cards:
  - Date
  - Time
  - Location
  - Attendee count
- Full description
- Organizer profile
- Action buttons:
  - Attend Event (join)
  - Share Event (share to others)
- Interactive like/favorite button

---

### 5. **Calendar View** 📅
**File:** `calendar_view_screen.dart`

**Features:**
- **Interactive Calendar** - Month view with:
  - Highlight event days
  - Current day indicator
  - Event indicators (dots)
- **Event List** - Shows events for selected day
- **Navigation** - Previous/next month navigation
- **Event Details** - Tap event to see details

**State:**
- Currently shows mock data
- Ready for API integration

---

### 6. **User Profile** 👤
**File:** `user_profile_screen.dart`

**Sections:**
1. **Profile Header**
   - Profile picture
   - User name
   - Email

2. **Statistics**
   - Events created
   - Events attending
   - Followers

3. **My Events** - List of user's events
   - Can view all events
   - Quick preview

4. **Settings**
   - Notifications
   - Privacy & Security
   - Help & Support
   - About

5. **Account Actions**
   - Edit profile
   - Logout

---

### 7. **Navigation** 🧭
**File:** `main_navigation_screen.dart`

**Bottom Navigation Bar** with 4 tabs:
1. **Home** - Dashboard/Enhanced Dashboard
2. **Discover** - Event Discovery
3. **Calendar** - Calendar View
4. **Profile** - User Profile

---

## 🔧 State Management

### Technology: Flutter Riverpod 3.0.3

### Key Providers:

```dart
// Authentication
authViewModelProvider → User state

// Events
eventViewModelProvider → NotifierProvider<EventNotifier, EventCreationState>
eventRepositoryProvider → EventRepository implementation
```

### Pattern: Notifier Pattern
- Clean, type-safe state management
- Automatic provider invalidation
- Easy testing

---

## 🎨 Design System

### Color Scheme
- **Primary:** Customizable primary color (gradient support)
- **Background:** Light neutral background
- **CardBackground:** Slightly elevated card backgrounds
- **TextPrimary:** Main text color
- **TextSecondary:** Muted/secondary text

### Typography
- **Bold Headers:** 18-28px with FontWeight.bold
- **Regular Text:** 14-16px with FontWeight.normal
- **Small Text:** 11-12px for secondary info

### Components
- **Cards:** Rounded corners (12px), border with opacity
- **Buttons:** Rounded corners, gradient support, multiple sizes
- **Input Fields:** Material design, prefix/suffix icons
- **Lists:** Tiles with icons, spacing consistency
- **Badges:** Colored containers with text

---

## 📡 API Integration

### Base Configuration
- **Production:** 10.1.1.56:5050
- **Emulator:** localhost:5050
- **Fallback Logic:** Automatic retry with multiple endpoints

### Event Endpoints
```
POST   /api/events/create         → Create event
GET    /api/events                → Get all events
GET    /api/events/{id}           → Get event details
PUT    /api/events/{id}           → Update event
DELETE /api/events/{id}           → Delete event
GET    /api/events/user/{userId}  → Get user's events
```

---

## 🔐 Authentication

**Implemented:**
- Google Sign-In
- Email/Password auth
- JWT token storage
- Secure token refresh
- Auto-logout on token expiry

**Feature:** Automatic fallback network retry during auth

---

## 📦 Key Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| flutter_riverpod | State Management | 3.0.3 |
| dio | HTTP Client | 5.9.0 |
| hive | Local Database | 2.2.3 |
| table_calendar | Calendar Widget | 3.0.9 |
| flutter_secure_storage | Secure Storage | 10.0.0 |
| json_serializable | JSON Serialization | 6.8.0 |
| google_sign_in | OAuth Login | 7.2.0 |
| cached_network_image | Image Caching | 3.3.1 |

---

## 🚀 Getting Started

### Setup

1. **Install Dependencies**
   ```bash
   cd event_planner
   flutter pub get
   ```

2. **Add table_calendar** (if not already added)
   ```bash
   flutter pub add table_calendar
   ```

3. **Run App**
   ```bash
   flutter run
   ```

### Network Configuration

Update host IP in `lib/core/api/api_endpoints.dart`:
```dart
static const String compIpAddress = "YOUR_HOST_IP"; // e.g., "192.168.x.x"
```

---

## 🎯 Professional Features

### User-Centric Design
✅ Intuitive navigation with clear visual hierarchy
✅ Smooth transitions and animations
✅ Responsive design for all screen sizes
✅ Accessible color contrasts and fonts
✅ Empty states with helpful messages
✅ Loading indicators and progress feedback
✅ Error handling with user-friendly messages

### Performance
✅ Lazy loading for events
✅ Image caching for offline access
✅ Optimized database queries
✅ Efficient state management
✅ Background sync for notifications

### Code Quality
✅ Clean Architecture with separated concerns
✅ Repository pattern for data abstraction
✅ Riverpod for reactive state management
✅ Type-safe implementations
✅ Reusable components and widgets
✅ Proper error handling
✅ Comprehensive documentation

---

## 📈 Future Enhancements

### Phase 2 Features
- [ ] Event notifications (push/in-app)
- [ ] Real-time event updates via WebSockets
- [ ] Event invitations and RSVP
- [ ] Venue management and booking
- [ ] Payment integration (Khalti, Stripe)
- [ ] Event analytics dashboard
- [ ] Social features (comments, ratings)
- [ ] Event recommendations
- [ ] Ticketing system
- [ ] Dark mode support

### Performance Optimization
- [ ] Pagination with infinite scroll
- [ ] Database indexing
- [ ] Image optimization
- [ ] Code splitting/modular loading

---

## 🤝 Contributing

This app follows Flutter best practices and clean architecture principles. When adding features:

1. Create feature folder with domain/data/presentation layers
2. Use Repository pattern for data
3. Use Riverpod for state management
4. Follow existing naming conventions
5. Add documentation to complex logic
6. Test API calls and state changes

---

## 📝 Notes

- **Database:** Currently using Hive for local storage
- **Authentication:** JWT tokens stored securely
- **Images:** Cached locally with flutter_cache_manager
- **Network:** Automatic retry logic for resilience
- **Events:** Mock data ready for API integration

---

## 🎓 Learning Resources

This project demonstrates:
- Clean Architecture implementation
- Advanced state management with Riverpod
- Complex UI patterns (TabBar, SliverAppBar, CustomScrollView)
- API integration with error handling
- Local data persistence
- Professional Flutter app structure

---

**Built with ❤️ for seamless event management**
