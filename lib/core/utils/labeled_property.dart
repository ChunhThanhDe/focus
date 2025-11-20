/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';

class Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  final double spacing;

  const Labeled({
    super.key,
    required this.label,
    required this.child,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label), SizedBox(height: spacing), child],
    );
  }
}
