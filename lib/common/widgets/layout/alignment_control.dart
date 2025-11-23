/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
* @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';

import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/core/utils/enum_extensions.dart';
import 'package:focus/common/widgets/button/custom_dropdown.dart';

/// A widget that allows the user to control and select an alignment value.
///
/// Displays an optional label and a dropdown menu to pick from available alignments.
/// (Can be extended to show a visual alignment selector.)
///
/// Note: Show choose value integrate dropdown menu in setting
class AlignmentControl extends StatelessWidget {
  final String? label;
  final AlignmentC alignment;
  final ValueChanged<AlignmentC> onChanged;

  const AlignmentControl({
    super.key,
    this.label,
    required this.alignment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Show label above the control if provided
        if (label != null) ...[Text(label!), const SizedBox(height: 10)],
        Row(
          children: [
            // AlignmentUI(
            //   size: 100,
            //   alignment: alignment,
            //   onChanged: onChanged,
            // ),
            // const SizedBox(width: 16),

            // Dropdown menu for selecting alignment value
            Expanded(
              child: CustomDropdown<AlignmentC>(
                key: ValueKey(alignment),
                // label: 'Alignment',
                value: alignment,
                isExpanded: true,
                items: AlignmentC.values,
                itemBuilder: (context, alignment) => Text(alignment.label),
                onSelected: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// [Currently not in use]
///
/// A widget for visually displaying the alignment box.
///
/// Currently shows a bordered square with a smaller center box,
/// can be extended for interactive alignment selection.
class AlignmentUI extends StatefulWidget {
  final double size;
  final AlignmentC alignment;
  final ValueChanged<AlignmentC> onChanged;

  const AlignmentUI({
    super.key,
    required this.alignment,
    required this.onChanged,
    required this.size,
  });

  @override
  State<AlignmentUI> createState() => _AlignmentUIState();
}

class _AlignmentUIState extends State<AlignmentUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey.shade100,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerBoxSize = constraints.maxWidth / 3;
          return Center(
            child: Container(
              width: centerBoxSize,
              height: centerBoxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
