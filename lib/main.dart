import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'screens/main_menu_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MagicSweeperApp());
}

class MagicSweeperApp extends StatelessWidget {
  const MagicSweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
      ],
      child: MaterialApp(
        title: 'Magic Sweeper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.magicPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MagicSweeperHome(),
      ),
    );
  }
}

class MagicSweeperHome extends StatelessWidget {
  const MagicSweeperHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Show loading indicator while settings are loading
        if (!settingsProvider.isLoaded) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.menuGradient,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.magicPurple,
                ),
              ),
            ),
          );
        }

        return const MainMenuScreen();
      },
    );
  }
}
