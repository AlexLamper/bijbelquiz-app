import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../data/admin_models.dart';
import 'widgets/admin_ui.dart';

/// Sends a grant: [email] is only set when the sheet asked for one.
typedef AdminGrantSubmit =
    Future<AdminGrantResult> Function(AdminGrantRequest request, String? email);

/// "Premium geven": choose a duration (or an end date), add a note, confirm.
///
/// Returns the server's result on success, null when cancelled. Errors are
/// shown inside the sheet so the admin can correct and retry.
Future<AdminGrantResult?> showAdminGrantSheet(
  BuildContext context, {
  required AdminGrantSubmit submit,
  String? userName,
  bool askEmail = false,
  AdminManualGrant? currentGrant,
  DateTime? now,
}) {
  return showModalBottomSheet<AdminGrantResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.paper,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AdminGrantSheet(
      submit: submit,
      userName: userName,
      askEmail: askEmail,
      currentGrant: currentGrant,
      now: now,
    ),
  );
}

/// The confirmation line for a finished grant, for a success notice.
String adminGrantSuccessText(AdminGrantResult result, {String? userName}) {
  final who = userName ?? result.user?.displayName ?? 'Het account';
  final until = result.grant?.until ?? result.premium.until;
  if (result.grant?.duration == 'lifetime' || until == null) {
    return '$who heeft nu Premium zonder einddatum.';
  }
  return '$who heeft Premium tot en met ${AdminFormat.date(until)}.';
}

class AdminGrantSheet extends StatefulWidget {
  const AdminGrantSheet({
    super.key,
    required this.submit,
    this.userName,
    this.askEmail = false,
    this.currentGrant,
    this.now,
  });

  final AdminGrantSubmit submit;
  final String? userName;
  final bool askEmail;
  final AdminManualGrant? currentGrant;

  /// Fixed clock for tests.
  final DateTime? now;

  @override
  State<AdminGrantSheet> createState() => _AdminGrantSheetState();
}

