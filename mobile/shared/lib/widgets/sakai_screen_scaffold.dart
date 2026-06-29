import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import 'sakai_app_bar.dart';

/// Common screen layout: [SakaiAppBar], padded body, optional bottom bar.
class SakaiScreenScaffold extends StatelessWidget {
  const SakaiScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.fab,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    return Scaffold(
      appBar: SakaiAppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Padding(
        padding: EdgeInsets.all(t.spaceMd),
        child: body,
      ),
      bottomNavigationBar: bottom,
      floatingActionButton: fab,
    );
  }
}
