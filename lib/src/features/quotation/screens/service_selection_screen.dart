// lib/src/features/quotation/screens/service_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/furniture_details_screen.dart'; // Asegúrate de crear este archivo en el siguiente paso

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService; // Para guardar la selección del usuario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizar un Servicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el servicio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Paso 1 de 7',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // FIX: La lista ahora es desplazable y el botón se mantiene abajo.
            Expanded(
              child: ListView(
                children: [
                  _buildServiceCard(
                    serviceName: 'Limpieza de Sala',
                    description: 'Limpieza profunda de salas y sillones.',
                    icon: Icons.chair_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(
                    serviceName: 'Limpieza de Alfombras',
                    description:
                        'Eliminación de manchas y suciedad en alfombras.',
                    icon: Icons.carpenter_sharp,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(
                    serviceName: 'Limpieza de Colchones',
                    description: 'Desinfección y limpieza de colchones.',
                    icon: Icons.bed_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(
                    serviceName: 'Limpieza General',
                    description: 'Servicio completo para el hogar u oficina.',
                    icon: Icons.cleaning_services_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Espacio entre la lista y el botón
            // Botón para continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedService == null
                    ? null // Deshabilitado si no hay servicio seleccionado
                    : () {
                        // Navega a la siguiente pantalla (Detalle de muebles)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FurnitureDetailsScreen(
                              selectedService: _selectedService!,
                            ),
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
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String serviceName,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected = _selectedService == serviceName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = serviceName; // Selecciona este servicio
        });
      },
      child: Card(
        color: isSelected
            ? const Color(0xFFE0F2FF)
            : Colors.white, // Color de selección
        elevation: isSelected ? 4 : 2, // Elevación para resaltar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(color: Color(0xFF0A7AFF), width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? const Color(0xFF0A7AFF) : Colors.grey[700],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF0A7AFF)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xCC0A7AFF)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF0A7AFF),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
