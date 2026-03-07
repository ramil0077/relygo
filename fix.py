import re
import sys

def fix_driver_tracking(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove flutter_map, latlong2, geocoding
    content = content.replace("import 'package:flutter_map/flutter_map.dart';", "")
    content = content.replace("import 'package:latlong2/latlong.dart';", "")
    content = content.replace("import 'package:geocoding/geocoding.dart';", "")

    # 2. Fix widget.bookingData to widget.initialBookingData
    content = content.replace("widget.bookingData", "widget.initialBookingData")

    # 3. Fix initialBookingData setter 
    # Oops, initialBookingData was already in properties correctly, we just changed widget.initialBookingData['x'] which is good

    # 4. Remove the block with FlutterMap and merge conflicts
    # I saw in driver_tracking_screen:
    #             // Map View with live coordinates
    #             if (lat != null && lng != null)
    #                 Container(
    #                   height: 300,
    #                   ...
    #                       child: FlutterMap( ...
    # This block spans roughly from line 1024 to 1099. We can just use regular expression.
    pattern = r'// Map View with live coordinates.*?else\s+Container\([\s\S]*?child: Center\([\s\S]*?Icon\(Icons\.location_off[\s\S]*?\]\s*,\s*\)\s*,\s*\)\s*,\s*\)'
    content = re.sub(pattern, '', content, flags=re.DOTALL)

    # 5. Remove merge conflicts
    # <<<<<<< HEAD
    #     if (!isActive) {
    #     if (status != 'started' || driverId == null) {
    # =======
    #     if (!['accepted', 'ongoing', 'started'].contains(status) || driverId == null) {
    # >>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
    conflict_1_pattern = r'<<<<<<< HEAD.*?if \(\!isActive\) \{\s*if \(status \!\= \'started\' \|\| driverId \=\= null\) \{.*?=======\s*.*?(if \(\!\[\'accepted\'.*?\).*?)\n.*?>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10'
    content = re.sub(conflict_1_pattern, r'\1', content, flags=re.DOTALL)

    conflict_2_pattern = r'<<<<<<< HEAD\s*\'Live tracking will be available when driver accepts the ride\',\s*=======\s*(\'Live tracking will be available once the driver accepts the ride\.\',)\s*>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10'
    content = re.sub(conflict_2_pattern, r'\1', content, flags=re.DOTALL)

    # 6. Delete _buildTrackingStat which is unused and buggy
    stat_pattern = r'Widget _buildTrackingStat.*?\}\s*'
    content = re.sub(stat_pattern, '', content, flags=re.DOTALL)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    fix_driver_tracking(r'lib\screens\driver_tracking_screen.dart')
