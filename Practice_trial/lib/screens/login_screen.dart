import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'citizen_main_screen.dart';
import 'admin/admin_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _adminEmailCtrl =
      TextEditingController(text: 'admin@smartcity.gov.in');

  @override
  void dispose() {
    _adminEmailCtrl.dispose();
    super.dispose();
  }

  void _goAsCitizen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CitizenMainScreen()),
    );
  }

  void _goAsAdmin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // ── Hero ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentDark],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40,
              bottom: 36,
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏙️', style: TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('SmartCity',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Report. Track. Resolve.',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to report civic issues\nand track resolutions in your city',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.muted, height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  // Google button
                  GestureDetector(
                    onTap: _goAsCitizen,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('G',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4285F4))),
                          SizedBox(width: 12),
                          Text('Continue with Google',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444444))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('By signing in you agree to our Terms of Service',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 32),

                  // Admin section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Admin access',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _adminEmailCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: scInputDecoration('admin@smartcity.gov.in'),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _goAsAdmin,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.accentDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Sign in as Admin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
