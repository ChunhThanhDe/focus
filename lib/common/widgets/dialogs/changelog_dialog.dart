/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
* @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:focus/common/widgets/dialogs/permission_request_dialog.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:focus/main.dart';
import 'package:focus/core/constants/colors.dart';
import 'package:focus/common/widgets/input/gesture_detector_with_cursor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangelogDialog extends StatefulWidget {
  const ChangelogDialog({super.key});

  @override
  State<ChangelogDialog> createState() => _ChangelogDialogState();
}

class _ChangelogDialogState extends State<ChangelogDialog> {
  String? changelog;
  String? version;
  DateTime? date;
  String? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChangelog();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: min(620, MediaQuery.of(context).size.width * 0.9),
        height: min(500, MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.settingsPanelBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "What's new in Focus",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            barrierDismissible: true,
                            builder:
                                (ctx) => const Material(
                                  type: MaterialType.transparency,
                                  child: PermissionRequestDialog(),
                                ),
                          );
                        });
                      },
                      splashRadius: 16,
                      iconSize: 18,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Expanded(child: Center(child: CupertinoActivityIndicator(radius: 12))),
            if (error != null)
              Expanded(
                child: Center(child: Text(error!, style: Theme.of(context).textTheme.bodyLarge)),
              ),
            if (changelog != null) ...[
              Flexible(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.dropdownOverlayColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        color: Theme.of(context).colorScheme.primary,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'v$version',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('dd MMMM, yyyy').format(date!),
                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.copyWith(
                                  bodyMedium: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              child: MarkdownBody(data: changelog!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetectorWithCursor(
                  onTap:
                      () => launchUrl(
                        Uri.parse('https://github.com/ChunhThanhDe/focus/blob/main/CHANGELOG.md'),
                      ),
                  child: Hoverable(
                    builder:
                        (context, hovering, child) => Text(
                          'View All Changelogs',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            decoration: hovering ? TextDecoration.underline : null,
                          ),
                        ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'aboutDialog.support'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetectorWithCursor(
                    onTap: () => launchUrl(Uri.parse('https://discord.gg/kMrAKAZA2X')),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5865F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'aboutDialog.joinDiscord'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> fetchChangelog() async {
    isLoading = true;
    if (mounted) setState(() {});
    try {
      version = packageInfo.version;
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/ChunhThanhDe/focus/$version/CHANGELOG.md'),
      );

      final releaseResponse = await http.get(
        Uri.parse('https://api.github.com/repos/ChunhThanhDe/focus/releases/tags/$version'),
      );
      isLoading = false;
      if (response.statusCode != 200 || releaseResponse.statusCode != 200) {
        throw Exception(response.body);
      }
      changelog = response.body;
      final jsonData = json.decode(releaseResponse.body);
      date = DateTime.tryParse(jsonData['published_at']);
      changelog = jsonData['body']?.toString();
      if (mounted) setState(() {});
    } catch (err, stacktrace) {
      log(err.toString());
      log(stacktrace.toString());
      isLoading = false;
      error = 'Unable to load changelog. Please try again later.';
      if (mounted) setState(() {});
    }
  }
}
