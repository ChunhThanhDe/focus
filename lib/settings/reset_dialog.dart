/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../resources/colors.dart';

class ResetDialog extends StatelessWidget {
  final VoidCallback onReset;

  const ResetDialog({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        // height: min(500, MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        decoration: BoxDecoration(
          color: AppColors.settingsPanelBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restore_rounded, size: 72, color: Colors.grey.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'settings.dialog.reset.title'.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'settings.dialog.reset.description'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textColor.withValues(alpha: 0.7), height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.red.withValues(alpha: 0.1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'settings.dialog.reset.note'.tr(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: AppColors.borderColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: Text('common.cancel'.tr()),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onReset();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: Text('settings.dialog.reset.yesReset'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
