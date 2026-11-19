import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../data/models.dart';
import '../../core/insta_loader.dart';
import '../splash/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _card => Theme.of(context).colorScheme.surface;
  Color get _field => Theme.of(context).inputDecorationTheme.fillColor!;
  Color get _stroke => Theme.of(context).colorScheme.outlineVariant;
  Color get _accent => Theme.of(context).colorScheme.primary;
  Color get _text => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _tint => Theme.of(context).colorScheme.primaryContainer;

  final auth = Get.find<AuthController>();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();

  bool _staff = false;
  Role _staffRole = Role.manager;
  bool _otpSent = false;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _timer;

  Role get _role => _staff ? _staffRole : Role.tenant;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendIn = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) timer.cancel();
    });
  }

  Future<void> _getOtp() async {
    FocusScope.of(context).unfocus();

    final error = auth.checkNumber(_role, _phone.text.trim());
    if (error != null) {
      return setState(() => _error = error);
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _busy = false;
      _otpSent = true;
      _otp.clear();
    });

    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _otpFocus.requestFocus(),
    );
  }

  Future<void> _verify() async {
    if (_otp.text.length < 4) {
      return setState(() => _error = 'Enter the 4-digit code');
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final error = auth.login(
      _role,
      _phone.text.trim(),
      _otp.text.trim(),
    );

    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
        _otp.clear();
      });
      _otpFocus.requestFocus();
    }
  }

  void _switchMode() {
    setState(() {
      _staff = !_staff;
      _otpSent = false;
      _error = null;
      _otp.clear();
      _timer?.cancel();
    });
  }

  String get _maskedPhone {
    final phone = _phone.text.trim();
    if (phone.length < 6) return '+91 $phone';

    return '+91 ${phone.substring(0, 2)}'
        '\u2022\u2022\u2022 \u2022\u2022'
        '${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 44),
                      _header(),
                      const SizedBox(height: 24),
                      _loginCard(),
                      const SizedBox(height: 22),
                      _staffBanner(),
                      const SizedBox(height: 14),
                      _featureTiles(),
                      const SizedBox(height: 22),
                      _terms(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Column(
        children: [
          Container(
            width: 190,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _accent.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
                radius: 0.75,
              ),
            ),
            child: const AppLogo(size: 92),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _stroke.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: _accent),
                const SizedBox(width: 8),
                Text(
                  _staff ? 'Owner & Manager Portal' : 'Resident & Guest Portal',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Welcome to your Haven',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _otpSent
                ? 'Enter the 4-digit code we just sent you'
                : 'Enter your 10-digit mobile number to\n'
                    'receive a one-time password (OTP)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      );

  Widget _loginCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _stroke.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_staff) ...[
              Row(
                children: [
                  _staffChip(
                    Role.manager,
                    'Manager',
                    Icons.badge_outlined,
                  ),
                  const SizedBox(width: 10),
                  _staffChip(Role.owner, 'Owner', Icons.key_outlined),
                ],
              ),
              const SizedBox(height: 18),
            ],
            Text(
              'Phone Number',
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _phoneRow(),
            if (!_otpSent) ...[
              const SizedBox(height: 8),
              Text(
                'Demo number: ${AuthController.testPhone}',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            _primaryButton(
              label: _otpSent ? 'Verify & Login' : 'Get OTP',
              onTap: _busy ? null : (_otpSent ? _verify : _getOtp),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _otpSent
                  ? _otpSection()
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      );

  Widget _staffChip(Role role, String label, IconData icon) {
    final selected = _staffRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _staffRole = role;
          _otpSent = false;
          _error = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accent.withValues(alpha: 0.16) : _field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _accent : _stroke,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? _accent : _muted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? _accent : _text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneRow() => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text(
                    '\u{1F1EE}\u{1F1F3}',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+91',
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _muted,
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 36, color: _stroke),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _phone,
                enabled: !_otpSent,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: _text,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
                cursorColor: _accent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
                onSubmitted: (_) => _getOtp(),
                decoration: InputDecoration(
                  hintText: '98765 43210',
                  hintStyle: TextStyle(
                    color: _muted,
                    fontSize: 22,
                  ),
                  filled: true,
                  fillColor: _field,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: _fieldBorder(_stroke),
                  enabledBorder: _fieldBorder(_stroke),
                  disabledBorder: _fieldBorder(
                    _stroke.withValues(alpha: 0.5),
                  ),
                  focusedBorder: _fieldBorder(_accent, 1.6),
                ),
              ),
            ),
          ],
        ),
      );

  OutlineInputBorder _fieldBorder(
    Color color, [
    double width = 1.2,
  ]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
  }) =>
      SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            disabledBackgroundColor: _accent.withValues(alpha: 0.6),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _busy
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: InstaLoader(
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 24),
                  ],
                ),
        ),
      );

  Widget _otpSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Enter 4\u2013Digit Code',
                  style: TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: _accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Auto-detected',
                style: TextStyle(
                  color: _accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _OtpBoxes(
            controller: _otp,
            focusNode: _otpFocus,
            hasError: _error != null,
            onChanged: () {
              if (_error != null) setState(() => _error = null);
            },
            onCompleted: _verify,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 20, color: _muted),
              const SizedBox(width: 8),
              Text(
                _resendIn > 0 ? 'Resend in ' : 'You can resend now',
                style: TextStyle(color: _muted, fontSize: 15),
              ),
              if (_resendIn > 0)
                Text(
                  '00:${_resendIn.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: _resendIn > 0 || _busy ? null : _getOtp,
                child: Text(
                  'Resend SMS',
                  style: TextStyle(
                    color: _resendIn > 0
                        ? _accent.withValues(alpha: 0.5)
                        : _accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: _field,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.sms_outlined, color: _accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo verification ($_maskedPhone)\n'
                    'Demo OTP: ${AuthController.testOtp}',
                    style: TextStyle(
                      color: _text,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _staffBanner() => Material(
        color: _tint,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _switchMode,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _text,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _staff ? Icons.person_outline : Icons.storefront_outlined,
                    color: _muted,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _staff ? 'Are you a resident?' : 'PG Owner or Manager?',
                        style: TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _staff
                            ? 'Switch back to resident login'
                            : 'Tap to log in and manage your PG',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _muted),
              ],
            ),
          ),
        ),
      );

  Widget _featureTiles() => const Row(
        children: [
          Expanded(
            child: _FeatureTile(
              Icons.bolt_outlined,
              'Instant Room\nAccess',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _FeatureTile(
              Icons.verified_user_outlined,
              'Zero Brokerage',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _FeatureTile(
              Icons.credit_card_rounded,
              'Auto Rent Pay',
            ),
          ),
        ],
      );

  Widget _terms() {
    final base = TextStyle(
      color: _muted,
      fontSize: 15,
      height: 1.5,
    );

    final link = TextStyle(
      color: _text,
      fontSize: 15,
      height: 1.5,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By continuing, you agree to PG App '),
          TextSpan(text: 'Terms of Service', style: link),
          const TextSpan(text: ' & '),
          TextSpan(text: 'Privacy Policy', style: link),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCompleted,
    required this.hasError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final text = controller.text;
        final scheme = Theme.of(context).colorScheme;

        return SizedBox(
          height: 72,
          child: Stack(
            children: [
              Row(
                children: List.generate(4, (index) {
                  final filled = index < text.length;
                  final active = focusNode.hasFocus &&
                      index == (text.length < 4 ? text.length : 3);

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 14,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              active ? scheme.outlineVariant : scheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasError
                                ? scheme.error
                                : active
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                            width: active ? 2.2 : 1.4,
                          ),
                        ),
                        child: Text(
                          filled ? text[index] : '',
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    enableInteractiveSelection: false,
                    showCursor: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      onChanged();
                      if (value.length == 4) onCompleted();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
