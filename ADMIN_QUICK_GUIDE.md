# Admin Panel Quick Reference Guide

## 🔐 Login Credentials
```
Email: admin@relygo.com
Password: admin123
```

## 📱 Main Features

### 1️⃣ Dashboard (Home Tab)
**What you see:**
- Real-time statistics (Total Users, Active Drivers, Pending Approvals, Open Complaints)
- Quick action buttons
- Recent activity feed (currently placeholder)

**Quick Actions:**
- Navigate to Users, Drivers, Analytics, or Complaints

---

### 2️⃣ User Management (Users Tab)
**Features:**
- ✅ View all registered users
- ✅ Click on user to see details
- ✅ View user's booking history
- ✅ View user's complaints
- ✅ Respond to user complaints

**How to respond to a complaint:**
1. Click on user
2. Go to "Complaints" tab
3. Click "Respond" button on complaint
4. Enter your response
5. Click "Send"

---

### 3️⃣ Driver Management (Drivers Tab)
**Features:**
- ✅ View all drivers (pending/approved/rejected)
- ✅ Approve/reject driver applications
- ✅ Chat with drivers in real-time

**How to approve a driver:**
1. Click "Driver Approvals" button
2. View pending drivers
3. Click "Approve" or "Reject"

**How to chat with a driver:**
1. Click on any driver from the list
2. Type message in text field
3. Click send button
4. Messages appear in real-time

---

### 4️⃣ Analytics & Feedback (Analytics Tab)
**Features:**
- ✅ View all user feedback
- ✅ See star ratings
- ✅ Access detailed service report

**How to view service report:**
1. Click "Service Report" button
2. See comprehensive analytics:
   - User/Driver counts
   - Booking statistics
   - Revenue analysis
   - Feedback ratings
3. Click "Refresh" to update data
4. Click "Export" (coming soon)

---

## 🗂️ Data Collections in Firestore

### Required Collections:
1. **users** - All users and drivers
2. **bookings** - Ride bookings
3. **complaints** - User/driver complaints
4. **messages** - Admin-driver chat
5. **feedback** - User ratings and reviews

### Sample Data Structures:

**User (Customer):**
```javascript
{
  name: "John Doe",
  email: "john@example.com",
  phone: "+91 98765 43210",
  userType: "user",
  createdAt: Timestamp
}
```

**Driver:**
```javascript
{
  name: "Jane Smith",
  email: "jane@example.com",
  phone: "+91 98765 43211",
  userType: "driver",
  status: "approved", // or "pending" or "rejected"
  vehicleType: "Sedan",
  vehicleNumber: "KL-01-AB-1234",
  documents: {
    license: "url_to_license_image",
    vehicleRegistration: "url_to_registration",
    insurance: "url_to_insurance"
  },
  createdAt: Timestamp
}
```

**Booking:**
```javascript
{
  userId: "user_id_here",
  driverId: "driver_id_here",
  driverName: "Jane Smith",
  pickupLocation: "Kozhikode Railway Station",
  dropoffLocation: "Beach Road",
  fare: 250,
  status: "completed", // or "pending", "ongoing", "cancelled"
  createdAt: Timestamp
}
```

**Complaint:**
```javascript
{
  userId: "user_id_here",
  userName: "John Doe",
  subject: "Late arrival",
  description: "Driver arrived 30 minutes late",
  status: "open", // or "resolved"
  adminResponse: "We apologize for the inconvenience...",
  createdAt: Timestamp,
  respondedAt: Timestamp
}
```

**Message (Chat):**
```javascript
{
  driverId: "driver_id_here",
  senderId: "admin",
  senderType: "admin", // or "driver"
  message: "Hello, how can I help you?",
  read: false,
  createdAt: Timestamp
}
```

**Feedback:**
```javascript
{
  userId: "user_id_here",
  userName: "John Doe",
  driverId: "driver_id_here",
  rating: 4.5,
  feedback: "Great service!",
  createdAt: Timestamp
}
```

---

## 🔍 Testing Without Real Data

If your Firestore is empty, add test data:

### Using Firebase Console:

1. **Add Test User:**
   - Collection: `users`
   - Add document with ID (auto or custom)
   - Fields: name, email, phone, userType="user"

