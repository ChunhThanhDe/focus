import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/extension_settings.dart';
import '../models/quote.dart';
import '../models/site_config.dart';
import '../stores/extension_store.dart';
import '../../resources/colors.dart';
import '../../utils/custom_observer.dart';

class ExtensionSettingsView extends StatelessWidget {
  const ExtensionSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomObserver(
      name: 'ExtensionSettingsView',
      builder: (context) {
        final extensionStore = context.read<ExtensionStore>();
        
        if (!extensionStore.initialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, extensionStore),
              const SizedBox(height: 24),
              _buildMainToggle(context, extensionStore),
              const SizedBox(height: 24),
              _buildSiteSettings(context, extensionStore),
              const SizedBox(height: 24),
              _buildQuoteSettings(context, extensionStore),
              const SizedBox(height: 24),
              _buildDisplaySettings(context, extensionStore),
              const SizedBox(height: 24),
              _buildCustomQuotes(context, extensionStore),
              const SizedBox(height: 24),
              _buildStats(context, extensionStore),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(BuildContext context, ExtensionStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.extension,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Chrome Extension',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Configure your social media focus extension',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (store.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    store.error!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: store.clearError,
                  icon: Icon(Icons.close, color: Colors.red, size: 18),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildMainToggle(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extension Enabled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable or disable the extension across all sites',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: store.isExtensionEnabled,
                onChanged: store.loading ? null : (_) => store.toggleExtension(),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSiteSettings(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enabled Sites',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which social media sites to apply the extension to',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SiteId.values.map((siteId) {
                  final isEnabled = store.isSiteEnabled(siteId);
                  final stats = store.getStatsForSite(siteId);
                  
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(siteId.displayName),
                        if (stats != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${stats.quotesShown}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isEnabled,
                    onSelected: store.loading ? null : (_) => store.toggleSite(siteId),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuoteSettings(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quote Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Quote Source
              Text(
                'Quote Source',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: QuoteSource.values.map((source) {
                  final isSelected = store.settings?.quoteSource == source;
                  return ChoiceChip(
                    label: Text(source.displayName),
                    selected: isSelected,
                    onSelected: store.loading ? null : (selected) {
                      if (selected) store.updateQuoteSource(source);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Quote Categories
              Text(
                'Quote Categories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QuoteCategory.values.map((category) {
                  final isSelected = store.settings?.selectedCategories.contains(category) ?? false;
                  return FilterChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: store.loading ? null : (selected) {
                      final currentCategories = List<QuoteCategory>.from(
                        store.settings?.selectedCategories ?? [],
                      );
                      
                      if (selected) {
                        currentCategories.add(category);
                      } else {
                        currentCategories.remove(category);
                      }
                      
                      store.updateQuoteCategories(currentCategories);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Rotation Settings
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Rotation',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Automatically change quotes every ${store.settings?.quoteRotation.intervalMinutes ?? 30} minutes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: store.settings?.quoteRotation.enabled ?? true,
                    onChanged: store.loading ? null : (enabled) {
                      final currentRotation = store.settings?.quoteRotation ?? const QuoteRotationSettings();
                      final newRotation = currentRotation.copyWith(enabled: enabled);
                      store.updateQuoteRotation(newRotation);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDisplaySettings(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Block Method
              Text(
                'Feed Blocking Method',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: BlockMethod.values.map((method) {
                  final isSelected = store.settings?.feedBlocking.blockMethod == method;
                  return RadioListTile<BlockMethod>(
                    title: Text(method.displayName),
                    subtitle: Text(
                      method.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: method,
                    groupValue: store.settings?.feedBlocking.blockMethod,
                    onChanged: store.loading ? null : (selectedMethod) {
                      if (selectedMethod != null) {
                        final currentBlocking = store.settings?.feedBlocking ?? const FeedBlockingSettings();
                        final newBlocking = currentBlocking.copyWith(blockMethod: selectedMethod);
                        store.updateFeedBlocking(newBlocking);
                      }
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomQuotes(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Custom Quotes (${store.customQuotes.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: store.loading ? null : () => _showAddQuoteDialog(context, store),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (store.customQuotes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No custom quotes yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your own inspirational quotes to personalize your experience',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: store.customQuotes.map((quote) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${quote.text}"',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '— ${quote.author}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: store.loading ? null : () => store.deleteCustomQuote(quote.id),
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStats(BuildContext context, ExtensionStore store) {
    return Observer(
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Usage Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: store.loading ? null : store.refresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Quotes Shown',
                      store.totalQuotesShown.toString(),
                      Icons.format_quote,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Feeds Blocked',
                      store.totalFeedsBlocked.toString(),
                      Icons.block,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Time Active',
                      store.getFormattedTimeActive(),
                      Icons.timer,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddQuoteDialog(BuildContext context, ExtensionStore store) {
    final textController = TextEditingController();
    final authorController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Quote Text',
                hintText: 'Enter your inspirational quote...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                hintText: 'Enter the author name...',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              final author = authorController.text.trim();
              
              if (text.isNotEmpty && author.isNotEmpty) {
                Navigator.of(context).pop();
                await store.addCustomQuote(text, author);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Quote'),
          ),
        ],
      ),
    );
  }
}