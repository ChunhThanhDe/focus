import 'package:flutter/material.dart';

class LegendPane extends StatelessWidget {
  final Color color;
  const LegendPane({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legend', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500, height: 1.4, letterSpacing: 0.2)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.red.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Red: due in < 10 minutes', style: TextStyle(color: color.withOpacity(0.9), height: 1.4, letterSpacing: 0.2))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Yellow: due in < 60 minutes', style: TextStyle(color: color.withOpacity(0.9), height: 1.4, letterSpacing: 0.2))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Green: completed', style: TextStyle(color: color.withOpacity(0.9), height: 1.4, letterSpacing: 0.2))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.keyboard_alt_rounded, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 8),
              Expanded(child: Text('Ctrl+S: save notes', style: TextStyle(color: color.withOpacity(0.9), height: 1.4, letterSpacing: 0.2))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 8),
              Expanded(child: Text('Notification pushes when time comes', style: TextStyle(color: color.withOpacity(0.9), height: 1.4, letterSpacing: 0.2))),
            ],
          ),
        ],
      ),
    );
  }
}