2. **Add Test Driver:**
   - Collection: `users`
   - Fields: name, email, phone, userType="driver", status="pending"

3. **Add Test Booking:**
   - Collection: `bookings`
   - Fields: userId, pickupLocation, dropoffLocation, status="completed", fare=100

4. **Add Test Complaint:**
   - Collection: `complaints`
   - Fields: userId, userName, subject, description, status="open"

5. **Add Test Feedback:**
   - Collection: `feedback`
   - Fields: userId, userName, rating=5, feedback="Excellent!"

---

## 🎯 Common Admin Tasks

### Task 1: Approve New Driver
```
1. Open app → Login as admin
2. Go to "Drivers" tab
3. Click "Driver Approvals"
4. Review pending driver
5. Click "Approve"
```

### Task 2: Respond to User Complaint
```
1. Go to "Users" tab
2. Click on user with complaint
3. Switch to "Complaints" tab
4. Click "Respond" on complaint
5. Type response → Send
```

### Task 3: Chat with Driver
```
1. Go to "Drivers" tab
2. Click on driver from list
3. Type message → Send
4. Wait for driver's response (real-time)
```

### Task 4: View Service Analytics
```
1. Go to "Analytics" tab
2. Click "Service Report"
3. View all statistics
4. Click "Refresh" to update
```

### Task 5: Monitor Complaints
```
1. From Dashboard → Click "Complaints" quick action
   OR
2. Go to "Users" tab → Click user → Complaints tab
```

---

## ⚠️ Troubleshooting

### "No users found" in Users tab:
- Check if Firestore has users with `userType: "user"`
- Verify Firebase connection
- Check Firestore rules allow read access

### "No drivers found" in Drivers tab:
- Check if Firestore has users with `userType: "driver"`
- Add test driver with status "pending" or "approved"

### "No bookings found" for a user:
- Add booking with matching `userId`
- Ensure `createdAt` field exists (Timestamp type)

### Chat not working:
- Check if `messages` collection exists
- Verify internet connection
- Check Firestore rules allow write to messages

### Analytics showing zeros:
- Add test data to relevant collections
- Click "Refresh" button
- Check Firestore console for data

---

## 📊 Analytics Calculations

**Success Rate:**
```
(Completed Bookings / Total Bookings) × 100
```

**Average Fare:**
```
Total Revenue / Completed Bookings
```

**Average Rating:**
```
Sum of all ratings / Total feedback count
```

---

## 🔒 Security Notes

### For Production:
1. ❌ Remove hardcoded admin credentials
2. ✅ Implement Firebase Authentication
3. ✅ Add custom claims for admin role
4. ✅ Set up Firestore security rules
5. ✅ Enable audit logging
6. ✅ Implement session timeouts

### Recommended: Add Admin Role in Firebase Auth
```javascript
// Set custom claims (using Firebase Admin SDK)
admin.auth().setCustomUserClaims(uid, { admin: true });
```

---

## 🚀 Performance Tips

1. **Limit Query Results:**
   - Add `.limit(50)` to streams for large datasets
   - Implement pagination

2. **Index Firestore Queries:**
   - Create composite indexes for complex queries
   - Monitor index usage in Firebase Console

3. **Cache Data:**
   - Use local caching for frequently accessed data
   - Implement offline support

---

## 📞 Support

**Common Issues:**
- Login not working → Check credentials
- Data not showing → Check Firestore collections
- Real-time updates not working → Check internet connection
- Chat messages not sending → Check Firestore rules

**For Development Help:**
- Check Flutter console for errors
- Review Firestore console for data
- Test with sample data first

---

## ✅ Feature Checklist

- [x] Admin login with hardcoded credentials
- [x] View all users
- [x] View user bookings
- [x] View user complaints
- [x] Respond to complaints
- [x] View all drivers
- [x] Approve/reject drivers
- [x] Chat with drivers (real-time)
- [x] View feedback and ratings
- [x] Generate service report
- [x] Real-time data updates
- [x] Firestore integration

---

**Quick Start:** Login → Explore Dashboard → Test Each Tab → Add Sample Data if Empty

**Remember:** All data is real-time from Firestore. Changes reflect immediately!
