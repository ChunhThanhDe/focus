/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/gesture_detector_with_cursor.dart';
import '../main.dart';
import '../resources/fonts.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Center(child: FocusLogo(size: 160, animate: false)),
        const SizedBox(height: 15),
        Text(
          'Focus To Your Target'.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'v${packageInfo.version}'.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Made with love',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                letterSpacing: 0.25,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.favorite,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'in',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                letterSpacing: 0.25,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetectorWithCursor(
          onTap: () => launchUrl(Uri.parse('https://flutter.dev')),
          child: Container(
            padding: const EdgeInsets.only(right: 4),
            height: 28,
            child: const FlutterLogo(
              style: FlutterLogoStyle.horizontal,
              size: 84,
              textColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Developed by',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            letterSpacing: 0.2,
            color: Theme.of(context).colorScheme.primary,
            // color: Colors.white.withValues(alpha:0.5),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'ChunhThanhDe'.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1,
              fontSize: 18,
              fontFamily: FontFamilies.systemUI,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetectorWithCursor(
              onTap: () => launchUrl(Uri.parse('https://www.youtube.com/@CHUNGCINE?sub_confirmation=1')),
              child: SizedBox.square(
                dimension: 34,
                child: Image.asset('assets/images/ic_youtube.png'),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetectorWithCursor(
              onTap: () => launchUrl(Uri.parse('https://github.com/ChunhThanhDe')),
              child: SizedBox.square(
                dimension: 32,
                child: Image.asset(
                  'assets/images/ic_github.png',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            GestureDetectorWithCursor(
              onTap: () => launchUrl(Uri.parse('https://chunhthanhde.github.io')),
              child: SizedBox.square(
                dimension: 32,
                child: Image.asset('assets/images/ic_website.png'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          'Backgrounds by',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            letterSpacing: 0.25,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetectorWithCursor(
          onTap: () => launchUrl(Uri.parse('https://unsplash.com')),
          child: Image.asset(
            'assets/images/ic_unsplash.png',
            height: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Weather & Geocoding API by',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            letterSpacing: 0.25,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetectorWithCursor(
          onTap: () => launchUrl(Uri.parse('https://open-meteo.com')),
          child: Image.asset(
            'assets/images/ic_open_meteo.png',
            height: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class FocusLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const FocusLogo({super.key, this.size = 120, this.animate = true});

  @override
  State<FocusLogo> createState() => _FocusLogoState();
}

class _FocusLogoState extends State<FocusLogo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Center(
        child: SizedBox.square(
          // Constrain the logo to 80% of the outer square to create
          // balanced padding around it while keeping the image centered.
          // This avoids edge-to-edge rendering and maintains visual harmony.
          dimension: widget.size * 0.8,
          child: Image.asset(
            'assets/images/ic_focus.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
