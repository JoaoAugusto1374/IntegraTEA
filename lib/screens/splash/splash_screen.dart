import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';

/// Tela de abertura do Cuidar+: símbolo radial orgânico formado por pétalas
/// pastel sobrepostas, transmitindo cuidado e acolhimento antes de qualquer
/// dado carregar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final isLoggedIn = AuthRepository().isLoggedIn;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => isLoggedIn ? const AppShell() : const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              child: SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(painter: _RadialBloomPainter()),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _controller,
              child: Text('Cuidar+', style: AppTextStyles.displayLg),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _controller,
              child: Text(
                'Cuidado contínuo, do jeito certo.',
                style: AppTextStyles.body.copyWith(color: AppColors.primaryText.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desenha o símbolo do Cuidar+: pétalas orgânicas (gotas) dispostas em
/// simetria radial ao redor de um núcleo central, nas cores da marca.
class _RadialBloomPainter extends CustomPainter {
  static const _petalColors = [
    AppColors.peach,
    AppColors.mint,
    AppColors.lavender,
    AppColors.pastelYellow,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final petalCount = _petalColors.length;
    final radius = size.width * 0.28;

    for (var i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi / petalCount) * i - math.pi / 2;
      final petalCenter = center + Offset(math.cos(angle), math.sin(angle)) * radius;

      final paint = Paint()..color = _petalColors[i].withValues(alpha: 0.9);

      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle + math.pi / 2);

      // Gota orgânica: círculo esticado com uma ponta, via path com curvas.
      final path = Path()
        ..moveTo(0, -radius * 0.95)
        ..quadraticBezierTo(radius * 0.85, -radius * 0.2, 0, radius * 0.75)
        ..quadraticBezierTo(-radius * 0.85, -radius * 0.2, 0, -radius * 0.95)
        ..close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Núcleo central
    canvas.drawCircle(center, size.width * 0.16, Paint()..color = AppColors.primaryText);
    canvas.drawCircle(center, size.width * 0.10, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
