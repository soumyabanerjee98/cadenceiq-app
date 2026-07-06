import 'package:cadenceiq_app/core/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CadenceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CadenceAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    this.centerTitle = false,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      centerTitle: centerTitle,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : leading,
      actions: actions,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
    );
  }
}

class CadenceLogo extends StatelessWidget {
  const CadenceLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(AppImages.logoIcon, height: size * 0.55),
    );
  }
}
