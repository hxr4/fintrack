import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../platform/authenticator.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  var _busy = false;
  var _unavailable = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final outcome = await ref.read(authenticatorProvider).authenticate(S.unlockReason);
    if (!mounted) {
      return;
    }
    switch (outcome) {
      case AuthOutcome.success:
        ref.read(lockProvider.notifier).unlock();
      case AuthOutcome.unavailable:
        setState(() => _unavailable = true);
      case AuthOutcome.failed:
        setState(() => _message = S.unlockFailed);
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 56, color: palette.accent),
                const SizedBox(height: 16),
                Text(S.lockTitle, style: textTheme.titleLarge?.copyWith(color: palette.text)),
                const SizedBox(height: 24),
                if (_unavailable) ...[
                  Text(S.lockUnavailable, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: palette.mutedText)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.read(lockProvider.notifier).unlock(),
                    child: const Text(S.continueAnyway),
                  ),
                ] else
                  FilledButton.icon(
                    key: const Key('unlock-button'),
                    onPressed: _busy ? null : _unlock,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text(S.unlock),
                  ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
