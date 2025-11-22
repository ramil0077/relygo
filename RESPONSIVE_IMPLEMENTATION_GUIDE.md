# Responsive Implementation Guide

This guide shows how to make all screens responsive in the RelyGO app.

## Pattern for Making Screens Responsive

### 1. Import Required Utilities

```dart
import 'package:relygo/utils/responsive.dart';
import 'package:relygo/constants.dart'; // For ResponsiveTextStyles and ResponsiveSpacing
```

### 2. Replace Hardcoded Values

#### Padding
```dart
// Before
padding: const EdgeInsets.all(16)

// After
padding: ResponsiveUtils.getResponsivePadding(context)
```

#### Spacing (SizedBox height/width)
```dart
// Before
const SizedBox(height: 20)

// After
SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28))
// OR use helper
SizedBox(height: ResponsiveSpacing.getMediumSpacing(context))
```

#### Font Sizes
```dart
// Before
fontSize: 18

// After
fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22)
// OR use text styles
style: ResponsiveTextStyles.getTitleStyle(context)
```

#### Icon Sizes
```dart
// Before
Icon(Icons.home, size: 24)

// After
Icon(Icons.home, size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28))
```

#### Border Radius
```dart
// Before
BorderRadius.circular(12)

// After
BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16))
```

#### Elevation
```dart
// Before
elevation: 2

// After
elevation: ResponsiveUtils.getResponsiveElevation(context, mobile: 2, tablet: 3, desktop: 4)
```

### 3. Use Responsive Widgets

```dart
// For different layouts per device
ResponsiveWidget(
  mobile: _buildMobileLayout(context),
  tablet: _buildTabletLayout(context),
  desktop: _buildDesktopLayout(context),
)

// For layout constraints
ResponsiveLayoutBuilder(
  builder: (context, constraints) {
    // Your responsive layout
  },
)
```

### 4. Use Responsive Text Styles

```dart
// Title
Text('Title', style: ResponsiveTextStyles.getTitleStyle(context))

// Subtitle
Text('Subtitle', style: ResponsiveTextStyles.getSubtitleStyle(context))

// Card Title
Text('Card Title', style: ResponsiveTextStyles.getCardTitleStyle(context))
```

### 5. Use Responsive Spacing Helpers

```dart
SizedBox(height: ResponsiveSpacing.getSmallSpacing(context))
SizedBox(height: ResponsiveSpacing.getMediumSpacing(context))
SizedBox(height: ResponsiveSpacing.getLargeSpacing(context))
SizedBox(height: ResponsiveSpacing.getExtraLargeSpacing(context))
```

## Screens Already Made Responsive

✅ driver_tracking_screen.dart
✅ payment_screen.dart
✅ admin_login_screen.dart
✅ signin_screen.dart
✅ driver_dashboard_screen.dart (already responsive)
✅ user_dashboard_screen.dart (already responsive)
✅ welcome_screen.dart (already responsive)

## Remaining Screens to Update

- user_registration_screen.dart
- driver_registration_screen.dart
- service_booking_screen.dart
- service_selection_screen.dart
- chat_detail_screen.dart
- driver_notifications_screen.dart
- user_profile_screen.dart
- driver_profile_screen.dart
- ride_history_screen.dart
- driver_ride_history_screen.dart
- admin screens (various)
- Other utility screens

## Quick Reference

### Common Replacements

| Old | New |
|-----|-----|
| `const EdgeInsets.all(16)` | `ResponsiveUtils.getResponsivePadding(context)` |
| `const SizedBox(height: 20)` | `SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28))` |
| `fontSize: 18` | `fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22)` |
| `size: 24` | `size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28)` |
| `BorderRadius.circular(12)` | `BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16))` |

