import 'dart:async'; // Necesario para StreamSubscription
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/main.dart';
import 'package:mubclean/src/features/home/home_page.dart';
import 'package:mubclean/src/shared/utils/helpers.dart';
import 'package:mubclean/src/features/auth/sign_up_page.dart';
import 'package:mubclean/src/features/auth/update_password_page.dart'; // Importamos la nueva página

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  // Variable para escuchar los eventos de Supabase
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // ESCUCHAMOS LOS CAMBIOS DE ESTADO
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      // SI EL EVENTO ES RECUPERACIÓN DE CONTRASEÑA...
      if (event == AuthChangeEvent.passwordRecovery) {
        if (!mounted) return;
        // ... NAVEGAMOS A LA PANTALLA DE CAMBIAR CONTRASEÑA
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancelamos la escucha al salir para evitar errores de memoria
    _authStateSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Ocurrió un error inesperado', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para pedir el correo de recuperación
  Future<void> _recoverPassword() async {
    final TextEditingController recoveryEmailController =
        TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: TextField(
          controller: recoveryEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Ingresa tu email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed == true && recoveryEmailController.text.isNotEmpty) {
      try {
        await supabase.auth.resetPasswordForEmail(
          recoveryEmailController.text.trim(),
        );
        if (mounted) context.showSnackBar('¡Link enviado! Revisa tu correo.');
      } catch (error) {
        if (mounted) {
          context.showSnackBar('Error al enviar correo', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          // Use screenWidth from helpers.dart
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Correo electrónico',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu correo',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Contraseña',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                ),
              ),

              const SizedBox(height: 16),

              // --- CAMBIO AQUÍ: QUITAMOS EL CHECKBOX "RECORDARME" ---
              // Solo dejamos el enlace de recuperar contraseña alineado a la derecha
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _recoverPassword,
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Color(0xFF0A7AFF),
                      fontWeight: FontWeight.w600,
                      fontSize:
                          14, // Un poquito más grande para que sea fácil de tocar
                    ),
                  ),
                ),
              ),

              // -----------------------------------------------------
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A7AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    ),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF0A7AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
