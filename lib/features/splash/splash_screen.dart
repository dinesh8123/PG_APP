import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'app_logo.dart';

const splashDuration = Duration(milliseconds: 5500);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: splashDuration,
  )..forward();

  late final Animation<double> _logoScale = Tween(
    begin: 0.6,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.25, curve: Curves.elasticOut),
    ),
  );

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.15, curve: Curves.easeOut),
  );

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.20, 0.38, curve: Curves.easeOut),
  );

  late final Animation<Offset> _titleSlide = Tween(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.20,
        0.38,
        curve: Curves.easeOutCubic,
      ),
    ),
  );

  late final Animation<double> _tagFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.34, 0.52, curve: Curves.easeOut),
  );

  late final Animation<double> _barFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.60, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kHeroGradient),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _circle(240, 0.07),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _circle(300, 0.06),
            ),
            Positioned(
              bottom: 140,
              right: -40,
              child: _circle(120, 0.05),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const AppLogo(size: 132),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'PG App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _tagFade,
                      child: Text(
                        'Rent  \u2022  Bijli  \u2022  Food  \u2022  Stay',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FadeTransition(
                      opacity: _barFade,
                      child: SizedBox(
                        width: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 5,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _barFade,
                      child: Text(
                        'Getting things ready...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: _tagFade,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}
