// lib/src/features/quotation/screens/furniture_details_screen.dart
import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/dirt_level_screen.dart'; // Asegúrate de crear este archivo en el siguiente paso

class FurnitureDetailsScreen extends StatefulWidget {
  final String selectedService;

  const FurnitureDetailsScreen({super.key, required this.selectedService});

  @override
  State<FurnitureDetailsScreen> createState() => _FurnitureDetailsScreenState();
}

class _FurnitureDetailsScreenState extends State<FurnitureDetailsScreen> {
  // Aquí podrías tener una lista de objetos Mueble si el usuario agrega múltiples
  // Para simplificar, empezaremos con un solo tipo y cantidad.
  String? _selectedFurnitureType; // Ej: 'Sillón', 'Cama', 'Silla'
  int _furnitureQuantity = 1;

  final List<String> _furnitureTypes = [
    'Sillón', 'Cama', 'Silla', 'Mesa', 'Escritorio', 'Alfombra', // Ejemplos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedService), centerTitle: true),
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
                    'Indica qué muebles quieres limpiar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Paso 2 de 7',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Tipo de mueble',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedFurnitureType, // Changed from value to initialValue
                    hint: const Text('Selecciona un tipo'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _furnitureTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFurnitureType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Cantidad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Color(0xFF0A7AFF),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_furnitureQuantity > 1) {
                                      // Added curly braces
                                      _furnitureQuantity--;
                                    }
                                  });
                                },
                              ),
                              Text(
                                '$_furnitureQuantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF0A7AFF),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _furnitureQuantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidad "Agregar otro mueble" por implementar.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF0A7AFF)),
                      label: const Text(
                        'Agregar otro mueble',
                        style: TextStyle(color: Color(0xFF0A7AFF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF0A7AFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedFurnitureType == null
                      ? null // Deshabilitado si no se ha seleccionado tipo de mueble
                      : () {
                          // Navega a la siguiente pantalla (Nivel de suciedad)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DirtLevelScreen(
                                selectedService: widget
                                    .selectedService, // Pasa el servicio seleccionado
                                furnitureType: _selectedFurnitureType!,
                                furnitureQuantity: _furnitureQuantity,
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
          ),
        ],
      ),
    );
  }
}
