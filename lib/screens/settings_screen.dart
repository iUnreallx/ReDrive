import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showSettingsSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  showCupertinoSheet(
  context: context,
  enableDrag: true,
  builder: (context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= 0.41) {
          Navigator.pop(context);
          return true;
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.50,
        minChildSize: 0.40,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SettingsSheet(
            scrollController: scrollController,
          );
        },
      ),
    );
  },
);
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.onSurface.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // ── Tiles ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 40),
                    child: Column(
                      children: [
                        _SettingsTile(
                      icon: Icons.settings_outlined,
                      label: 'Place Holder..',
                      colorScheme: colorScheme,
                    ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.85),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
