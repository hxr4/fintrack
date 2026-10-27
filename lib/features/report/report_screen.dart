import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/strings.dart';
import '../../app/theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.reportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            key: const Key('all-transactions'),
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text(S.allTransactions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/transactions'),
          ),
          const SizedBox(height: 16),
          Text(S.reportLater, style: TextStyle(color: context.palette.mutedText)),
        ],
      ),
    );
  }
}
