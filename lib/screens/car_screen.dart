import 'package:flutter/material.dart';
import 'package:redrive/l10n/app_localizations.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});
  @override State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [_GarageHeader(), Expanded(child: Center(child: _EmptyGarageCard()))])));
}

class _GarageHeader extends StatelessWidget {
  const _GarageHeader();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.only(top: 3, left: 20, right: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.garageTitle, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: c.onSurface)),
      Text(l.garageDescription, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.onSurface.withAlpha(180))),
    ]));
  }
}

class _EmptyGarageCard extends StatelessWidget {
  const _EmptyGarageCard();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30), child: Container(
      constraints: const BoxConstraints(maxWidth: 350), width: double.infinity, height: 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), color: c.surfaceContainer, border: Border.all(width: 2, color: c.primary)),
      child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(36), child: Material(color: Colors.transparent, child: InkWell(onTap: () {}, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(l.noVehicles, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: c.onSurface)),
        const SizedBox(height: 16), Text(l.addFirstVehicle, textAlign: TextAlign.center, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.onSurface.withAlpha(180))),
        const SizedBox(height: 30), Container(width: 250, height: 60, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: c.primary), child: Text(l.addVehicle, textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.onSurface))),
      ]))))));
  }
}
