import 'package:flutter/material.dart';

import '../core/theme/app_radii.dart';

/// Card base do design system: cantos arredondados generosos e padding amplo,
/// usado em toda a UI para manter baixa densidade visual.
class CuidarCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CuidarCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppRadii.spaceMd),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: card,
    );
  }
}
