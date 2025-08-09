import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(151, 75, 24, 1),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Mycolors.basecolor, Mycolors.textcolor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 85),
              Text(
                "Welcome to RelyGO",
                style: GoogleFonts.allerta(
                  color: Mycolors.textcolor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              Text("What are you looking for today?",style: GoogleFonts.allerta,)
            ],
          ),
        ),
      ),
    );
  }
}
