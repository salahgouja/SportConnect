import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Animated 2D Character Widget for Onboarding
/// Custom vector-style animated characters without gradients
class AnimatedCharacter extends StatefulWidget {
  final CharacterType type;
  final CharacterMood mood;
  final double size;
  final bool isAnimating;

  const AnimatedCharacter({
    super.key,
    required this.type,
    this.mood = CharacterMood.happy,
    this.size = 200,
    this.isAnimating = true,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

enum CharacterType { driver, passenger, eco, achiever }

enum CharacterMood { happy, excited, proud, inspired }

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with TickerProviderStateMixin {
  late AnimationController _bodyController;
  late AnimationController _armController;
  late AnimationController _faceController;
  late AnimationController _floatController;

  late Animation<double> _bodyBounce;
  late Animation<double> _armWave;
  late Animation<double> _eyeBlink;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Body bounce animation
    _bodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bodyBounce = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bodyController, curve: Curves.easeInOut),
    );

    // Arm wave animation
    _armController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _armWave = Tween<double>(
      begin: -0.15,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _armController, curve: Curves.easeInOut));

    // Eye blink animation
    _faceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _eyeBlink = Tween<double>(begin: 1, end: 0.1).animate(
      CurvedAnimation(parent: _faceController, curve: Curves.easeInOut),
    );

