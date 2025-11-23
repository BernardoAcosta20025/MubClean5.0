import 'package:flutter/material.dart';
import 'package:mubclean/src/features/quotation/screens/photo_upload_screen.dart';

class FurnitureDetailsScreen extends StatefulWidget {
  final String selectedService;
  const FurnitureDetailsScreen({super.key, required this.selectedService});

  @override
  State<FurnitureDetailsScreen> createState() => _FurnitureDetailsScreenState();
}

class _FurnitureDetailsScreenState extends State<FurnitureDetailsScreen> {
  // Lista de muebles ya configurados (Las tarjetas que se van apilando)
  final List<Map<String, dynamic>> _addedItems = [];

  // --- Estado del Formulario (Lo que el usuario está editando ahora) ---
  String? _currentType; // ✨ MODIFICADO: Ahora puede ser nulo al inicio para cargarlo dinámicamente
  String _currentSize = 'Mediano';
  String _currentMaterial = 'Tela';
  String _currentDirtLevel = 'Medio';
  final List<String> _currentStains = [];
  int _quantity = 1;

  // ✨ NUEVO: Mapa para filtrar tipos de muebles según el servicio
  final Map<String, List<String>> _furnitureOptionsByService = {
    'Limpieza de Sala': ['Sofá 2 plazas', 'Sofá 3 plazas', 'Sofá en L', 'Sillón Individual', 'Silla de Comedor', 'Puf', 'Love Seat'],
    'Limpieza de Alfombras': ['Alfombra de Área', 'Tapete Chico', 'Tapete Grande', 'Alfombra Fija (m2)', 'Tapete de Entrada'],
    'Limpieza de Colchones': ['Colchón Individual', 'Colchón Matrimonial', 'Colchón Queen', 'Colchón King Size', 'Cuna de Bebé'],
    'Limpieza General': ['Silla de Oficina', 'Cortinas', 'Interior de Auto', 'Carriola de Bebé', 'Mueble Genérico'],
  };

  // ✨ NUEVO: Getter para obtener la lista filtrada
  List<String> get _currentFurnitureTypes {
    return _furnitureOptionsByService[widget.selectedService] ?? 
           ['Mueble Genérico', 'Otro'];
  }

  // Datos Base (Precios actualizados para cubrir las nuevas opciones)
  final Map<String, double> _basePrices = {
    'Sofá 2 plazas': 600.0, 'Sofá 3 plazas': 850.0, 'Sofá en L': 1200.0, 'Sillón Individual': 350.0,
    'Alfombra de Área': 400.0, 'Tapete Chico': 200.0, 'Alfombra Fija (m2)': 80.0,
    'Colchón Individual': 400.0, 'Colchón Matrimonial': 600.0, 'Colchón King Size': 900.0,
  };
  
  final List<String> _sizes = ['Chico', 'Mediano', 'Grande'];
  final List<String> _materials = ['Tela', 'Piel/Cuero', 'Sintético', 'Terciopelo'];
  final List<String> _dirtLevels = ['Bajo', 'Medio', 'Alto'];
  final List<String> _stainOptions = ['Comida', 'Bebida', 'Mascota', 'Grasa', 'Tinta'];

  @override
  void initState() {
    super.initState();
    // ✨ MODIFICADO: Inicializar el tipo con el primero de la lista FILTRADA
    if (_currentFurnitureTypes.isNotEmpty) {
      _currentType = _currentFurnitureTypes.first;
    } else {
      _currentType = 'Otro';
    }
  }

  // Cálculo de precio (Lógica interna)
  double get _currentItemPrice {
    // Busca precio base o usa 300 por defecto
    double base = _basePrices[_currentType] ?? 300.0;
    
    if (_currentSize == 'Grande') base += 100;
    if (_currentDirtLevel == 'Alto') base += 100;
    return base * _quantity;
  }

  double get _totalCartPrice {
    return _addedItems.fold(0, (sum, item) => sum + (item['price'] as double));
  }

