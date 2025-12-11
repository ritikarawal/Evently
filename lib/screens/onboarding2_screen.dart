import 'package:event_planner/screens/onboarding3_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_planner/screens/login_screen.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  final Color background = const Color(0xFFF8DCDC);
  final Color accent = const Color(0xFF7F0F23);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/eventlylogo.png',
                    width: 60,
                    height: 60,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/onboarding2.jpg'),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Stay Organized!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            ' Manage Guest Lists & Details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 30,
                              height: 10,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Onboarding3Screen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
