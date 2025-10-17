# User & Driver Module Implementation Guide

## 📋 Complete Feature List

### ✅ Already Created:
1. **Models:** `booking_model.dart`
2. **Services:** `driver_service.dart`, `user_service.dart` (updated)

---

## 🚗 Driver Module Features

### 1. Driver Availability Toggle
**Screen:** Update existing `driver_dashboard_screen.dart`

**Features:**
- Toggle button (Available/Unavailable)
- Real-time status update
- Visual indicator

**Implementation:**
```dart
StreamBuilder<bool>(
  stream: DriverService.getAvailabilityStream(driverId),
  builder: (context, snapshot) {
    bool isAvailable = snapshot.data ?? false;
    return Switch(
      value: isAvailable,
      onChanged: (value) async {
        await DriverService.updateAvailability(driverId, value);
      },
    );
  },
)
```

---

### 2. Booking Requests Screen
**New File:** `lib/screens/driver_booking_requests_screen.dart`

**Features:**
- List of pending booking requests
- Real-time updates
- Accept/Reject actions
- Fare input on accept

**UI Components:**
- Booking card with user details
- Pickup/Dropoff locations
- Accept button (Green)
- Reject button (Red)

---

### 3. Accept Booking Dialog
**Features:**
- Popup to enter fare amount
- Validation
- Confirmation message

```dart
Future<void> _acceptBooking(String bookingId) async {
  final fareController = TextEditingController();
  
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter Fare Amount'),
      content: TextField(
        controller: fareController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Fare (₹)',
          prefixText: '₹ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm'),
        ),
      ],
    ),
  );

  if (confirmed == true && fareController.text.isNotEmpty) {
    final fare = double.parse(fareController.text);
    await DriverService.acceptBooking(bookingId, fare, driverName);
  }
}
```

---

### 4. Earnings Screen
**New File:** `lib/screens/driver_earnings_screen.dart`

**Features:**
- Total earnings
- Today's earnings
- Total rides
- Earnings breakdown
- Monthly chart (optional)

**UI:**
```
┌─────────────────────┐
│ Total Earnings      │
│    ₹ 15,000         │
└─────────────────────┘

┌─────────────────────┐
│ Today's Earnings    │
│    ₹ 1,200          │
└─────────────────────┘

Recent Rides:
- Ride #1: ₹500 (Paid)
- Ride #2: ₹300 (Paid)
```

---

### 5. Driver Notifications Screen
**New File:** `lib/screens/driver_notifications_screen.dart`

**Features:**
- List all notifications
- Mark as read
- Different types:
  - New booking request
  - Payment received
  - Booking cancelled

---

### 6. Driver Profile Screen
**Update:** Existing `driver_profile_screen.dart`

**Add Features:**
- Profile image upload (Cloudinary)
- Edit personal info
- Change password
- View ratings
- Logout

---

## 👤 User Module Features

### 1. Available Drivers Screen
**New File:** `lib/screens/available_drivers_screen.dart`

**Features:**
- List of online drivers
- Filter by rating
- View driver details
- Book button

**UI:**
```
Available Drivers

┌────────────────────────────┐
│ 👤 John Doe               │
│ ⭐ 4.8 (50 rides)         │
│ 🚗 Sedan - KL01AB1234     │
│ [Book Now]                │
└────────────────────────────┘
```

---

### 2. Booking Form Screen
**New File:** `lib/screens/user_booking_form_screen.dart`

**Features:**
- Select booking type:
  - Driver Only
  - Driver with Vehicle
- Pickup location
- Dropoff location
- Additional details
- Date/Time picker
- Submit button

**Form Fields:**
```dart
- Booking Type (Radio buttons)
- Pickup Location (TextField)
- Dropoff Location (TextField)
- Date & Time (DateTimePicker)
- Additional Notes (TextField - optional)
- [Submit Booking] button
```

---

### 3. Booking Confirmation Screen
**New File:** `lib/screens/booking_confirmation_screen.dart`

**Features:**
- Show booking details
- Wait for driver acceptance
- Show fare when accepted
- Pay Now button
- Cancel button

**Status Flow:**
```
Pending → Waiting for driver...
Accepted → Fare: ₹500 [Pay Now]
Rejected → Driver declined. [Try Another]
```

---

### 4. Payment Screen
**New File:** `lib/screens/user_payment_screen.dart`

**Features:**
- Show fare amount
- Payment methods:
  - UPI
  - Credit/Debit Card
  - Net Banking
  - Cash (on delivery)
- Process payment button

---

### 5. Review & Rating Screen
**New File:** `lib/screens/user_review_screen.dart`

**Features:**
- Star rating (1-5)
- Text review
- Submit button
- Show after ride completion

**UI:**
```
Rate Your Experience

Driver: John Doe
Ride: Airport to City Center

⭐⭐⭐⭐⭐ (Tap to rate)

Write your review:
[Text Area]

[Submit Review]
```

---

### 6. Ride History Screen
**New File:** `lib/screens/user_ride_history_screen.dart`

**Features:**
- List all past bookings
- Filter by status
- View details
- Re-book option

