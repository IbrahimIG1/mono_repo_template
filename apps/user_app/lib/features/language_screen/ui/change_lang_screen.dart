import 'package:flutter/material.dart';
import 'package:monorepo_template/features/language_screen/ui/widgets/change_lang_screen_body.dart';

class ChangeLangScreen extends StatelessWidget {
  const ChangeLangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ChangeLangScreenBody()],
            ),
          ),
        ],
      ),
    );
  }
}
