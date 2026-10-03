import 'package:flutter/material.dart';

class ReconnectionBanner extends StatelessWidget {
  final String message;

  const ReconnectionBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shape: StadiumBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withAlpha(100),
          width: 1.5,
        ),
      ),

      color: Color.lerp(
        Theme.of(context).colorScheme.surfaceContainer,
        Colors.black,
        0.4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
