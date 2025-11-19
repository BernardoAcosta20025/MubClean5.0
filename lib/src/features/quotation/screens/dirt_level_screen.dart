import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/cleaning_preferences_screen.dart';
import 'package:mubclean/src/features/quotation/screens/photo_upload_screen.dart';

class DirtLevelScreen extends StatefulWidget {
  final String selectedService;
  final String furnitureType;
  final int furnitureQuantity;

  const DirtLevelScreen({
    super.key,
    required this.selectedService,
    required this.furnitureType,
    required this.furnitureQuantity,
  });

  @override
  State<DirtLevelScreen> createState() => _DirtLevelScreenState();
}

class _DirtLevelScreenState extends State<DirtLevelScreen> {
  String? _selectedDirtLevel;
  final List<String> _selectedStains = [];

  final List<String> _dirtLevels = ['Bajo', 'Medio', 'Alto'];
  final List<String> _stainTypes = [
    'Comida',
    'Bebida',
    'Mascotas',
    'Tinta',
    'Grasa',
    'Olor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Mueble'),
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
                    'Nivel de suciedad y manchas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Paso 3 de 5',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Nivel general de suciedad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _dirtLevels.map((level) {
                      final isSelected = _selectedDirtLevel == level;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDirtLevel = level),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0A7AFF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0A7AFF)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                level,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Tipos de manchas (Opcional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _stainTypes.map((stain) {
                      final isSelected = _selectedStains.contains(stain);
                      return FilterChip(
                        label: Text(stain),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStains.add(stain);
                            } else {
                              _selectedStains.remove(stain);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFE0F2FF),
                        checkmarkColor: const Color(0xFF0A7AFF),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0A7AFF)
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0A7AFF)
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // ✨ AQUÍ ESTÁ EL BOTÓN QUE FALTABA ✨
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoUploadScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF0A7AFF),
                      ),
                      label: const Text(
                        'Agregar fotos de los muebles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A7AFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ), // Added bottom padding to scrollable content
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: Colors.white, // Consistent background
              child: ElevatedButton(
                onPressed: _selectedDirtLevel == null
                    ? null
                    : () {
                        // ✨ CORRECCIÓN DE SINTAXIS Y DATOS ✨
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CleaningPreferencesScreen(
                              // Pasamos los datos anteriores
                              selectedService: widget.selectedService,
                              furnitureType: widget.furnitureType,
                              furnitureQuantity: widget.furnitureQuantity,
                              // Pasamos los datos nuevos de esta pantalla
                              dirtLevel: _selectedDirtLevel!,
                              stainTypes: _selectedStains,
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
                  disabledBackgroundColor: Colors.grey.shade300,
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
}
