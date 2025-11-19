import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/location_access_screen.dart';

class CleaningPreferencesScreen extends StatefulWidget {
  // 1. Recibimos todos los datos acumulados
  final String selectedService;
  final String furnitureType;
  final int furnitureQuantity;
  final String dirtLevel;
  final List<String> stainTypes;

  const CleaningPreferencesScreen({
    super.key,
    required this.selectedService,
    required this.furnitureType,
    required this.furnitureQuantity,
    required this.dirtLevel,
    required this.stainTypes,
  });

  @override
  State<CleaningPreferencesScreen> createState() =>
      _CleaningPreferencesScreenState();
}

class _CleaningPreferencesScreenState extends State<CleaningPreferencesScreen> {
  bool _petFriendly = false;
  bool _ecoFriendly = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferencias de Limpieza',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Paso 4 de 5',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildSwitchTile(
                    title: 'Productos Pet Friendly',
                    subtitle: 'Seguros para mascotas, sin olores fuertes.',
                    value: _petFriendly,
                    onChanged: (val) => setState(() => _petFriendly = val),
                    icon: Icons.pets,
                  ),
                  const SizedBox(height: 15),
                  _buildSwitchTile(
                    title: 'Productos Ecológicos',
                    subtitle: 'Biodegradables y amigables con el ambiente.',
                    value: _ecoFriendly,
                    onChanged: (val) => setState(() => _ecoFriendly = val),
                    icon: Icons.eco,
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Notas Adicionales (Opcional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ej: Cuidado con la pata trasera del sofá...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ), // Add some space at the bottom of scrollable content
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: Colors
                  .white, // Ensure the background for the button is consistent
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a Ubicación (Paso 5)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationAccessScreen(
                        selectedService: widget.selectedService,
                        furnitureType: widget.furnitureType,
                        furnitureQuantity: widget.furnitureQuantity,
                        dirtLevel: widget.dirtLevel,
                        stainTypes: widget.stainTypes,
                        petFriendly: _petFriendly,
                        ecoFriendly: _ecoFriendly,
                        notes: _notesController.text,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFF0A7AFF) : Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF0A7AFF),
        title: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
