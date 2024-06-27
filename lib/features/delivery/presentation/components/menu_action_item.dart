import 'package:flutter/material.dart';

class MenuActionItem extends StatelessWidget {
  const MenuActionItem({
    super.key,
    required this.label,
    required this.icon,
    this.color,
    this.onPressed,
    this.size = 130,
    this.labelTextStyle,
  });

  final String label;
  final TextStyle? labelTextStyle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            padding: const EdgeInsets.all(8),
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: size / 1.5, color: Colors.white),
          ),
        ),

        //# Label
        Text(label, style: labelTextStyle ?? const TextStyle(fontSize: 16)),
      ],
    );
  }
}
