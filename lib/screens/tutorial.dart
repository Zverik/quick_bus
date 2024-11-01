import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/providers/tutorial_state.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class TutorialPage extends ConsumerWidget {
  static const String SEEN_TUTORIAL_KEY = "seen_tutorial";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const decoration = PageDecoration(
      imagePadding: EdgeInsets.symmetric(vertical: 24.0),
    );
    final loc = AppLocalizations.of(context)!;
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: loc.tMainScreen,
          image: SizedBox(
            width: 240.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenPart(
                  color: Colors.red,
                  text: loc.msMap,
                ),
                ScreenPart(
                  color: Colors.blue,
                  text: loc.msDestination,
                ),
                ScreenPart(
                  color: Colors.cyan,
                  text: loc.msArrivals,
                ),
              ],
            ),
          ),
          bodyWidget: Text(
            loc.bMainScreen,
            style: decoration.bodyTextStyle,
            textAlign: TextAlign.start,
          ),
          decoration: decoration,
        ),
        PageViewModel(
          title: loc.tBookmarks,
          bodyWidget: Text(
            loc.bBookmarks,
            style: decoration.bodyTextStyle,
            textAlign: TextAlign.start,
          ),
          image: Center(
              child:
                  Image.asset('assets/tutorial_bookmarks.png', height: 833.0)),
          decoration: decoration,
        ),
        PageViewModel(
          title: loc.tSaveThePlan,
          bodyWidget: Text(
            loc.bSaveThePlan,
            style: decoration.bodyTextStyle,
            textAlign: TextAlign.start,
          ),
          image: Center(
              child:
                  Image.asset('assets/tutorial_saved_plan.png', height: 716.0)),
          decoration: decoration,
        ),
        PageViewModel(
          title: loc.tFriendRoute,
          bodyWidget: Text(
            loc.bFriendRoute,
            style: decoration.bodyTextStyle,
            textAlign: TextAlign.start,
          ),
          image: Center(
              child:
              Image.asset('assets/tutorial_starting.png', height: 584.0)),
          decoration: decoration,
        ),
      ],
      safeAreaList: [false, false, true, false],
      done: Text(
        loc.tutorialDone,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      next: const Icon(Icons.navigate_next),
      onDone: () {
        final seenTutorial = ref.read(seenTutorialProvider.notifier);
        seenTutorial.setSeen();
        Navigator.pop(context);
      },
    );
  }
}

class ScreenPart extends StatelessWidget {
  final Color color;
  final String text;

  ScreenPart({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}
