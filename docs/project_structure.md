# Project Structure for Job Scheduling System

## Overview
This document outlines the file structure and implementation details for the new job scheduling system while maintaining the existing styling and architecture.

## New Features Implementation

### 1. State Management

#### New Provider Files
```
lib/providers/
├── availability_provider.dart     # Manages electrician availability
├── schedule_provider.dart        # Handles scheduling logic
└── direct_request_provider.dart  # Manages direct job requests
```

#### Model Updates
```
lib/models/
├── availability_model.dart       # Electrician availability model
├── schedule_model.dart          # Schedule slot model
├── direct_request_model.dart    # Direct request model
└── job_model.dart              # Update existing with new states
```

### 2. New Screens

#### Homeowner Screens
```
lib/features/homeowner/screens/
├── electrician_list_screen.dart         # Browse electricians
├── electrician_profile_view_screen.dart # View electrician profile
├── book_appointment_screen.dart         # Book available slots
├── reschedule_request_screen.dart       # Handle reschedule
└── job_tracking_screen.dart            # Enhanced job tracking
```

#### Electrician Screens
```
lib/features/electrician/screens/
├── availability_calendar_screen.dart    # Enhanced availability management
├── incoming_requests_screen.dart        # Handle direct requests
├── reschedule_management_screen.dart    # Manage reschedule requests
└── schedule_overview_screen.dart        # Weekly/monthly schedule view
```

### 3. New Widgets

#### Common Widgets
```
lib/features/common/widgets/
├── calendar_widget.dart                # Enhanced calendar widget
├── time_slot_picker.dart              # Time slot selection
├── schedule_card.dart                 # Schedule display card
└── status_timeline.dart               # Job status timeline
```

#### Homeowner Widgets
```
lib/features/homeowner/widgets/
├── electrician_card.dart              # Electrician preview card
├── availability_viewer.dart           # View electrician availability
└── booking_confirmation.dart          # Booking confirmation dialog
```

#### Electrician Widgets
```
lib/features/electrician/widgets/
├── availability_editor.dart           # Edit availability slots
├── request_card.dart                 # Direct request display
└── schedule_timeline.dart            # Daily schedule timeline
```

## Implementation TODOs

### 1. Database Schema Updates

```sql
-- Availability Management
CREATE TABLE electrician_availability (
    id UUID PRIMARY KEY,
    electrician_id UUID REFERENCES electricians(id),
    day_of_week INTEGER,
    start_time TIME,
    end_time TIME,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Schedule Slots
CREATE TABLE schedule_slots (
    id UUID PRIMARY KEY,
    electrician_id UUID REFERENCES electricians(id),
    date DATE,
    start_time TIME,
    end_time TIME,
    status VARCHAR(20), -- AVAILABLE, BOOKED, BLOCKED
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Direct Requests
CREATE TABLE direct_requests (
    id UUID PRIMARY KEY,
    job_id UUID REFERENCES jobs(id),
    homeowner_id UUID REFERENCES homeowners(id),
    electrician_id UUID REFERENCES electricians(id),
    preferred_date DATE,
    preferred_time TIME,
    status VARCHAR(20), -- PENDING, ACCEPTED, DECLINED
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Reschedule Requests
CREATE TABLE reschedule_requests (
    id UUID PRIMARY KEY,
    job_id UUID REFERENCES jobs(id),
    requested_by_id UUID,
    requested_by_type VARCHAR(20), -- HOMEOWNER, ELECTRICIAN
    original_date DATE,
    original_time TIME,
    proposed_date DATE,
    proposed_time TIME,
    status VARCHAR(20), -- PENDING, ACCEPTED, DECLINED
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Provider Implementation TODOs

#### AvailabilityProvider
- [x] Implement CRUD operations for availability slots
- [x] Add recurring schedule management
- [x] Handle availability conflicts
- [x] Implement buffer time management

#### ScheduleProvider
- [x] Implement booking slot creation
- [x] Add schedule conflict resolution
- [x] Handle reschedule requests
- [ ] Implement calendar sync features

#### DirectRequestProvider
- [x] Implement direct request creation
- [x] Add request status management
- [x] Handle request notifications
- [x] Implement request filtering

### 3. Screen Implementation TODOs

#### Homeowner Screens
- [x] Create electrician browsing interface
- [x] Implement availability viewing
- [ ] Add booking flow
- [ ] Create reschedule request interface

#### Electrician Screens
- [x] Enhance availability management
- [x] Create request management interface
- [x] Implement schedule overview
- [x] Add reschedule handling

### 4. Widget Implementation TODOs

#### Common Widgets
- [x] Create reusable calendar component
- [x] Implement time slot picker
- [x] Add schedule display components
- [ ] Create status indicators

#### Specific Widgets
- [ ] Implement availability editor
- [ ] Create request cards
- [ ] Add booking confirmation dialogs
- [ ] Implement schedule timeline

## Styling Guidelines

Maintain existing styling from `AppTheme`:

```dart
// Colors
- Primary: AppColors.primary (Beige)
- Accent: AppColors.accent (Dark gray)
- Background: AppColors.background
- Surface: AppColors.surface
- Text: AppColors.textPrimary, AppColors.textSecondary

// Typography
- Headings: AppTextStyles.h1, h2, h3
- Body: AppTextStyles.bodyLarge, bodyMedium, bodySmall

// Spacing
- Page Padding: 24.0
- Card Padding: 16.0
- Element Spacing: 8.0, 16.0, 24.0

// Shapes
- Border Radius: 12.0 (cards), 8.0 (buttons)
- Elevation: 0-2 (subtle shadows)
```

## Navigation Updates

Update `lib/main.dart` with new routes:

```dart
// Add new routes
case '/electrician/availability-calendar':
  return MaterialPageRoute(
    builder: (_) => const AvailabilityCalendarScreen(),
  );
case '/homeowner/electrician-list':
  return MaterialPageRoute(
    builder: (_) => const ElectricianListScreen(),
  );
// ... add other new routes
```

## Next Steps

1. **Phase 1: Core Infrastructure**
   - [ ] Implement database schema updates
   - [ ] Create base providers
   - [ ] Set up basic navigation

2. **Phase 2: Basic Features**
   - [ ] Implement availability management
   - [ ] Create direct request system
   - [ ] Add basic scheduling

3. **Phase 3: Enhanced Features**
   - [ ] Add reschedule management
   - [ ] Implement conflict resolution
   - [ ] Create advanced calendar features

4. **Phase 4: Polish**
   - [ ] Enhance UI/UX
   - [ ] Add animations
   - [ ] Implement error handling
   - [ ] Add loading states 