  void _addItemToOrder() {
    if (_currentType == null) return; // Seguridad

    setState(() {
      _addedItems.add({
        'type': _currentType!,
        'size': _currentSize,
        'material': _currentMaterial,
        'dirt': _currentDirtLevel,
        'stains': List<String>.from(_currentStains),
        'quantity': _quantity,
        'price': _currentItemPrice,
      });
      // Reseteamos el formulario
      _quantity = 1;
      _currentStains.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mubBlue = Color(0xFF0A7AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Personaliza tus Muebles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Área de Scroll (Lista de items + Formulario)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 1. LISTA DE ÍTEMS YA AGREGADOS
                  if (_addedItems.isNotEmpty) ...[
                    const Text('Lista de Ítems:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 10),
                    
                    Column(
                      children: _addedItems.map((item) => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Encabezado de la tarjeta
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // ✨ MODIFICADO: Flexible + Overflow para el título
                                  Flexible(
                                    child: Text(
                                      "${item['quantity']}x ${item['type']}", 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis, // Corta con "..."
                                      maxLines: 1,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => setState(() => _addedItems.remove(item)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const Divider(),
                              
                              // Detalles del ítem
                              // ✨ MODIFICADO: Overflow para los detalles
                              Text("Tamaño: ${item['size']}", overflow: TextOverflow.ellipsis),
                              Text("Material: ${item['material']}", overflow: TextOverflow.ellipsis),
                              Text("Suciedad: ${item['dirt']}", overflow: TextOverflow.ellipsis),
                              
                              if ((item['stains'] as List).isNotEmpty)
                                Text(
                                  "Manchas: ${(item['stains'] as List).join(', ')}", 
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis, // Corta lista larga de manchas
                                  maxLines: 2,
                                ),
                              
                              const SizedBox(height: 5),
                              Text("\$${item['price'].toStringAsFixed(0)}", style: TextStyle(color: mubBlue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 2. FORMULARIO "Configurar Nuevo Mueble"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Configurar Nuevo Mueble", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 30),

                        // TIPO DE MUEBLE
                        _buildLabel("Tipo de Mueble"),
                        DropdownButtonFormField<String>(
                          value: _currentType,
                          isExpanded: true,
                          decoration: _inputDecoration(),
                          // ✨ MODIFICADO: Usamos _currentFurnitureTypes (la lista filtrada)
                          items: _currentFurnitureTypes.map((t) => DropdownMenuItem(
                            value: t, 
                            child: Text(
                              t, 
                              overflow: TextOverflow.ellipsis // Protege el dropdown también
                            )
                          )).toList(),
                          onChanged: (v) => setState(() => _currentType = v!),
                        ),
                        const SizedBox(height: 20),

                        // TAMAÑO
                        _buildLabel("Tamaño"),
                        Wrap(
                          spacing: 10,
                          children: _sizes.map((s) => ChoiceChip(
                            label: Text(s),
                            selected: _currentSize == s,
                            onSelected: (v) => setState(() => _currentSize = s),
                            selectedColor: const Color(0xFFE0F2FF),
                            labelStyle: TextStyle(color: _currentSize == s ? mubBlue : Colors.black),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),

                        // MATERIAL
                        _buildLabel("Material"),
                        DropdownButtonFormField<String>(
                          value: _currentMaterial,
                          isExpanded: true,
                          decoration: _inputDecoration(),
                          items: _materials.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (v) => setState(() => _currentMaterial = v!),
                        ),
                        const SizedBox(height: 20),

                        // NIVEL DE SUCIEDAD
                        _buildLabel("Nivel de Suciedad"),
                        Row(
                          children: _dirtLevels.map((d) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () => setState(() => _currentDirtLevel = d),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _currentDirtLevel == d ? mubBlue : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _currentDirtLevel == d ? mubBlue : Colors.grey.shade300),
                                  ),
                                  child: Text(d, style: TextStyle(color: _currentDirtLevel == d ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),

                        // MANCHAS
                        _buildLabel("¿Tiene Manchas Específicas?"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _stainOptions.map((s) => FilterChip(
                            label: Text(s),
                            selected: _currentStains.contains(s),
                            onSelected: (sel) => setState(() {
                              sel ? _currentStains.add(s) : _currentStains.remove(s);
                            }),
                            selectedColor: const Color(0xFFE0F2FF),
                            checkmarkColor: mubBlue,
                          )).toList(),
                        ),
                        const SizedBox(height: 25),

                        // CANTIDAD Y BOTÓN "AGREGAR OTRO"
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null)),
                                  Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add, color: mubBlue), onPressed: () => setState(() => _quantity++)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addItemToOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: mubBlue,
                                  side: const BorderSide(color: mubBlue),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("+ Agregar otro mueble", textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20), // Espacio extra abajo
                ],
              ),
            ),
          ),

          // FOOTER FIJO
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Total Estimado:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("\$${_totalCartPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addedItems.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoUploadScreen(
                          selectedService: widget.selectedService,
                          furnitureItems: _addedItems,
                          itemsTotal: _totalCartPrice,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mubBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Continuar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}