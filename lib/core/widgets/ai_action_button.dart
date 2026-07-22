import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:cadenceiq_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AiActionButton extends StatefulWidget {
  const AiActionButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.label = "Generate Insight",
    this.icon = Icons.auto_awesome,
    this.color = AppColors.ai,
  });

  final bool loading;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;

  @override
  State<AiActionButton> createState() => _AiActionButtonState();
}

class _AiActionButtonState extends State<AiActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return Padding(
        padding: const EdgeInsets.all(11),
        child: SizedBox(
          height: 22,
          width: 22,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
            child: Transform.scale(
              scale: 2,
              child: Lottie.asset(
                AppLotties.aiLoading,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..repeat();
                },
              ),
            ),
          ),
        ),
      );
    }

    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: widget.color),
      onPressed: widget.onPressed,
      icon: Icon(widget.icon),
      label: Text(widget.label),
    );
  }
}
