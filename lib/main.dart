import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'services/auth_service.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';
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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SocketService()),
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

class MagicSweeperHome extends StatefulWidget {
  const MagicSweeperHome({super.key});

  @override
  State<MagicSweeperHome> createState() => _MagicSweeperHomeState();
}

class _MagicSweeperHomeState extends State<MagicSweeperHome> {
  @override
  void initState() {
    super.initState();
    // Try to connect to backend on app start
    _initializeBackend();
  }

  Future<void> _initializeBackend() async {
    // Initialize API service first (loads stored session)
    await ApiService().init();
    
    // Then check auth status
    if (mounted) {
      final authService = context.read<AuthService>();
      await authService.checkAuth();
    }
  }

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
