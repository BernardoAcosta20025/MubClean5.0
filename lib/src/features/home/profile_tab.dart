import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Librería para galería
import 'package:supabase_flutter/supabase_flutter.dart'; // Necesario para excepciones de Storage
import 'package:mubclean/main.dart';
import 'package:mubclean/src/features/auth/login_page.dart';
import 'package:mubclean/src/features/edit_profile_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  bool _isUploading = false; // Para mostrar carga en la foto
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNCIÓN PARA SUBIR FOTO ---
  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    // 1. Abrir galería
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (image == null) return; // Usuario canceló

    setState(() => _isUploading = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      final imageExtension = image.path.split('.').last;
      final imagePath =
          '/$userId/profile.$imageExtension'; // Ruta: /id_usuario/profile.jpg
      final imageBytes = await image.readAsBytes();

      // 2. Subir a Supabase Storage (Bucket 'avatars')
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
            ), // Sobreescribir si existe
          );

      // 3. Obtener la URL pública
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(imagePath);

      // 4. Actualizar la tabla profiles con la nueva URL
      // Truco: Agregamos un timestamp al final (?v=...) para obligar a refrescar la imagen en la app
      final urlWithTimestamp =
          '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      await supabase
          .from('profiles')
          .update({
            'avatar_url': urlWithTimestamp,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 5. Recargar perfil
      await _getProfile();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto actualizada')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final name = _profileData?['full_name'] ?? 'Usuario';
    final phone = _profileData?['phone'] ?? 'Sin teléfono';
    final email = supabase.auth.currentUser?.email ?? '';
    final avatarUrl = _profileData?['avatar_url']; // URL de la foto

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),

        // --- AVATAR CON LÓGICA DE FOTO ---
        Center(
          child: Stack(
            children: [
              _isUploading
                  ? const CircleAvatar(
                      radius: 60,
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange[100],
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            )
                          : null,
                    ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Mostramos opciones: Editar datos o Cambiar foto
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_camera),
                            title: const Text('Cambiar Foto'),
                            onTap: () {
                              Navigator.pop(context); // Cerrar menú
                              _uploadPhoto(); // Ejecutar subida
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Editar Nombre/Teléfono'),
                            onTap: () async {
                              Navigator.pop(context);
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    currentName: name,
                                    currentPhone: phone,
                                    currentEmail: email,
                                  ),
                                ),
                              );
                              if (result == true) _getProfile();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A7AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------
        const SizedBox(height: 15),
        Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text("Cliente", style: TextStyle(color: Colors.grey)),
        ),

        const SizedBox(height: 30),

        const Text(
          "Información Personal",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        _infoCard(Icons.email, "Email", email),
        const SizedBox(height: 10),
        _infoCard(Icons.phone, "Teléfono", phone),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              "Cerrar Sesión",
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            // <-- FIX: Permite que la columna ocupe el espacio restante
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow
                      .ellipsis, // <-- FIX: Añade puntos suspensivos si el texto es muy largo
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
