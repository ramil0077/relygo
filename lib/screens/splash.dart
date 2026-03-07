import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

import 'package:relygo/constants.dart';
<<<<<<< HEAD
import 'package:relygo/widgets/auth_wrapper.dart';
=======

import 'package:relygo/screens/signin_screen.dart';
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
<<<<<<< HEAD

  late Animation<double> _logoScaleAnimation;
=======
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
<<<<<<< HEAD
  late Animation<double> _buttonScaleAnimation;
=======
  late Animation<double> _buttonSlideAnimation;
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

<<<<<<< HEAD
    // Logo fade and subtle scale (no rotation/pulse)
    _logoScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
=======
    // Logo Opacity and Scale
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Button animations
    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

<<<<<<< HEAD
    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
=======
    _buttonSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Start button animation after text
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
<<<<<<< HEAD
  // Start repeating logo animation (fade in/out + subtle scale)
  _logoController.repeat(reverse: true);
=======
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

<<<<<<< HEAD
              // Animated Logo (fade in/out + subtle scale, no spin or radial gradient)
              FadeTransition(
                opacity: _logoOpacityAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/logooo.png",
                      height: 160,
                      width: 160,
                      fit: BoxFit.contain,
=======
              // Animated Logo
              AnimatedBuilder(
                animation: _logoOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent, // Removed shadow/gradient
                      ),
                      child: Image.asset(
                        "assets/logooo.png",
                        height: 140,
                        width: 140,
                      ),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Animated Title
              AnimatedBuilder(
                animation: Listenable.merge([
                  _textFadeAnimation,
                  _textSlideAnimation,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _textSlideAnimation.value),
                    child: Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            "Welcome to RelyGO",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Mycolors.basecolor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your On-Demand Driver Companion",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Mycolors.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Animated Get Started button
              AnimatedBuilder(
                animation: Listenable.merge([
                  _buttonFadeAnimation,
                  _buttonSlideAnimation,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _buttonSlideAnimation.value),
                    child: Opacity(
                      opacity: _buttonFadeAnimation.value,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthWrapper(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolors.basecolor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0, // Clean professional flat look
                          ),
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Animated Terms text
              AnimatedBuilder(
                animation: _buttonFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _buttonFadeAnimation.value,
                    child: Text(
                      "By continuing, you agree to our Terms & Privacy",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Mycolors.gray,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
