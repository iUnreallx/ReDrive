import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redrive/screens/settings_screen.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LogoSection(colorScheme: colorScheme),
        _SettingsButton(colorScheme: colorScheme),
      ],
    );
  }
}

class _LogoSection extends StatelessWidget {
  final ColorScheme colorScheme;
  const _LogoSection({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          textScaler: TextScaler.noScaling,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: 'Re',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              TextSpan(
                text: 'Drive',
                style: TextStyle(color: colorScheme.primary),
              ),
            ],
          ),
        ),
        Text(
          'DRIVE SMARTER',
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 5.1,
          ),
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final ColorScheme colorScheme;
  const _SettingsButton({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withAlpha(80),
            colorScheme.surfaceContainer,
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainer,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showSettingsSheet(context),
            borderRadius: BorderRadius.circular(100),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/svg/dashboard/settings.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
