import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/upload_screen.dart';
import 'screens/result_screen.dart';
import 'screens/history_screen.dart';
import 'services/api_service.dart';
import 'services/history_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VehicleDetectionApp());
}

class VehicleDetectionApp extends StatelessWidget {
  const VehicleDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<HistoryService>(
          create: (_) => HistoryService(),
        ),
      ],
      child: MaterialApp(
        title: 'Vehicle Detection',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routes: {
          '/': (_) => const UploadScreen(),
          ResultScreen.routeName: (_) => const ResultScreen(),
          HistoryScreen.routeName: (_) => const HistoryScreen(),
        },
      ),
    );
  }
}
