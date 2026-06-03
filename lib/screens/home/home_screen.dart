import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../routing/router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Double Entry'),
        actions: [
          // Sync button — will show badge when items are pending
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
            onPressed: () {
              // TODO: trigger sync
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('No pending transactions.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.newTransaction),
        tooltip: 'New transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
