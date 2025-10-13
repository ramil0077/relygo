# Authentication System Documentation

## Overview
The RelyGO app implements a comprehensive authentication system using Firebase Authentication, Cloudinary for media storage, and Firestore for user data management.

## Features

### 1. User Authentication
- **Email/Password Authentication**: Users can sign up and sign in using email and password
- **Password Reset**: Users can reset their password via email
- **Role-based Access**: Different user types (User, Driver, Admin) with appropriate dashboards
- **Authentication State Management**: Automatic login state handling

### 2. User Registration
- **User Registration**: Basic user account creation
- **Driver Registration**: Extended registration with document uploads
- **Document Verification**: Cloudinary integration for document storage
- **Admin Approval**: Driver applications require admin approval

### 3. Media Management
- **Cloudinary Integration**: Secure media upload and storage
- **Document Upload**: Support for multiple document types
- **Image Validation**: File type and size validation
- **Firestore Integration**: Media URLs stored in Firestore

## Architecture

### Services

#### AuthService (`lib/services/auth_service.dart`)
Central authentication service handling all auth operations:

```dart
// Sign in
final result = await AuthService.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Create user
final result = await AuthService.createUserWithEmailAndPassword(
  email: email,
  password: password,
  name: name,
  phone: phone,
  userType: 'user',
);

// Reset password
final result = await AuthService.resetPassword(email);
```

#### CloudinaryService (`lib/services/cloudinary_service.dart`)
Media upload and management service:

```dart
// Upload single image
final url = await CloudinaryService.uploadImage(file, folder);

// Upload multiple images
final urls = await CloudinaryService.uploadMultipleImages(files, folder);

// Upload profile image
final url = await CloudinaryService.uploadProfileImage(file, userId);
```

### Widgets

#### AuthWrapper (`lib/widgets/auth_wrapper.dart`)
Handles authentication state and routing:

- Automatically redirects to appropriate dashboard based on user role
- Shows pending approval screen for drivers awaiting admin approval
- Manages authentication state changes

#### ImageUploadWidget (`lib/widgets/image_upload_widget.dart`)
Reusable component for image uploads:

- Image selection from gallery
- File validation (type, size)
- Upload progress indication
- Error handling

### Screens

#### SignInScreen (`lib/screens/signin_screen.dart`)
- Email/password login form
- Demo credentials display
- Forgot password link
- Registration options

#### UserRegistrationScreen (`lib/screens/user_registration_screen.dart`)
- Basic user registration form
- Terms and conditions
- Automatic dashboard redirect

#### DriverRegistrationScreen (`lib/screens/driver_registration_screen.dart`)
- Extended registration form
- Vehicle information
- Document upload requirements
- Admin approval workflow

#### ForgotPasswordScreen (`lib/screens/forgot_password_screen.dart`)
- Password reset email functionality
- Success confirmation
- Error handling

## User Flow

### 1. User Registration Flow
1. User selects "Sign Up" → User Registration
2. Fills registration form
3. Creates Firebase Auth account
4. Saves user data to Firestore
5. Redirects to User Dashboard

### 2. Driver Registration Flow
1. User selects "Sign Up" → Driver Registration
2. Fills personal information
3. Fills vehicle information
4. Uploads required documents (License, Registration, Insurance)
5. Creates Firebase Auth account
6. Saves driver data with documents to Firestore
7. Shows pending approval screen
8. Admin reviews and approves/rejects

### 3. Login Flow
1. User enters credentials
2. Firebase Authentication validates
3. Retrieves user data from Firestore
4. Determines user role and status
5. Redirects to appropriate dashboard

### 4. Password Reset Flow
1. User clicks "Forgot Password"
2. Enters email address
3. Firebase sends reset email
4. User follows email instructions
5. Returns to login screen

## Data Structure

### Firestore User Document
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "userType": "driver",
  "status": "approved",
  "profileImage": "https://cloudinary.com/image.jpg",
  "documents": {
    "license": "https://cloudinary.com/license.jpg",
    "vehicleRegistration": "https://cloudinary.com/registration.jpg",
    "insurance": "https://cloudinary.com/insurance.jpg"
  },
  "licenseNumber": "DL123456",
  "vehicleType": "Sedan",
  "vehicleNumber": "ABC123",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Security Features

### 1. Input Validation
- Email format validation
- Password strength requirements
- Phone number validation
- File type and size validation

### 2. Error Handling
- Comprehensive error messages
- User-friendly error display
- Network error handling
- Authentication error handling

### 3. Data Protection
- Secure Firebase Authentication
- Cloudinary secure uploads
- Firestore security rules
- User data encryption

## Configuration

### Firebase Setup
1. Firebase project created
2. Authentication enabled
3. Firestore database configured
4. Security rules implemented

### Cloudinary Setup
1. Cloudinary account created
2. Upload presets configured
3. API keys secured
4. Folder structure organized

## Testing

### Unit Tests
- AuthService functionality
- CloudinaryService operations
- Input validation
- Error handling

### Integration Tests
- Complete registration flow
- Login/logout cycle
- Document upload process
- Role-based routing

## Deployment Considerations

### Environment Variables
- Firebase configuration
- Cloudinary credentials
- API endpoints

### Security Rules
- Firestore security rules
- Cloudinary upload restrictions
- Authentication requirements

## Troubleshooting

### Common Issues
1. **Authentication Errors**: Check Firebase configuration
2. **Upload Failures**: Verify Cloudinary settings
3. **Navigation Issues**: Check user role and status
4. **Document Upload**: Ensure all required documents uploaded

### Debug Information
- Console logging for errors
- User feedback for operations
- Loading states for async operations
- Error messages for failures

## Future Enhancements

### Planned Features
1. **Social Login**: Google, Facebook integration
2. **Two-Factor Authentication**: SMS/Email verification
3. **Biometric Authentication**: Fingerprint/Face ID
4. **Advanced Document Verification**: OCR integration
5. **Real-time Notifications**: Push notifications for status updates

### Performance Optimizations
1. **Image Compression**: Automatic image optimization
2. **Caching**: Local data caching
3. **Offline Support**: Offline authentication
4. **Background Sync**: Automatic data synchronization
