import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/dtc_provider.dart';

extension on ColorScheme {
  Color get muted => onSurface.withValues(alpha: .6);
  Color get edge => onSurface.withValues(alpha: .05);
  Color get track => onSurface.withValues(alpha: .1);
  Color get greyTint => onSurface.withValues(alpha: .06);
  Color get okTint => primary.withValues(alpha: .18);
  Color get badTint => AppColors.warning.withValues(alpha: .18);
}

class DtcScreen extends StatelessWidget {
  const DtcScreen({super.key, this.onOpenConnection});

  final VoidCallback? onOpenConnection;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final dtc = context.watch<DtcProvider>();

    final Widget body = switch (dtc.state) {
      DtcState.idle when !dtc.connected => _Prompt(
        icon: Icon(Icons.power_off_rounded, size: 30, color: cs.muted),
        tint: cs.greyTint,
        title: l.dtcConnectTitle,
        body: l.dtcConnectBody,
        action: onOpenConnection == null
            ? null
            : _PrimaryButton(
                icon: Icons.bluetooth_rounded,
                label: l.connect,
                onPressed: onOpenConnection,
              ),
      ),
      DtcState.idle => _Prompt(
        icon: Icon(
          Icons.health_and_safety_outlined,
          size: 30,
          color: cs.primary,
        ),
        tint: cs.okTint,
        title: l.dtcScanTitle,
        body: l.dtcScanBody,
        action: Tooltip(
          message: l.dtcScan,
          child: _PrimaryButton(
            icon: Icons.play_arrow_rounded,
            label: l.dtcScan,
            onPressed: dtc.canScan ? dtc.loadCodes : null,
          ),
        ),
      ),
      DtcState.loading || DtcState.clearing => _Progress(
        title: dtc.state == DtcState.loading ? l.dtcLoading : l.dtcClearing,
        hint: l.dtcKeepIgnition,
      ),
      DtcState.success when dtc.codes.isEmpty => _AllGood(
        checkedAt: dtc.checkedAt,
        onRescan: dtc.canScan ? dtc.loadCodes : null,
      ),
      DtcState.success => _CodesList(
        codes: dtc.codes,
        checkedAt: dtc.checkedAt,
        onRescan: dtc.canScan ? dtc.loadCodes : null,
        onClear: dtc.canClear ? () => _confirmClear(context) : null,
      ),
      DtcState.error || DtcState.clearFailed => _Prompt(
        icon: const Icon(
          Icons.error_outline_rounded,
          size: 30,
          color: AppColors.warning,
        ),
        tint: cs.badTint,
        title: switch (dtc.state) {
          DtcState.clearFailed => l.dtcClearFailed,
          _ when dtc.error is UnsupportedError => l.dtcUnsupported,
          _ => l.dtcFailure,
        },
        body: dtc.connected ? l.dtcScanBody : l.dtcConnectBody,
        action: Tooltip(
          message: l.dtcRescan,
          child: _PrimaryButton(
            icon: Icons.refresh_rounded,
            label: l.dtcRescan,
            onPressed: dtc.canScan ? dtc.loadCodes : null,
          ),
        ),
      ),
    };

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: DefaultTextStyle(
          style: TextStyle(fontFamily: 'Inter', color: cs.onSurface),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l.dtc,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                    ),
                  ),
                ),
              ),
              // Отступы внутри SliverFillRemaining: снаружи (SliverPadding)
              // они прибавлялись к высоте экрана, и пустой экран скроллился.
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    child: KeyedSubtree(
                      key: ValueKey((
                        dtc.state,
                        dtc.connected,
                        dtc.codes.isEmpty,
                      )),
                      child: Semantics(liveRegion: true, child: body),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Пустое состояние с крупной иконкой, текстом и одной кнопкой внизу.
class _Prompt extends StatelessWidget {
  const _Prompt({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    this.action,
  });

  final Widget icon;
  final Color tint;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        _Badge(tint: tint, child: icon),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.muted, fontSize: 14, height: 1.4),
        ),
        const Spacer(),
        ?action,
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: _panel(cs, 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
            child: Column(
              children: [
                SizedBox.square(
                  dimension: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: cs.primary,
                    backgroundColor: cs.track,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(hint, style: TextStyle(color: cs.muted, fontSize: 13)),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: cs.primary,
                    backgroundColor: cs.track,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AllGood extends StatelessWidget {
  const _AllGood({required this.checkedAt, required this.onRescan});

  final DateTime? checkedAt;
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: _panel(cs, 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Badge(
                  tint: cs.okTint,
                  child: Icon(Icons.check_rounded, size: 34, color: cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  l.dtcEmpty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [l.dtcAllGood, ?_checked(context, checkedAt)].join(' · '),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.muted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Tooltip(
                  message: l.dtcRescan,
                  child: _PrimaryButton(
                    icon: Icons.refresh_rounded,
                    label: l.dtcRescan,
                    onPressed: onRescan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CodesList extends StatelessWidget {
  const _CodesList({
    required this.codes,
    required this.checkedAt,
    required this.onRescan,
    required this.onClear,
  });

  final List<String> codes;
  final DateTime? checkedAt;
  final VoidCallback? onRescan;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final checked = _checked(context, checkedAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: _panel(cs, 20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.badTint,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/svg/dashboard/dtc_engine.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dtcCount(codes.length),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        checked ?? l.dtcStored,
                        style: TextStyle(color: cs.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: l.dtcRescan,
                  child: IconButton(
                    onPressed: onRescan,
                    style: IconButton.styleFrom(backgroundColor: cs.okTint),
                    color: cs.primary,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final code in codes) ...[
          _CodeCard(code: code, label: l.dtcConfirmed),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: onClear,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.warning,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          label: Text(l.dtcClear),
        ),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: _panel(cs, 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.warning),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.badTint,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.tint, required this.child});

  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      icon: Icon(icon, size: 22),
      label: Text(label),
    );
  }
}

String? _checked(BuildContext context, DateTime? at) {
  if (at == null) return null;
  final time = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(at));
  return AppLocalizations.of(context).dtcCheckedAt(time);
}

Future<void> _confirmClear(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;
  final l = AppLocalizations.of(context);
  final obd = context.read<DtcProvider>();
  final session = obd.session;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheet) {
      final currentSession = sheet.select((DtcProvider dtc) => dtc.session);
      if (!identical(currentSession, session)) {
        final route = ModalRoute.of(sheet)!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (route.isCurrent) {
            route.navigator!.pop(false);
          } else if (route.isActive) {
            route.navigator!.removeRoute(route);
          }
        });
        return const SizedBox.shrink();
      }
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.dtcClearTitle,
                style: Theme.of(sheet).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                l.dtcClearBody,
                style: TextStyle(color: cs.onSurface.withValues(alpha: .7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheet, false),
                      child: Text(l.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: cs.onPrimary,
                      ),
                      onPressed: () => Navigator.pop(sheet, true),
                      child: Text(l.dtcClear),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  if (confirmed == true && context.mounted && identical(session, obd.session)) {
    await obd.clearCodes();
  }
}

BoxDecoration _panel(ColorScheme cs, double radius) => BoxDecoration(
  color: cs.surfaceContainer,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: cs.edge),
);
