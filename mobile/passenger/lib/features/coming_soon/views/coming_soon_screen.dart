import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SakaiAppBar(title: Text(feature)),
      body: SafeArea(
        child: ComingSoonState(
          feature: feature,
          onBack: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
    );
  }
}
