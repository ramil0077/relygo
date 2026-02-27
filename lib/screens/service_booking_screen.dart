import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  String _selectedService = "driver_with_vehicle";
  String _selectedVehicle = "Car";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? _driverId;
  String? _driverName;
  int? _estimatedPrice;
  bool _detectingLocation = false;

  @override
  void initState() {
    super.initState();
    // Read driver args if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        setState(() {
          _driverId = args['driverId']?.toString();
          _driverName = args['driverName']?.toString();
          final vehicleArg = args['vehicle']?.toString();
          if (vehicleArg != null && vehicleArg.isNotEmpty) {
            _selectedVehicle = vehicleArg;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  /// Auto-detect current location and fill pickup field
  Future<void> _detectCurrentLocation() async {
    setState(() => _detectingLocation = true);
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location services are disabled. Please enable GPS.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Mycolors.orange,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location permission denied.',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Mycolors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permission permanently denied. Enable it in app settings.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Mycolors.red,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final parts = <String>[];
        if ((place.name ?? '').isNotEmpty &&
            place.name != place.street &&
            place.name != place.thoroughfare) {
          parts.add(place.name!);
        }
        if ((place.street ?? '').isNotEmpty) parts.add(place.street!);
        if ((place.subLocality ?? '').isNotEmpty) parts.add(place.subLocality!);
        if ((place.locality ?? '').isNotEmpty) parts.add(place.locality!);
        if ((place.administrativeArea ?? '').isNotEmpty) {
          parts.add(place.administrativeArea!);
        }

        final address = parts.isNotEmpty
            ? parts.join(', ')
            : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

        setState(() {
          _pickupController.text = address;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location detected!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Mycolors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get location. Please enter manually.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Mycolors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await Navigator.maybePop(context);
          },
        ),
        title: Text(
          "Book a Service",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Type Selection
              Text(
                "Select Service Type",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildServiceTypeCard(
                      "Driver\nOnly",
                      Icons.person,
                      "driver_only",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildServiceTypeCard(
                      "Driver +\nVehicle",
                      Icons.directions_car,
                      "driver_with_vehicle",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Vehicle Type Selection (only show if no specific driver selected)
              if (_driverId == null) ...[
                Text(
                  "Select Vehicle Type",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildVehicleCard(
                        "Car",
                        Icons.directions_car,
                        "Car",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildVehicleCard(
                        "Bike",
                        Icons.two_wheeler,
                        "Bike",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildVehicleCard(
                        "Auto",
                        Icons.local_taxi,
                        "Auto",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ] else ...[
                // Show selected driver's info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Mycolors.basecolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Mycolors.basecolor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Mycolors.basecolor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Driver: $_driverName",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Mycolors.basecolor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getVehicleIcon(_selectedVehicle),
                            color: Mycolors.basecolor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Vehicle: $_selectedVehicle",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Mycolors.basecolor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Pickup Location ──────────────────────────────────────────
              Text(
                "Pickup Location",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pickupController,
                      decoration: InputDecoration(
                        hintText: "Enter pickup location",
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Mycolors.basecolor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 📍 Auto-Location Button
                  Tooltip(
                    message: 'Use my current location',
                    child: InkWell(
                      onTap: _detectingLocation ? null : _detectCurrentLocation,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 50,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Mycolors.basecolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Mycolors.basecolor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _detectingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap 📍 to auto-detect your current location',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Mycolors.gray,
                ),
              ),
              const SizedBox(height: 20),

              // ── Destination ──────────────────────────────────────────────
              Text(
                "Destination",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: "Enter destination",
                  prefixIcon: Icon(Icons.place, color: Mycolors.basecolor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Mycolors.basecolor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedDate != null
                                      ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                      : "Select Date",
                                  style: GoogleFonts.poppins(
                                    color: _selectedDate != null
                                        ? Colors.black
                                        : Mycolors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Mycolors.basecolor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : "Select Time",
                                  style: GoogleFonts.poppins(
                                    color: _selectedTime != null
                                        ? Colors.black
                                        : Mycolors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Special Instructions
              Text(
                "Special Instructions (Optional)",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Any special requirements...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Price Estimate
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Mycolors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Estimated Price",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _estimatedPrice != null ? "₹${_estimatedPrice}" : "—",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Book Now Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Book Now",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard(String title, dynamic icon, String value) {
    bool isSelected = _selectedService == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Mycolors.basecolor,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(String title, dynamic icon, String value) {
    bool isSelected = _selectedVehicle == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Mycolors.basecolor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'auto':
        return Icons.local_taxi;
      default:
        return Icons.directions_car;
    }
  }

  Future<void> _createBooking() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to book'),
          backgroundColor: Mycolors.red,
        ),
      );
      return;
    }

    if (_pickupController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a pickup location',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Mycolors.orange,
        ),
      );
      return;
    }

    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a destination',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Mycolors.orange,
        ),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'driverId': _driverId,
        'driverName': _driverName,
        'service': _selectedService,
        'vehicle': _selectedVehicle,
        'pickup': _pickupController.text.trim(),
        'destination': _destinationController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
        'scheduledDate': _selectedDate != null
            ? Timestamp.fromDate(
                DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime?.hour ?? 0,
                  _selectedTime?.minute ?? 0,
                ),
              )
            : null,
      };

      await FirebaseFirestore.instance.collection('ride_requests').add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request sent to driver'),
          backgroundColor: Mycolors.green,
        ),
      );
      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }
}
