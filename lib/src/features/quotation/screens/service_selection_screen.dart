import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/furniture_details_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizar un Servicio'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F7),
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
            const Text('Paso 1 de 5', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
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
                    description: 'Eliminación de manchas y suciedad.',
                    icon: Icons.layers,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(
                    serviceName: 'Limpieza de Colchones',
                    description: 'Desinfección profunda.',
                    icon: Icons.bed_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(
                    serviceName: 'Limpieza General',
                    description: 'Servicio completo para el hogar.',
                    icon: Icons.cleaning_services_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedService == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FurnitureDetailsScreen(selectedService: _selectedService!),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({required String serviceName, required String description, required IconData icon}) {
    final bool isSelected = _selectedService == serviceName;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = serviceName),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A7AFF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: isSelected ? const Color(0xFF0A7AFF) : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0A7AFF) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0A7AFF), size: 24),
          ],
        ),
      ),
    );
  }
}