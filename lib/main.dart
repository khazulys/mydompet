import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FThemes.zinc.dark;

    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      theme: theme.toApproximateMaterialTheme().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFF1A1A1A),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      builder: (_, child) => FAnimatedTheme(
        data: theme,
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
