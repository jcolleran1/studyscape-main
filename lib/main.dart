import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_controller_scope.dart';

/// Never block [runApp] on prefs I/O — if [SharedPreferences] hangs or throws,
/// awaiting here would leave a permanent blank screen before the first frame.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  themeController.load().catchError((Object e, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: e, stack: stack, library: 'theme'),
    );
  });
  runApp(
    ThemeControllerScope(
      notifier: themeController,
      child: StudyScapeApp(themeController: themeController),
    ),
  );
}

class StudyScapeApp extends StatelessWidget {
  const StudyScapeApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'StudyScape',
          debugShowCheckedModeBanner: false,
          theme: buildStudyscapeTheme(Brightness.light),
          darkTheme: buildStudyscapeTheme(Brightness.dark),
          themeMode: themeController.themeMode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
