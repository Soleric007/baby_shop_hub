// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_nav_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasNavigated = false; // Prevent multiple navigation calls

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startSplashSequence() {
    // Start animations with proper error handling
    _startAnimations();
    
    // Navigate after all animations complete
    _scheduleNavigation();
  }

  void _startAnimations() {
    // Use WidgetsBinding to ensure proper timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Start scale animation first
        _scaleController.forward().catchError((error) {
          debugPrint('Scale animation error: $error');
        });
        
        // Then fade animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _fadeController.forward().catchError((error) {
              debugPrint('Fade animation error: $error');
            });
          }
        });
        
        // Finally slide animation
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            _slideController.forward().catchError((error) {
              debugPrint('Slide animation error: $error');
            });
          }
        });
      }
    });
  }

  void _scheduleNavigation() {
    // Give enough time for animations to complete
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && !_hasNavigated) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (_hasNavigated || !mounted) return;
    
    _hasNavigated = true;
    
    try {
      // Check if user is already logged in
      final prefs = await SharedPreferences.getInstance();
      final loggedInUser = prefs.getString('loggedInUser');
      
      if (!mounted) return;
      
      Widget targetScreen;
      if (loggedInUser != null && loggedInUser.isNotEmpty) {
        // User is logged in, go to main app
        targetScreen = const BottomNavScreen();
      } else {
        // User not logged in, go to login screen
        targetScreen = const LoginScreen();
      }

      // Use Navigator.pushAndRemoveUntil to completely replace splash screen
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
          settings: RouteSettings(
            name: loggedInUser != null ? '/main' : '/login',
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback navigation
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers safely
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF4F4),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Animated Logo
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.child_care,
                        size: 60,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'BabyShopHub',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF444466),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.pinkAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Everything for your little one 💕',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666688),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Loading Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pinkAccent,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading your baby essentials...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF888899),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Made with 💖 for super parents',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999AAA),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}