import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/main.dart';
import 'package:mubclean/src/features/auth/login_page.dart';
import 'package:mubclean/src/features/home/widgets/home_widgets.dart'; // Asegúrate que esté importado
import 'package:mubclean/src/features/home/profile_tab.dart';

// --- NUEVO IMPORT para la imagen del logo ---
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui; // Para el asset de imagen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0: Inicio, 1: Historial, 2: Perfil
  String _userName = 'Usuario'; 
  ui.Image? _logoImage; // Variable para cargar el logo

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadLogoAsset(); // Cargar el logo al iniciar
  }

  // Cargar el nombre del usuario
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
      // Manejar error o dejar nombre por defecto
    }
  }

  // Cargar el logo de la empresa
  Future<void> _loadLogoAsset() async {
    final ByteData data = await rootBundle.load('assets/mubclean_logo.png'); // Ruta de tu logo
    final List<int> bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _logoImage = frameInfo.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: _selectedIndex == 0 
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF0A7AFF),
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hola,', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text(_userName, style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )
            : Text(
                _getAppBarTitle(),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
        actions: [
          // Icono de Notificaciones
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 10), // Espacio
        ],
      ),

      body: _getSelectedView(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A7AFF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1: return 'Historial de Servicios';
      case 2: return 'Mi Perfil';
      default: return '';
    }
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(logoImage: _logoImage); // Pasamos el logo al HomeContent
      case 1:
        return const Center(child: Text("Aquí verás tus servicios anteriores"));
      case 2:
        return const ProfileTab();
      default:
        return HomeContent(logoImage: _logoImage);
    }
  }
}

// --- CONTENIDO DEL HOME MEJORADO ---
class HomeContent extends StatelessWidget {
  final ui.Image? logoImage; // Recibimos el logo

  const HomeContent({super.key, this.logoImage});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        
        // 1. LOGO DE LA EMPRESA (Si está cargado)
        if (logoImage != null)
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 120, // Ajusta el tamaño del logo
              height: 120,
              child: RawImage(image: logoImage, fit: BoxFit.contain),
            ),
          ),
        const SizedBox(height: 10),
        
        // 2. IMAGEN VISTOSA CENTRAL
        Image.asset(
          'assets/cleaning_image.png', // RUTA DE TU IMAGEN VISTOSA
          height: 150,
        ),
        const SizedBox(height: 15),

        const Center(
          child: Column(
            children: [
              Text(
                "¡Estamos listos para limpiar!",
                style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
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

        const SizedBox(height: 40), // Espacio

        // 3. SECCIÓN AYUDA Y SOPORTE
        const Text("Ayuda y Soporte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        
        const QuickAccessItem(icon: Icons.support_agent_rounded, title: "Contactar Soporte"),
        const QuickAccessItem(icon: Icons.info_outline, title: "Preguntas Frecuentes"),
        
        const SizedBox(height: 40), // Espacio

        // 4. BOTÓN "COTIZAR UN SERVICIO" (Ahora debajo de Ayuda y Soporte)
        CotizarServicioButton(
          onPressed: () {
            // AQUÍ NAVEGARÁ A LA PANTALLA DE SELECCIÓN DE SERVICIOS
            print('Navegando a selección de servicios...'); 
          },
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}