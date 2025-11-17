/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:09:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';

import '../ui/custom_switch.dart';
import '../ui/text_input.dart';
import '../ui/gesture_detector_with_cursor.dart';
import '../resources/colors.dart';
import '../utils/custom_observer.dart';
import '../utils/social_cleaner_store.dart';

class SocialCleanerSettings extends StatefulWidget {
  const SocialCleanerSettings({super.key});

  @override
  State<SocialCleanerSettings> createState() => _SocialCleanerSettingsState();
}

class _SocialCleanerSettingsState extends State<SocialCleanerSettings> {
  final SocialCleanerStore store = SocialCleanerStore();
  final TextEditingController _customQuoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.loadSettings();
  }

  @override
  void dispose() {
    _customQuoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomObserver(
      name: 'SocialCleanerSettings',
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main toggle
            _buildSection(
              title: 'Social Feed Cleaner',
              child: CustomSwitch(
                value: store.enabled,
                onChanged: (value) => store.updateEnabled(value),
                label: 'Enable social feed cleaning',
              ),
            ),

            if (store.enabled) ...[
              const SizedBox(height: 24),

              // Quote settings
              _buildSection(
                title: 'Quote Settings',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSwitch(
                      value: store.showQuotes,
                      onChanged: (value) => store.updateShowQuotes(value),
                      label: 'Show inspirational quotes',
                    ),

                    if (store.showQuotes) ...[
                      const SizedBox(height: 16),
                      CustomSwitch(
                        value: store.builtinQuotesEnabled,
                        onChanged: (value) => store.updateBuiltinQuotesEnabled(value),
                        label: 'Use built-in quotes',
                      ),

                      const SizedBox(height: 16),
                      _buildCustomQuotesSection(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Site-specific settings
              _buildSection(
                title: 'Site Settings',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSiteToggle('Facebook', 'facebook'),
                    _buildSiteToggle('Instagram', 'instagram'),
                    _buildSiteToggle('TikTok', 'tiktok'),
                    _buildSiteToggle('Twitter/X', 'twitter'),
                    _buildSiteToggle('Reddit', 'reddit'),
                    _buildSiteToggle('LinkedIn', 'linkedin'),
                    _buildSiteToggle('YouTube', 'youtube'),
                    _buildSiteToggle('GitHub', 'github'),
                    _buildSiteToggle('Shopee', 'shopee'),
                    _buildSiteToggle('Hacker News', 'hackernews'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reset button
              _buildSection(
                title: 'Reset',
                child: GestureDetectorWithCursor(
                  onTap: () => _showResetDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Reset to defaults',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSiteToggle(String siteName, String siteId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomSwitch(
        value: store.isSiteEnabled(siteId),
        onChanged: (value) => store.updateSiteEnabled(siteId, value),
        label: siteName,
      ),
    );
  }

  Widget _buildCustomQuotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Quotes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),

        // Add quote input
        Row(
          children: [
            Expanded(
              child: TextInput(
                controller: _customQuoteController,
                hintText: 'Enter your custom quote...',
                onSubmitted: (value) async {
                  _addCustomQuote();
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetectorWithCursor(
              onTap: () => _addCustomQuote(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Custom quotes list
        if (store.customQuotes.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: store.customQuotes.length,
              itemBuilder: (context, index) {
                final quote = store.customQuotes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          quote,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetectorWithCursor(
                        onTap: () => store.removeCustomQuote(index),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          Text(
            'No custom quotes added yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _addCustomQuote() {
    final quote = _customQuoteController.text.trim();
    if (quote.isNotEmpty) {
      store.addCustomQuote(quote);
      _customQuoteController.clear();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all social cleaner settings to their default values? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  store.resetSettings();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
