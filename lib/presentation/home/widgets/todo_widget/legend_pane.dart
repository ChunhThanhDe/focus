/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-19 20:30:51
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:focus/presentation/home/store/background_store.dart';

class LegendPane extends StatelessWidget {
  final Color color;

  const LegendPane({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    final bool isDarkTodo = store.isTodoMode && store.todoDarkMode;
    final Color borderBase = isDarkTodo ? Theme.of(context).colorScheme.primary : color;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        // borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderBase.withOpacity(0.15),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'todo.guide'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'todo.legendRed'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'todo.legendYellow'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'todo.legendGreen'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.keyboard_alt_rounded, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'todo.ctrlSaveNotes'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'todo.notifyWhenTimeComes'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
