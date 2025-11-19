import 'package:flutter/material.dart';
import 'package:mubclean/main.dart'; // Para acceder a supabase

class EditProfilePage extends StatefulWidget {
  // Recibimos los datos actuales para rellenar los campos
  final String currentName;
  final String currentPhone;
  final String currentEmail;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController; // Para mostrar, aunque no se edita
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos que recibimos
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;

      // Enviamos SOLO los cambios de nombre y teléfono a Supabase
      await supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        // Regresamos 'true' para indicar que hubo cambios y que la página anterior debe refrescarse
        Navigator.pop(context, true); 
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $error'), backgroundColor: Colors.red),
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
        title: const Text("Editar Perfil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo NO editable (Email)
            const Text("Email (No editable)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            TextField(
              controller: _emailController,
              enabled: false, // No se puede editar el email
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Campo Nombre
            const Text("Nombre Completo"),
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo Teléfono
            const Text("Teléfono"),
            const SizedBox(height: 5),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar Cambios", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}