import 'dart:io';

void main() {
  var filesToFix = [
    'web/_redirects',
    'web/index.html',
    'lib/widgets/auth_wrapper.dart',
    'lib/services/driver_service.dart',
    'lib/services/email_service.dart',
    'lib/services/location_service.dart',
    'lib/services/user_service.dart',
    'lib/services/auth_service.dart',
    'lib/services/admin_service.dart',
    'lib/screens/admin_dashboard_screen.dart',
    'lib/screens/admin_login_screen.dart',
    'lib/screens/driver_earnings_screen.dart',
    'lib/screens/driver_profile_screen.dart',
    'lib/screens/driver_reviews_screen.dart',
    'lib/screens/driver_ride_history_screen.dart',
    'lib/screens/driver_tracking_screen.dart',
    'lib/screens/responsive_user_dashboard_screen.dart',
    'lib/screens/ride_history_screen.dart',
    'lib/screens/service_booking_screen.dart',
    'lib/screens/signin_screen.dart',
    'lib/screens/splash.dart',
    'lib/screens/user_dashboard_screen.dart',
    'lib/screens/user_profile_screen.dart',
    'lib/screens/driver_management_screen.dart',
    'lib/screens/driver_dashboard_screen.dart',
    'lib/main.dart',
    'android/app/src/main/AndroidManifest.xml'
  ];

  int totalFixed = 0;
  for (String path in filesToFix) {
    File file = File(path);
    if (!file.existsSync()) continue;
    
    List<String> lines = file.readAsLinesSync();
    List<String> newLines = [];
    int resolvingState = 0; // 0 normal, 1 HEAD, 2 INCOMING
    bool changed = false;

    for (String line in lines) {
      if (line.startsWith('<<<<<<< HEAD')) {
        resolvingState = 1;
        changed = true;
      } else if (line.startsWith('=======')) {
        if (resolvingState == 1) {
          resolvingState = 2;
        } else {
          newLines.add(line);
        }
      } else if (line.startsWith('>>>>>>>')) {
        if (resolvingState == 2 || resolvingState == 1) {
          resolvingState = 0;
        } else {
          newLines.add(line);
        }
      } else {
        if (resolvingState == 0 || resolvingState == 1) {
          newLines.add(line);
        }
      }
    }
    
    // Safety handling for missing newlines at EOF
    if (changed) {
      file.writeAsStringSync(newLines.join('\n'));
      print('Fixed \${path}');
      totalFixed++;
    }
  }
  print('Total fixed: \$totalFixed');
}
