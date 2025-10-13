# Admin Approval System Documentation

## Overview
The RelyGO app now implements a proper admin approval system where drivers must be approved by administrators before they can access the driver dashboard. This replaces the demo user system with a real-world workflow.

## System Flow

### 1. Driver Registration
- Drivers register with personal information, vehicle details, and required documents
- Documents are uploaded to Cloudinary and URLs stored in Firestore
- Driver status is set to "pending" by default
- Driver sees "Application Under Review" screen

### 2. Admin Review Process
- Admins can view all pending driver applications
- Admins can approve or reject applications with reasons
- Real-time updates show application status changes
- Statistics show pending, approved, and rejected counts

### 3. Driver Status After Review
- **Approved**: Driver can access driver dashboard
- **Rejected**: Driver sees rejection screen with option to reapply
- **Pending**: Driver continues to see "Under Review" screen

## Key Components

### Services

#### AdminService (`lib/services/admin_service.dart`)
Handles all admin operations for driver management:

```dart
// Get pending drivers
final pendingDrivers = await AdminService.getPendingDrivers();

// Approve a driver
await AdminService.approveDriver(driverId);

// Reject a driver with reason
await AdminService.rejectDriver(driverId, reason);

// Get application statistics
final stats = await AdminService.getApplicationStats();
```

#### AuthService (Enhanced)
- Updated to handle user status checking
- Proper role-based routing based on approval status
- Support for pending, approved, and rejected states

### Screens

#### AdminDriverApprovalScreen (`lib/screens/admin_driver_approval_screen.dart`)
Comprehensive driver approval interface:
- **Real-time Statistics**: Pending, approved, rejected counts
- **Tabbed Interface**: View by status (pending/approved/rejected)
- **Driver Cards**: Complete driver information display
- **Action Buttons**: Approve/reject with confirmation
- **Rejection Reasons**: Text input for rejection explanations

#### AuthWrapper (Enhanced)
Smart routing based on user status:
- **Users**: Direct access to user dashboard
- **Drivers (Approved)**: Access to driver dashboard
- **Drivers (Pending)**: "Under Review" screen
- **Drivers (Rejected)**: "Application Rejected" screen with reapply option
- **Admins**: Access to admin dashboard

### User Experience

#### For Drivers
1. **Registration**: Complete form with documents
2. **Pending State**: Clear "Under Review" message
3. **Approval**: Automatic redirect to driver dashboard
4. **Rejection**: Clear rejection message with reapply option

#### For Admins
1. **Dashboard**: Overview with statistics
2. **Driver Management**: Access to approval system
3. **Review Process**: Easy approve/reject with reasons
4. **Real-time Updates**: Live status changes

## Data Structure

### User Document in Firestore
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "userType": "driver",
  "status": "pending", // pending, approved, rejected
  "documents": {
    "license": "https://cloudinary.com/license.jpg",
    "vehicleRegistration": "https://cloudinary.com/registration.jpg",
    "insurance": "https://cloudinary.com/insurance.jpg"
  },
  "licenseNumber": "DL123456",
  "vehicleType": "Sedan",
  "vehicleNumber": "ABC123",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "approvedAt": "timestamp", // Only if approved
  "rejectedAt": "timestamp", // Only if rejected
  "rejectionReason": "Invalid documents" // Only if rejected
}
```

## Features

### Real-time Updates
- Live statistics updates
- Real-time driver list changes
- Instant status updates after admin actions

### Comprehensive Information
- Driver personal details
- Vehicle information
- Document verification
- Application timestamps

### Admin Controls
- Bulk approval/rejection
- Reason tracking for rejections
- Statistics and analytics
- Search and filter capabilities

### Security
- Role-based access control
- Status-based routing
- Secure document storage
- Admin-only approval actions

## Workflow Examples

### Successful Driver Application
1. Driver registers → Status: "pending"
2. Admin reviews application
3. Admin approves → Status: "approved"
4. Driver can login and access driver dashboard

### Rejected Driver Application
1. Driver registers → Status: "pending"
2. Admin reviews application
3. Admin rejects with reason → Status: "rejected"
4. Driver sees rejection screen with reapply option

### Admin Review Process
1. Admin opens driver management
2. Views pending applications
3. Reviews driver information and documents
4. Approves or rejects with reason
5. System updates status and notifies driver

## Technical Implementation

### Status Management
- **pending**: Initial state for new driver applications
- **approved**: Driver can access driver features
- **rejected**: Driver cannot access driver features

### Real-time Features
- Firestore listeners for live updates
- Stream-based data management
- Automatic UI updates

### Error Handling
- Comprehensive error messages
- Network error handling
- Validation for admin actions

## Benefits

### For Drivers
- Clear application status
- Professional approval process
- Opportunity to reapply if rejected
- Secure document handling

### For Admins
- Efficient review process
- Complete driver information
- Statistics and analytics
- Reason tracking for decisions

### For Platform
- Quality control for drivers
- Professional image
- Secure document verification
- Scalable approval system

## Future Enhancements

### Planned Features
- Email notifications for status changes
- Document verification automation
- Advanced filtering and search
- Bulk approval operations
- Application history tracking

### Analytics
- Approval rate statistics
- Common rejection reasons
- Processing time metrics
- Driver performance tracking

This system provides a professional, scalable solution for driver onboarding that ensures quality control while providing a smooth user experience for both drivers and administrators.
