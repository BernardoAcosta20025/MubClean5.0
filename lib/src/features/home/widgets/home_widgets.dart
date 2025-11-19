import 'package:flutter/material.dart';

// Este widget ya no va a navegar, solo es el botón visual.
// La navegación la haremos directamente en home_page.dart para tener más control
class CotizarServicioButton extends StatelessWidget {
  final VoidCallback onPressed; // Agregamos un callback para cuando se presione

  const CotizarServicioButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Tamaño del botón ligeramente más pequeño
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed, // Usamos el callback
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A7AFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline, size: 24),
        label: const Text(
          'Cotizar un Servicio', // Texto cambiado
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Widget para las opciones de Acceso Rápido/Ayuda y Soporte
class QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const QuickAccessItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: const Color(0xFF0A7AFF).withOpacity(0.1), // Ya está bien
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A7AFF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          // Implementar navegación o acción aquí
        },
      ),
    );
  }
}
