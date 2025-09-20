import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class AdminTruckSelectionScreen extends StatefulWidget {
  const AdminTruckSelectionScreen({super.key});

  @override
  State<AdminTruckSelectionScreen> createState() =>
      _AdminTruckSelectionScreenState();
}

class _AdminTruckSelectionScreenState extends State<AdminTruckSelectionScreen> {
  String? _selectedTruck;

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
          "Admin Panel",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                "Select Truck",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Choose the type of truck for this assignment",
                style: GoogleFonts.poppins(fontSize: 16, color: Mycolors.gray),
              ),
              const SizedBox(height: 40),

              // Truck Selection Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final truckTypes = [
                      "Small Truck",
                      "Medium Truck",
                      "Large Truck",
                      "Refrigerated Truck",
                      "Flatbed Truck",
                      "Container Truck",
                    ];

                    final truckIcons = [
                      Icons.local_shipping,
                      Icons.local_shipping,
                      Icons.local_shipping,
                      Icons.ac_unit,
                      Icons.view_in_ar,
                      Icons.inventory,
                    ];

                    final isSelected = _selectedTruck == truckTypes[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTruck = truckTypes[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Mycolors.basecolor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Mycolors.basecolor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Mycolors.basecolor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              truckIcons[index],
                              size: 40,
                              color: isSelected
                                  ? Colors.white
                                  : Mycolors.basecolor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              truckTypes[index],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            if (isSelected) const SizedBox(height: 5),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedTruck != null
                      ? () {
                          // Process truck selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: $_selectedTruck'),
                              backgroundColor: Mycolors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTruck != null
                        ? Mycolors.basecolor
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Continue",
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
}
