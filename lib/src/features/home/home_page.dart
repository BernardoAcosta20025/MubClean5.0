import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:mubclean/main.dart'; // Cliente de Supabase global
import 'package:mubclean/src/features/home/widgets/home_widgets.dart';
import 'package:mubclean/src/features/home/profile_tab.dart'; 
import 'package:mubclean/src/features/history/history_page.dart'; // NECESARIO

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 
  String _userName = 'Usuario';
  ui.Image? _logoImage;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

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
      // Error silencioso
    }
  }

  

  @override
  Widget build(BuildContext context) {
    const Color mubBlue = Color(0xFF0A7AFF);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      
      appBar: _selectedIndex != 0 ? null : AppBar( // Solo muestra AppBar en Inicio
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
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
        ),
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _getSelectedView(), // Aquí se decide qué pantalla mostrar

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: mubBlue,
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

  // --- LÓGICA DE NAVEGACIÓN PRINCIPAL ---

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return const HomeContent();
      case 1:
        // LLAMADA FINAL Y CORREGIDA: Sin 'const'
        return const HistoryPage(); 
      case 2:
        return const ProfileTab();
      default:
        return HomeContent(logoImage: _logoImage);
    }
  }
}

// --- CLASE CONTENEDORA DEL HOME (ListView) ---
class HomeContent extends StatelessWidget {
  final ui.Image? logoImage;

  const HomeContent({super.key, this.logoImage});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/image/Logo.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 25),
        
        // Botón Cotizar
        CotizarServicioButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Próximamente: Módulo de Cotización"))
            );
          },
        ),

        const SizedBox(height: 40),
        const Text("Ayuda y Soporte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const QuickAccessItem(icon: Icons.support_agent_rounded, title: "Contactar Soporte"),
        const QuickAccessItem(icon: Icons.info_outline, title: "Preguntas Frecuentes"),
        const SizedBox(height: 20),
      ],
    );
  }
}