**UI:**
```
Your Rides

┌────────────────────────────┐
│ ✅ Completed               │
│ Airport → City Center      │
│ Driver: John Doe           │
│ Fare: ₹500                 │
│ Jan 15, 2024               │
└────────────────────────────┘
```

---

### 7. Complaint Screen
**New File:** `lib/screens/user_complaint_screen.dart`

**Features:**
- Subject field
- Description
- Attach booking (optional)
- Attach driver (optional)
- Submit button

---

### 8. User Notifications Screen
**New File:** `lib/screens/user_notifications_screen.dart`

**Features:**
- Booking accepted/rejected
- Payment confirmation
- Ride completed
- Review reminders

---

### 9. User Profile Screen
**Update:** Existing `user_profile_screen.dart`

**Add Features:**
- Profile image upload (Cloudinary)
- Edit personal info
- Change password
- View booking history
- Logout

---

## 🔔 Notification System

### Firestore Structure:
```javascript
notifications: {
  userId: String (or driverId),
  title: String,
  message: String,
  type: String,
  bookingId: String,
  read: Boolean,
  createdAt: Timestamp
}
```

### Notification Types:
**For Driver:**
- `booking_request` - New booking
- `payment_received` - User paid
- `booking_cancelled` - User cancelled

**For User:**
- `booking_accepted` - Driver accepted
- `booking_rejected` - Driver rejected
- `ride_completed` - Ride finished

---

## 📸 Cloudinary Integration

### Service File:
**New File:** `lib/services/cloudinary_service.dart`

```dart
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class CloudinaryService {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiSecret = 'YOUR_API_SECRET';

  static Future<String?> uploadImage(String imagePath) async {
    try {
      // Upload to Cloudinary
      // Return URL
    } catch (e) {
      return null;
    }
  }
}
```

---

## 🗂️ Firestore Collections Structure

### 1. users
```javascript
{
  id: String,
  name: String,
  email: String,
  phone: String,
  userType: 'user' | 'driver',
  profileImage: String (Cloudinary URL),
  isAvailable: Boolean (for drivers),
  status: 'pending' | 'approved' | 'rejected',
  // ... other fields
}
```

### 2. bookings
```javascript
{
  id: String,
  userId: String,
  userName: String,
  userPhone: String,
  driverId: String,
  driverName: String,
  pickupLocation: String,
  dropoffLocation: String,
  bookingType: 'driver_only' | 'driver_with_vehicle',
  status: 'pending' | 'accepted' | 'rejected' | 'ongoing' | 'completed' | 'cancelled',
  fare: Number,
  isPaid: Boolean,
  paymentId: String,
  paymentMethod: String,
  createdAt: Timestamp,
  acceptedAt: Timestamp,
  completedAt: Timestamp
}
```

### 3. reviews
```javascript
{
  id: String,
  bookingId: String,
  userId: String,
  userName: String,
  driverId: String,
  rating: Number (1-5),
  review: String,
  createdAt: Timestamp
}
```

### 4. complaints
```javascript
{
  id: String,
  userId: String,
  userName: String,
  subject: String,
  description: String,
  driverId: String (optional),
  bookingId: String (optional),
  status: 'open' | 'resolved',
  adminResponse: String,
  createdAt: Timestamp
}
```

### 5. notifications
```javascript
{
  id: String,
  userId: String (or driverId),
  title: String,
  message: String,
  type: String,
  bookingId: String,
  read: Boolean,
  createdAt: Timestamp
}
```

---

## 🔄 Complete User Flow

### User Books a Ride:
1. User opens app → Views available drivers
2. Selects driver → Opens booking form
3. Fills details → Submits booking
4. Booking status: **Pending**
5. Notification sent to driver

### Driver Responds:
**If Accept:**
6. Driver enters fare → Accepts booking
7. User receives notification → Fare: ₹500
8. User clicks "Pay Now" → Payment screen
9. User pays → Status: **Ongoing**
10. Driver receives payment notification

**If Reject:**
6. Driver rejects → User gets notification
7. User sees: "Try another driver"

### After Ride:
11. Driver marks as completed
12. User receives notification
13. User submits review & rating
14. Ride appears in history

---

## 📱 Screen Priority

### Must Implement First:
1. ✅ Driver availability toggle (dashboard)
2. ✅ Booking requests screen (driver)
3. ✅ Available drivers screen (user)
4. ✅ Booking form screen (user)
5. ✅ Accept/Reject with fare (driver)
6. ✅ Payment screen (user)
7. ✅ Notifications (both)

### Implement Next:
8. Review & rating (user)
9. Ride history (user)
10. Earnings tracking (driver)
11. Profile management (both)
12. Complaint system (user)

---

## 🎯 Next Steps

I'll now create the priority screens one by one. Would you like me to start with:

1. **Driver Booking Requests Screen** - Shows pending bookings to driver
2. **User Available Drivers Screen** - Shows available drivers to user
3. **Booking Form Screen** - User creates booking
4. **Driver Availability Toggle** - Update driver dashboard

Which one should I create first?

---

**Status:** 📝 Planning Complete, Ready to Implement
**Services Created:** ✅ driver_service.dart, user_service.dart
**Models Created:** ✅ booking_model.dart
