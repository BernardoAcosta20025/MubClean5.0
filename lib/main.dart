import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Imports de tus pantallas
import 'package:mubclean/src/features/auth/login_page.dart';
import 'package:mubclean/src/features/home/home_page.dart';
import 'package:mubclean/src/features/auth/update_password_page.dart'; // Importante importar esto

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // Tus credenciales reales (Las mantengo igual)
    url: 'https://nvswszwballqzzuziwyx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52c3dzendiYWxscXp6dXppd3l4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTIyNTUsImV4cCI6MjA3ODQ4ODI1NX0.OxfXYVGveWAlMxsSVB4MBIA-3TT_mKuXrCfOWkQs0AY',
  );

  runApp(const MyApp());
}

// Cliente global
final supabase = Supabase.instance.client;

// Llave global para poder navegar desde cualquier lugar
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Este es el "Oído Global". Escucha eventos siempre.
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      // Si detectamos que el usuario viene de un link de recuperar contraseña:
      if (event == AuthChangeEvent.passwordRecovery) {
        // Usamos la llave global para forzar la navegación a la pantalla de nueva contraseña
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colores extraídos de tu imagen de referencia
    const Color mubBlue = Color(0xFF0A7AFF); 
    const Color mubText = Color(0xFF1D1D1F);
    const Color mubInputBg = Color(0xFFF2F2F7);

    return MaterialApp(
      title: 'MubClean',
      navigatorKey: navigatorKey, // <--- IMPORTANTE: Conectamos la llave aquí
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: mubBlue, primary: mubBlue),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: mubText),
          titleTextStyle: TextStyle(color: mubText, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: mubInputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mubBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // Lógica de sesión inicial
      home: supabase.auth.currentSession != null ? const HomePage() : const LoginPage(),
    );
  }
}