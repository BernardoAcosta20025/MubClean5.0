import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:mubclean/main.dart'; // Cliente de Supabase global
import 'package:mubclean/src/features/home/widgets/home_widgets.dart';
import 'package:mubclean/src/features/home/profile_tab.dart';
// ✨ CAMBIO: Importamos la pantalla del Paso 1 del nuevo flujo
import 'package:mubclean/src/features/quotation/screens/service_selection_screen.dart';
import 'package:mubclean/src/features/history/history_page.dart'; // Pantalla de historial

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0: Inicio, 1: Historial, 2: Perfil
  String _userName = 'Usuario';
  ui.Image? _logoImage;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadLogoAsset();
  }

  // Cargar el nombre del usuario desde Supabase
  Future<void> _loadUserName() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final data = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            String fullName = data['full_name'] ?? 'Usuario';
            _userName = fullName.split(' ')[0];
          });
        }
      }
    } catch (e) {
      // MEJORA: Mostrar un error si la carga del nombre falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos del usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('*** Error en _loadUserName: $e');
    }
  }

  // Cargar el logo de la empresa como asset de imagen
  Future<void> _loadLogoAsset() async {
    try {
      // CORRECCIÓN: La ruta del asset era incorrecta.
      final ByteData data = await rootBundle.load('assets/image/Logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _logoImage = frameInfo.image;
        });
      }
    } catch (e) {
      // MEJORA: Mostrar un error si la carga del logo falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint("Error al cargar el logo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      // AppBar solo visible en la pestaña de Inicio (índice 0)
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFFF5F5F7),
              elevation: 0,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF0A7AFF),
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola,',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La pantalla de notificaciones aún no está implementada.',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            )
          : AppBar(
              title: Text(_getAppBarTitle()),
              centerTitle: true,
              elevation: 1,
            ),

      body: _getSelectedView(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A7AFF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Historial de Servicios';
      case 2:
        return 'Mi Perfil';
      default:
        return '';
    }
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(logoImage: _logoImage);
      case 1:
        return const HistoryPage();
      case 2:
        return const ProfileTab();
      default:
        return HomeContent(logoImage: _logoImage);
    }
  }
}

class HomeContent extends StatelessWidget {
  final ui.Image? logoImage;

  const HomeContent({super.key, this.logoImage});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Logo
        if (logoImage != null)
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 120,
              height: 120,
              child: RawImage(image: logoImage, fit: BoxFit.contain),
            ),
          )
        else
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/image/Logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),
          ),

        const SizedBox(height: 10),

        // Imagen Central
        Image.asset(
          'assets/image/Mueble.png',
          height: 150,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, size: 100, color: Colors.grey),
        ),

        const SizedBox(height: 15),

        const Center(
          child: Column(
            children: [
              Text(
                "¡Estamos listos para limpiar!",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Cotiza tu servicio de limpieza en segundos.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Ayuda y Soporte
        const Text(
          "Ayuda y Soporte",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        const QuickAccessItem(
          icon: Icons.support_agent_rounded,
          title: "Contactar Soporte",
        ),
        const QuickAccessItem(
          icon: Icons.info_outline,
          title: "Preguntas Frecuentes",
        ),

        const SizedBox(height: 40),

        // Botón Cotizar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // ✨ CAMBIO: Navegamos al NUEVO FLUJO (Paso 1: Selección de Servicio)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceSelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A7AFF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cotizar un Servicio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
