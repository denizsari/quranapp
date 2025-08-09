import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/typography.dart';

class AppButton extends StatelessWidget {
  const AppButton.primary(this.label, {super.key, this.onPressed}) : variant = _ButtonVariant.primary;
  const AppButton.ghost(this.label, {super.key, this.onPressed}) : variant = _ButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final _ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppSemanticColors>()!;
    final baseStyle = AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white);
    Color bg;
    Color border;
    Color fg;
    switch (variant) {
      case _ButtonVariant.primary:
        bg = theme.primary;
        border = theme.primary;
        fg = Colors.white;
        break;
      case _ButtonVariant.ghost:
        bg = Colors.transparent;
        border = theme.primary.withOpacity(.4);
        fg = theme.primary;
        break;
    }
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(label, style: baseStyle.copyWith(color: fg)),
      ),
    );
  }
}

enum _ButtonVariant { primary, ghost }

class AppCard extends StatelessWidget {
  const AppCard({super.key, this.child, this.onTap});
  final Widget? child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppSemanticColors>()!;
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withOpacity(.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value});
  final double value; // 0-1
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppSemanticColors>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(children: [
            Container(height: 10, width: double.infinity, color: Colors.black.withOpacity(.05)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 10,
              width: constraints.maxWidth * value.clamp(0, 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary, colors.success]),
              ),
            )
          ]);
        },
      ),
    );
  }
}

class Badge extends StatelessWidget {
  const Badge({super.key, required this.label, this.color});
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? colors.primary).withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color ?? colors.primary, fontWeight: FontWeight.w600)),
    );
  }
}
