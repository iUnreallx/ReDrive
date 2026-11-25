import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/dtc_provider.dart';

const _orangeTint = Color(0xFF3A1608);
const _greenTint = Color(0xFF2B3A10);
const _muted = Color(0xFF9A9A9A);
const _edge = Color(0xFF1D1D1D);

class DtcScreen extends StatelessWidget {
  const DtcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dtc = context.watch<DtcProvider>();
    final success = dtc.state == DtcState.success;
    final loading = dtc.isBusy;
    final count = success ? dtc.codes.length : null;
    final status = switch (dtc.state) {
      DtcState.idle => dtc.connected ? l.dtcIdle : l.notConnected,
      DtcState.loading => l.dtcLoading,
      DtcState.clearing => l.dtcClearing,
      DtcState.clearFailed => l.dtcClearFailed,
      DtcState.success => dtc.codes.isEmpty ? l.dtcEmpty : l.dtcStored,
      DtcState.error =>
        dtc.error is UnsupportedError ? l.dtcUnsupported : l.dtcFailure,
    };

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              Text(
                l.dtc,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 16),
              Tooltip(
                message: !dtc.connected
                    ? l.notConnected
                    : dtc.state == DtcState.idle
                    ? l.dtcScan
                    : l.dtcRescan,
                child: Material(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: dtc.canScan ? dtc.loadCodes : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: loading ? _greenTint : _orangeTint,
                              shape: BoxShape.circle,
                            ),
                            child: loading
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.accent,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/svg/dashboard/dtc_engine.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (count != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${l.dtcConfirmed} · $count',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (dtc.canScan)
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: _greenTint,
                              child: Icon(
                                Icons.refresh,
                                size: 20,
                                color: AppColors.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Category(
                      label: l.dtcConfirmed,
                      count: count,
                      selected: true,
                    ),
                    _Category(label: l.dtcPending),
                    _Category(label: l.dtcPermanent),
                  ],
                ),
              ),
              if (success && dtc.codes.isNotEmpty) ...[
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: _panel(28),
                  child: Column(
                    children: [
                      for (final (index, code) in dtc.codes.indexed) ...[
                        if (index > 0)
                          const Divider(height: 1, color: Color(0xFF222222)),
                        _CodeRow(code: code, label: l.dtcConfirmed),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: dtc.canClear ? () => _confirmClear(context) : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  foregroundColor: AppColors.warning,
                  disabledForegroundColor: AppColors.warning.withValues(
                    alpha: .45,
                  ),
                  side: BorderSide(
                    color: AppColors.warning.withValues(
                      alpha: dtc.canClear ? 1 : .45,
                    ),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 22),
                label: Text(l.dtcClear.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmClear(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final obd = context.read<DtcProvider>();
  final session = obd.session;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.cardBg,
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
                style: const TextStyle(color: Colors.white70),
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
                        foregroundColor: Colors.black,
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

BoxDecoration _panel(double radius) => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: _edge),
);

class _Category extends StatelessWidget {
  const _Category({required this.label, this.count, this.selected = false});

  final String label;
  final int? count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            count == null ? label : '$label $count',
            style: TextStyle(
              color: selected ? Colors.black : _muted,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _orangeTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFF7A4D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
