import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../data/backup.dart';
import '../common/widgets.dart';

String backupFileName(DateTime now) {
  final wall = KolkataTime.wallClock(now);
  String two(int value) => value.toString().padLeft(2, '0');
  return 'fintrack-backup-${wall.year}-${two(wall.month)}-${two(wall.day)}-${two(wall.hour)}${two(wall.minute)}.ftbackup';
}

String backupFailureText(BackupFailure failure) => switch (failure) {
      BackupFailure.notABackup => S.backupNotABackup,
      BackupFailure.wrongPassphrase => S.backupWrongPassphrase,
      BackupFailure.newerVersion => S.backupNewer,
      BackupFailure.damaged => S.backupDamaged,
    };

Future<String?> askPassphrase(BuildContext context, {required bool confirm}) =>
    showDialog<String>(context: context, builder: (_) => _PassphraseDialog(confirm: confirm));

Future<bool> runRestoreFlow(BuildContext context, WidgetRef ref, {required bool replacing}) async {
  final messenger = ScaffoldMessenger.of(context);
  ref.read(lockProvider.notifier).expectExternal();
  final Uint8List? bytes;
  try {
    bytes = await ref.read(fileBridgeProvider).pickFile();
  } on PlatformException {
    return false;
  }
  if (bytes == null || !context.mounted) {
    return false;
  }
  final BackupInfo info;
  try {
    info = BackupCodec.inspect(bytes);
  } on BackupException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(backupFailureText(error.failure))));
    return false;
  }
  final passphrase = await askPassphrase(context, confirm: false);
  if (passphrase == null || !context.mounted) {
    return false;
  }
  if (replacing) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(S.restoreConfirm(formatDate(KolkataTime.dateOf(info.createdAt)))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text(S.cancel)),
          FilledButton(key: const Key('restore-confirm'), onPressed: () => Navigator.of(context).pop(true), child: const Text(S.restore)),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return false;
    }
  }
  try {
    await ref.read(budgetProvider.notifier).restoreBackup(bytes, passphrase);
  } on BackupException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(backupFailureText(error.failure))));
    return false;
  }
  ref.read(lockProvider.notifier).unlock();
  messenger.showSnackBar(const SnackBar(content: Text(S.restored)));
  return true;
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  var _busy = false;
  String? _savedTo;
  Uint8List? _lastBytes;
  String? _lastName;

  Future<void> _create() async {
    final passphrase = await askPassphrase(context, confirm: true);
    if (passphrase == null) {
      return;
    }
    setState(() => _busy = true);
    final now = ref.read(clockProvider)();
    final bytes = await ref.read(budgetProvider.notifier).createBackup(passphrase);
    final name = backupFileName(now);
    String? location;
    try {
      ref.read(lockProvider.notifier).expectExternal();
      location = await ref.read(fileBridgeProvider).saveToDownloads(name, bytes);
    } on PlatformException {
      location = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _lastBytes = bytes;
      _lastName = name;
      _savedTo = location;
    });
  }

  Future<void> _share() async {
    final bytes = _lastBytes;
    final name = _lastName;
    if (bytes == null || name == null) {
      return;
    }
    ref.read(lockProvider.notifier).expectExternal();
    await ref.read(fileBridgeProvider).share(name, bytes);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final last = ref.watch(budgetProvider.select((value) => value.value?.preferences.lastBackupAt));
    return Scaffold(
      appBar: AppBar(title: const Text(S.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            key: const Key('backup-warning'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: palette.tight),
                const SizedBox(width: 12),
                Expanded(child: Text(S.backupNotice, style: textTheme.bodyMedium)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            last == null ? S.neverBackedUp : S.lastBackup(formatDate(KolkataTime.dateOf(last))),
            key: const Key('last-backup'),
            style: textTheme.bodyMedium?.copyWith(color: palette.mutedText),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('create-backup'),
            onPressed: _busy ? null : _create,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_alt),
            label: Text(_busy ? S.creatingBackup : S.createBackup),
          ),
          if (_lastBytes != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              key: const Key('backup-result'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_savedTo == null ? S.notSaved : S.savedTo(_savedTo!), style: textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(onPressed: _share, icon: const Icon(Icons.share_outlined), label: const Text(S.share)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('restore-backup'),
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    final navigator = Navigator.of(context);
                    final ok = await runRestoreFlow(context, ref, replacing: true);
                    if (!mounted) {
                      return;
                    }
                    setState(() => _busy = false);
                    if (ok) {
                      navigator.pop();
                    }
                  },
            icon: const Icon(Icons.restore),
            label: const Text(S.restoreBackup),
          ),
        ],
      ),
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.confirm});

  final bool confirm;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _second = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.passphrase),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.confirm) const Text(S.passphraseHint),
            TextFormField(
              key: const Key('passphrase'),
              controller: _first,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: S.passphrase),
              validator: (value) => (value ?? '').length < BackupCodec.minimumPassphraseLength ? S.passphraseTooShort : null,
            ),
            if (widget.confirm)
              TextFormField(
                key: const Key('passphrase-again'),
                controller: _second,
                obscureText: true,
                decoration: const InputDecoration(labelText: S.confirmPassphrase),
                validator: (value) => value != _first.text ? S.passphraseMismatch : null,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('passphrase-ok'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(_first.text);
            }
          },
          child: const Text(S.confirm),
        ),
      ],
    );
  }
}