class _AdminGrantSheetState extends State<AdminGrantSheet> {
  AdminGrantDuration _duration = AdminGrantDuration.month1;
  DateTime? _customDate;
  final _note = TextEditingController();
  final _email = TextEditingController();
  bool _confirming = false;
  bool _busy = false;
  String? _error;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void dispose() {
    _note.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _emailValid {
    if (!widget.askEmail) return true;
    final v = _email.text.trim();
    return v.contains('@') && v.contains('.') && v.length >= 5;
  }

  bool get _canContinue =>
      _emailValid &&
      (_duration != AdminGrantDuration.custom || _customDate != null);

  Future<void> _pickDate() async {
    final now = _now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime(now.year, now.month + 1, now.day),
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 10, now.month, now.day),
      helpText: 'Premium tot en met',
      cancelText: 'Annuleren',
      confirmText: 'Kiezen',
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _duration = AdminGrantDuration.custom;
      });
    }
  }

  void _select(AdminGrantDuration d) {
    if (d == AdminGrantDuration.custom) {
      _pickDate();
      return;
    }
    setState(() => _duration = d);
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.submit(
        AdminGrantRequest(
          duration: _duration,
          until: _duration == AdminGrantDuration.custom ? _customDate : null,
          note: _note.text,
        ),
        widget.askEmail ? _email.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      final (_, title, message) = describeAdminError(e);
      setState(() {
        _busy = false;
        _error = title == 'Er ging iets mis' ? message : '$title. $message';
      });
    }
  }

  String get _endText {
    if (_duration == AdminGrantDuration.lifetime) return 'zonder einddatum';
    final end = _duration.previewEnd(_now, custom: _customDate);
    return 'tot en met ${AdminFormat.date(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.ruleStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const BqIconTile(
                  size: 40,
                  background: AppTheme.goldTint,
                  child: BqIcon(BqIcons.crown, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _confirming ? 'Klopt dit?' : 'Premium geven',
                        style: AppTheme.displayMedium,
                      ),
                      if (widget.userName != null)
                        Text(
                          widget.userName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_confirming) ..._confirmStep() else ..._chooseStep(),
          ],
        ),
      ),
    );
  }

  List<Widget> _chooseStep() {
    final current = widget.currentGrant;
    return [
      if (widget.askEmail) ...[
        const Text('E-mailadres van het account', style: AppTheme.metaLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'naam@voorbeeld.nl'),
        ),
        const SizedBox(height: 16),
      ],
      const Text('Hoe lang', style: AppTheme.metaLabel),
      const SizedBox(height: 6),
      BqListCard(
        children: [
          for (final d in AdminGrantDuration.values)
            _DurationRow(
              label: d == AdminGrantDuration.custom && _customDate != null
                  ? 'Tot en met ${AdminFormat.date(_customDate)}'
                  : d.label,
              hint: switch (d) {
                AdminGrantDuration.lifetime => 'Geen einddatum',
                AdminGrantDuration.custom => 'Kies zelf de laatste dag',
                _ => 'Tot ${AdminFormat.date(d.previewEnd(_now))}',
              },
              selected: _duration == d,
              onTap: () => _select(d),
            ),
        ],
      ),
      if (current != null && current.active) ...[
        const SizedBox(height: 10),
        Text(
          current.until == null
              ? 'Dit account heeft al handmatig Premium zonder einddatum. '
                    'Deze keuze vervangt die.'
              : 'Dit account heeft al handmatig Premium tot '
                    '${AdminFormat.date(current.until)}. Deze keuze vervangt '
                    'die einddatum (telt niet op).',
          style: AppTheme.caption.copyWith(color: AppTheme.goldText),
        ),
      ],
      const SizedBox(height: 16),
      const Text('Notitie (optioneel)', style: AppTheme.metaLabel),
      const SizedBox(height: 6),
      TextField(
        controller: _note,
        maxLength: 300,
        maxLines: 2,
        minLines: 1,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: 'Bijvoorbeeld: prijs van de zomerquiz',
          counterText: '',
        ),
      ),
      const SizedBox(height: 20),
      BqButton(
        label: 'Verder',
        onPressed: _canContinue
            ? () => setState(() {
                _confirming = true;
                _error = null;
              })
            : null,
      ),
      const SizedBox(height: 4),
      BqButton(
        label: 'Annuleren',
        style: BqButtonStyle.secondary,
        height: 46,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
  }

  List<Widget> _confirmStep() {
    final who = widget.askEmail
        ? _email.text.trim()
        : (widget.userName ?? 'dit account');
    final note = _note.text.trim();
    return [
      BqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Je geeft '),
                  TextSpan(
                    text: who,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' Premium '),
                  TextSpan(
                    text: _endText,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: _duration == AdminGrantDuration.custom ||
                            _duration == AdminGrantDuration.lifetime
                        ? '.'
                        : ' (${_duration.label}).',
                  ),
                ],
              ),
              style: AppTheme.bodyLead.copyWith(color: AppTheme.ink),
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notitie: $note', style: AppTheme.caption),
            ],
            const SizedBox(height: 8),
            Text(
              'Stripe, store, levenslang en groepslicenties blijven zoals ze '
              'zijn. De gift stopt vanzelf op de einddatum.',
              style: AppTheme.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 12),
        BqCard(
          color: AppTheme.coralTint,
          borderColor: AppTheme.coralLine,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 18, color: AppTheme.vermilion),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: AppTheme.caption.copyWith(color: AppTheme.vermilion),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      BqButton(
        label: 'Bevestigen',
        loading: _busy,
        onPressed: _busy ? null : _confirm,
      ),
      const SizedBox(height: 4),
      BqButton(
        label: 'Terug',
        style: BqButtonStyle.secondary,
        height: 46,
        onPressed: _busy ? null : () => setState(() => _confirming = false),
      ),
    ];
  }
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppTheme.lapis : AppTheme.paperRaised,
                  border: Border.all(
                    color: selected ? AppTheme.lapis : AppTheme.ruleStrong,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: BqIcon(
                          BqIcons.check,
                          size: 12,
                          color: AppTheme.inkInverted,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyStrong.copyWith(
                    color: selected ? AppTheme.lapisStrong : AppTheme.ink,
                  ),
                ),
              ),
              Text(hint, style: AppTheme.caption.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
