import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/main.dart';
// import 'package:mubclean/src/features/home/home_page.dart'; // Ya no lo usamos directo porque volvemos al Login

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Llave global para validar
  
  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUp() async {
    // 1. Ejecuta todas las validaciones (Regex) antes de hacer nada
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Enviar datos a Supabase (incluyendo nombre y teléfono como metadata)
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      final User? user = res.user;

      if (user != null) {
        if (mounted) {
          // Mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada! Revisa tu correo para confirmar.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Regresamos al Login para que el usuario espere su confirmación
          Navigator.of(context).pop(); 
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey, // Conectamos la llave del formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nombre Completo'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words, // Pone mayúscula inicial
                decoration: _inputDecoration('Ej: Sofia Ramirez'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El nombre es obligatorio';
                  if (value.length < 3) return 'El nombre es muy corto';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Ej: sofia@email.com'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El email es obligatorio';
                  // Regex Profesional para Email
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Ingresa un correo válido (ej: usuario@dominio.com)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Número de Teléfono'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number, // Teclado numérico
                decoration: _inputDecoration('Ej: 9991234567'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El teléfono es obligatorio';
                  // Regex: Solo números
                  final numberRegex = RegExp(r'^[0-9]+$');
                  if (!numberRegex.hasMatch(value)) return 'Solo se permiten números (sin guiones ni espacios)';
                  if (value.length != 10) return 'El teléfono debe tener 10 dígitos exactos';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Contraseña'),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('********'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
                  if (value.length < 8) return 'Mínimo 8 caracteres';
                  if (!value.contains(RegExp(r'[0-9]'))) return 'Debe contener al menos un número';
                  if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener al menos una mayúscula';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text('Requisito: 8 caracteres, 1 número, 1 mayúscula.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              
              const SizedBox(height: 16),

              _buildLabel('Confirmar Contraseña'),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration('********'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                  if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A7AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Crear Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Al crear una cuenta, aceptas nuestros Términos y Condiciones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}