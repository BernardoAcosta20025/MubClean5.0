import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/details_price_screen.dart';
import 'package:mubclean/src/features/quotation/models/quotation_model.dart'; // Asegúrate de tener este import

class LocationAccessScreen extends StatefulWidget {
  final String selectedService;
  final String furnitureType;
  final int furnitureQuantity;
  final String dirtLevel;
  final List<String> stainTypes;
  final bool petFriendly;
  final bool ecoFriendly;
  final String notes;

  const LocationAccessScreen({
    super.key,
    required this.selectedService,
    required this.furnitureType,
    required this.furnitureQuantity,
    required this.dirtLevel,
    required this.stainTypes,
    required this.petFriendly,
    required this.ecoFriendly,
    required this.notes,
  });

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación'),
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
              'Dirección del servicio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Paso 5 de 7',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Dirección completa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Calle, Número, Colonia, CP',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                      ),
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
                  const SizedBox(height: 24),
                  const Text(
                    'Instrucciones de acceso (Opcional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ej: Tocar el timbre 3B, portón negro...',
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Se ensambla el objeto de cotización final con TODOS los datos recopilados
                  final quotation = Quotation(
                    selectedService: widget.selectedService,
                    furnitureType: widget.furnitureType,
                    furnitureQuantity: widget.furnitureQuantity,
                    dirtLevel: widget.dirtLevel,
                    stainTypes: widget.stainTypes,
                    petFriendly: widget.petFriendly,
                    ecoFriendly: widget.ecoFriendly,
                    notes: widget.notes,
                    address: _addressController.text,
                    accessInstructions: _instructionsController.text,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailsPriceScreen(quotation: quotation),
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
                  'Ver Resumen y Precio',
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
}