    // Float animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    if (widget.isAnimating) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _bodyController.repeat(reverse: true);
    _armController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _scheduleEyeBlink();
  }

  void _scheduleEyeBlink() {
    Future.delayed(
      Duration(milliseconds: 2000 + math.Random().nextInt(2000)),
      () {
        if (mounted && widget.isAnimating) {
          _faceController.forward().then((_) {
            _faceController.reverse().then((_) {
              _scheduleEyeBlink();
            });
          });
        }
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimations();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _bodyController.stop();
      _armController.stop();
      _floatController.stop();
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _armController.dispose();
    _faceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bodyController,
        _armController,
        _faceController,
        _floatController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: _buildCharacter(),
        );
      },
    );
  }

  Widget _buildCharacter() {
    switch (widget.type) {
      case CharacterType.driver:
        return _buildDriverCharacter();
      case CharacterType.passenger:
        return _buildPassengerCharacter();
      case CharacterType.eco:
        return _buildEcoCharacter();
      case CharacterType.achiever:
        return _buildAchieverCharacter();
    }
  }

  Widget _buildDriverCharacter() {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Car body
          Positioned(
            bottom: size * 0.15,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value * 0.3),
              child: _buildCar(size * 0.9),
            ),
          ),

          // Character in car
          Positioned(
            bottom: size * 0.35,
            left: size * 0.35,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value),
              child: _buildCharacterHead(size * 0.28),
            ),
          ),

          // Waving arm
          Positioned(
            bottom: size * 0.42,
            left: size * 0.55,
            child: Transform.rotate(
              angle: _armWave.value,
              alignment: Alignment.bottomCenter,
              child: _buildWavingArm(size * 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCharacter() {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Map/location icon behind
          Positioned(bottom: size * 0.1, child: _buildMapIcon(size * 0.5)),

          // Main character
          Positioned(
            bottom: size * 0.25,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value),
              child: _buildFullCharacter(size * 0.6),
            ),
          ),

          // Phone in hand
          Positioned(
            bottom: size * 0.35,
            right: size * 0.2,
            child: Transform.rotate(
              angle: _armWave.value * 0.3,
              child: _buildPhone(size * 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoCharacter() {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Globe/Earth
          Positioned(
            bottom: size * 0.15,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value * 0.5),
              child: _buildGlobe(size * 0.45),
            ),
          ),

          // Character hugging globe
          Positioned(
            bottom: size * 0.25,
            left: size * 0.15,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value),
              child: _buildFullCharacter(size * 0.5),
            ),
          ),

          // Floating leaves
          Positioned(
            top: size * 0.1,
            right: size * 0.2,
            child: Transform.translate(
              offset: Offset(0, _float.value * 0.5),
              child: _buildLeaf(size * 0.08),
            ),
          ),
          Positioned(
            top: size * 0.2,
            left: size * 0.15,
            child: Transform.translate(
              offset: Offset(0, -_float.value * 0.3),
              child: _buildLeaf(size * 0.06),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchieverCharacter() {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trophy/podium
          Positioned(bottom: size * 0.1, child: _buildTrophy(size * 0.35)),

          // Character celebrating
          Positioned(
            bottom: size * 0.3,
            child: Transform.translate(
              offset: Offset(0, _bodyBounce.value),
              child: _buildCelebratingCharacter(size * 0.55),
            ),
          ),

          // Stars
          Positioned(
            top: size * 0.08,
            right: size * 0.15,
            child: Transform.rotate(
              angle: _float.value * 0.02,
              child: _buildStar(size * 0.1),
            ),
          ),
          Positioned(
            top: size * 0.15,
            left: size * 0.2,
            child: Transform.rotate(
              angle: -_float.value * 0.02,
              child: _buildStar(size * 0.07),
            ),
          ),
        ],
      ),
    );
  }

  // Component builders
  Widget _buildCar(double width) {
    return SizedBox(
      width: width,
      height: width * 0.4,
      child: CustomPaint(
        painter: _CarPainter(color: AppColors.primary),
        size: Size(width, width * 0.4),
      ),
    );
  }

  Widget _buildCharacterHead(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDBB4), // Skin tone
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0B89A), width: 2),
      ),
      child: Stack(
        children: [
          // Eyes
          Positioned(
            left: size * 0.22,
            top: size * 0.35,
            child: Container(
              width: size * 0.12,
              height: size * 0.12 * _eyeBlink.value,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(size * 0.06),
              ),
            ),
          ),
          Positioned(
            right: size * 0.22,
            top: size * 0.35,
            child: Container(
              width: size * 0.12,
              height: size * 0.12 * _eyeBlink.value,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(size * 0.06),
              ),
            ),
          ),
          // Smile
          Positioned(
            bottom: size * 0.22,
            left: size * 0.3,
            right: size * 0.3,
            child: Container(
              height: size * 0.08,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: const Color(0xFF333333), width: 2),
                ),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Hair
          Positioned(
            top: 0,
            left: size * 0.1,
            right: size * 0.1,
            child: Container(
              height: size * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3C31),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.3),
                  topRight: Radius.circular(size * 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWavingArm(double size) {
    return Container(
      width: size * 0.4,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Column(
        children: [
          // Hand
          Container(
            width: size * 0.5,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBB4),
              borderRadius: BorderRadius.circular(size * 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCharacter(double size) {
    return SizedBox(
      width: size,
      height: size * 1.5,
      child: Column(
        children: [
          // Head
          _buildCharacterHead(size * 0.5),
          SizedBox(height: size * 0.05),
          // Body
          Container(
            width: size * 0.6,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(size * 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebratingCharacter(double size) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Head
          Positioned(top: size * 0.1, child: _buildCharacterHead(size * 0.4)),
          // Raised arms
          Positioned(
            top: size * 0.3,
            left: size * 0.05,
            child: Transform.rotate(
              angle: -0.5 + _armWave.value,
              child: Container(
                width: size * 0.1,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(size * 0.05),
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.3,
            right: size * 0.05,
            child: Transform.rotate(
              angle: 0.5 - _armWave.value,
              child: Container(
                width: size * 0.1,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(size * 0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapIcon(double size) {
    return Container(
      width: size,
      height: size * 0.8,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.map_rounded,
        color: AppColors.primary.withValues(alpha: 0.5),
        size: size * 0.4,
      ),
    );
  }

  Widget _buildPhone(double size) {
    return Container(
      width: size * 0.6,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.7,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(size * 0.05),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobe(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.infoDark, width: 3),
      ),
      child: ClipOval(
        child: CustomPaint(painter: _GlobePainter(), size: Size(size, size)),
      ),
    );
  }

  Widget _buildLeaf(double size) {
    return Icon(Icons.eco_rounded, color: AppColors.success, size: size);
  }

  Widget _buildTrophy(double size) {
    return Icon(
      Icons.emoji_events_rounded,
      color: AppColors.xpGold,
      size: size,
    );
  }

  Widget _buildStar(double size) {
    return Icon(Icons.star_rounded, color: AppColors.starFilled, size: size);
  }
}

// Custom painters
class _CarPainter extends CustomPainter {
  final Color color;

  _CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Car body
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.1, size.height * 0.6);
    bodyPath.lineTo(size.width * 0.15, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.3, size.height * 0.1);
    bodyPath.lineTo(size.width * 0.7, size.height * 0.1);
    bodyPath.lineTo(size.width * 0.85, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.9, size.height * 0.6);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);

    // Windows
    final windowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final windowPath = Path();
    windowPath.moveTo(size.width * 0.32, size.height * 0.18);
    windowPath.lineTo(size.width * 0.68, size.height * 0.18);
    windowPath.lineTo(size.width * 0.78, size.height * 0.35);
    windowPath.lineTo(size.width * 0.22, size.height * 0.35);
    windowPath.close();

    canvas.drawPath(windowPath, windowPaint);

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.75),
      size.height * 0.2,
      wheelPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.75),
      size.height * 0.2,
      wheelPaint,
    );

    // Wheel centers
    final wheelCenterPaint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.75),
      size.height * 0.08,
      wheelCenterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.75),
      size.height * 0.08,
      wheelCenterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Simplified continents
    // Americas
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3, size.height * 0.4),
        width: size.width * 0.25,
        height: size.height * 0.35,
      ),
      landPaint,
    );

    // Europe/Africa
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.45),
        width: size.width * 0.2,
        height: size.height * 0.4,
      ),
      landPaint,
    );

    // Asia
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.35),
        width: size.width * 0.25,
        height: size.height * 0.3,
      ),
      landPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating icons animation widget
class FloatingIcons extends StatefulWidget {
  final List<IconData> icons;
  final Color color;
  final double size;

  const FloatingIcons({
    super.key,
    required this.icons,
    this.color = AppColors.primary,
    this.size = 24,
  });

  @override
  State<FloatingIcons> createState() => _FloatingIconsState();
}

class _FloatingIconsState extends State<FloatingIcons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.icons.asMap().entries.map((entry) {
            final index = entry.key;
            final icon = entry.value;
            final offset =
                math.sin((_controller.value * 2 * math.pi) + index) * 8;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Icon(icon, color: widget.color, size: widget.size),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
