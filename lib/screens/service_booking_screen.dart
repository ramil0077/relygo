import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  String _selectedService = "Ride";
  String _selectedVehicle = "Car";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
                      "Ride",
                      Icons.directions_car,
                      "Ride",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildServiceTypeCard(
                      "Delivery",
                      Icons.local_shipping,
                      "Delivery",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Vehicle Type Selection
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
                    child: _buildVehicleCard("Bike", Icons.two_wheeler, "Bike"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildVehicleCard("Auto", Icons.local_taxi, "Auto"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Pickup Location
              Text(
                "Pickup Location",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter pickup location",
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Mycolors.basecolor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Destination Location
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
                      "₹250 - ₹350",
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
                  onPressed: () {
                    _showBookingConfirmation();
                  },
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

  Widget _buildServiceTypeCard(String title, IconData icon, String value) {
    bool isSelected = _selectedService == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(String title, IconData icon, String value) {
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

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirm Booking",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Service: $_selectedService", style: GoogleFonts.poppins()),
              Text("Vehicle: $_selectedVehicle", style: GoogleFonts.poppins()),
              if (_selectedDate != null)
                Text(
                  "Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  style: GoogleFonts.poppins(),
                ),
              if (_selectedTime != null)
                Text(
                  "Time: ${_selectedTime!.format(context)}",
                  style: GoogleFonts.poppins(),
                ),
              const SizedBox(height: 10),
              Text(
                "Estimated Price: ₹250 - ₹350",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking confirmed! Driver will contact you soon.',
                    ),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Confirm", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
