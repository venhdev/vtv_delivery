import 'package:flutter/material.dart';

class MenuActionItem extends StatelessWidget {
  const MenuActionItem({super.key, required this.label, required this.icon, this.color, this.onPressed});

  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.all(8),
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            Text(label),
          ],
        ),
      ),
    );
  }
}
