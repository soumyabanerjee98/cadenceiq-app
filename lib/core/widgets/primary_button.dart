import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';

class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.shine = false,
    this.paddingDisable = false,
    this.danger = false,
    this.ai = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final bool shine;
  final bool paddingDisable;
  final bool danger;
  final bool ai;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    if (widget.ai) {
      _lottieController = AnimationController(vsync: this);
    }

    if (widget.shine) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shine && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.shine && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: widget.ai
                ? Transform.scale(
                    scale: 2.0,
                    child: Lottie.asset(
                      AppLotties.aiLoading,
                      controller: _lottieController,
                      onLoaded: (composition) {
                        _lottieController
                          ..duration = composition.duration
                          ..repeat();
                      },
                    ),
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 8),
              ] else if (widget.ai) ...[
                Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(color: AppColors.surface),
              ),
            ],
          );

    final themeStyle = Theme.of(context).elevatedButtonTheme.style;

    Widget button = ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: themeStyle?.copyWith(
        backgroundColor: widget.danger
            ? WidgetStatePropertyAll(AppColors.error)
            : widget.ai
            ? WidgetStatePropertyAll(AppColors.ai)
            : null,
      ),
      child: child,
    );

    if (widget.shine) {
      button = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return ShaderMask(
              shaderCallback: (rect) {
                final width = rect.width;

                final dx = Tween<double>(
                  begin: -width,
                  end: width * 2,
                ).transform(_controller.value);

                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Colors.transparent,
                    Colors.white10,
                    Colors.white12,
                    Colors.white24,
                    Colors.white30,
                    Colors.white24,
                    Colors.white12,
                    Colors.white10,
                    Colors.transparent,
                  ],
                  stops: const [
                    0.00,
                    0.18,
                    0.34,
                    0.46,
                    0.50,
                    0.54,
                    0.66,
                    0.82,
                    1.00,
                  ],
                  transform: GradientTranslation(dx),
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: child,
            );
          },
          child: button,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.paddingDisable == true ? 0 : 16,
      ),
      child: widget.expand == true
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.paddingDisable = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool paddingDisable;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingDisable == true ? 0 : 16),
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, height: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
