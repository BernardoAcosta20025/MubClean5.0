import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/main.dart';
import 'package:mubclean/src/features/auth/login_page.dart';
import 'package:mubclean/src/features/home/widgets/home_widgets.dart';
import 'package:mubclean/src/features/home/profile_tab.dart';
import 'package:mubclean/src/features/history/history_page.dart';
// ELIMINADO: import 'package:mubclean/src/features/quote/category_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0: Inicio, 1: Historial, 2: Perfil
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
      // Si falla, se queda como 'Usuario'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      
      // Solo mostramos el AppBar del Home si estamos en la pestaña 0 (Inicio)
appBar: _selectedIndex != 0 ? null : AppBar(
    // ... todo el código que ya tenías del AppBar ...
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
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 10),
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
        return const HomeContent(); 
      case 1:
        // AQUÍ CONECTAMOS LA PANTALLA DE HISTORIAL
        return const HistoryPage();
      case 2:
        return const ProfileTab();
      default:
        return const HomeContent();
    }
  }
}

// --- CONTENIDO DEL HOME ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        
        // 1. LOGO DE LA EMPRESA
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/image/Logo.png', fit: BoxFit.contain),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // 2. IMAGEN VISTOSA CENTRAL
        Image.asset('assets/image/Mueble.png', 
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

        const SizedBox(height: 40),

        // 3. SECCIÓN AYUDA Y SOPORTE
        const Text("Ayuda y Soporte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        
        const QuickAccessItem(icon: Icons.support_agent_rounded, title: "Contactar Soporte"),
        const QuickAccessItem(icon: Icons.info_outline, title: "Preguntas Frecuentes"),
        
        const SizedBox(height: 40),

        // 4. BOTÓN "COTIZAR UN SERVICIO"
        CotizarServicioButton(
          onPressed: () {
            // CORRECCIÓN: Solo mostramos un mensaje, no navegamos a ningún lado aún.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Próximamente: Módulo de Cotización"))
            );
          },
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}