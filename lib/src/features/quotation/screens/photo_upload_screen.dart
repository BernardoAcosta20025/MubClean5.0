import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mubclean/src/features/quotation/screens/location_map_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  final String selectedService;
  final List<Map<String, dynamic>> furnitureItems;
  final double itemsTotal;

  const PhotoUploadScreen({
    super.key,
    required this.selectedService,
    required this.furnitureItems,
    required this.itemsTotal,
  });

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final List<XFile> _takenPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxPhotos = 4; 

  Future<void> _takePhoto() async {
    if (_takenPhotos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Límite de fotos alcanzado (Máx 4).")));
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _takenPhotos.add(photo);
        });
      }
    } catch (e) {
      debugPrint("Error cámara: $e");
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _takenPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mubBlue = Color(0xFF0A7AFF);
    bool hasPhotos = _takenPhotos.isNotEmpty;
    bool isFull = _takenPhotos.length >= _maxPhotos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Evidencia Fotográfica'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Fotos del Mueble",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Toma fotos claras de las zonas afectadas.",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 1. BOTÓN GIGANTE (SIEMPRE VISIBLE) ---
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: isFull ? Colors.grey[200] : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFull ? Colors.grey : mubBlue.withOpacity(0.5), 
                          width: 4
                        ),
                        boxShadow: [
                          if (!isFull)
                            BoxShadow(color: mubBlue.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isFull ? Colors.grey : mubBlue, 
                              shape: BoxShape.circle
                            ),
                            child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isFull ? "Límite\nAlcanzado" : "Tomar Foto",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: isFull ? Colors.grey : mubBlue
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- 2. LAS FOTOS APARECEN AQUÍ ABAJO ---
                  if (hasPhotos) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Capturas (${_takenPhotos.length}/$_maxPhotos):",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Grid de fotos
                    GridView.builder(
                      shrinkWrap: true, // Importante para que funcione dentro del Scroll
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 fotos por fila
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1, // Cuadradas
                      ),
                      itemCount: _takenPhotos.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(_takenPhotos[index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Botón borrar
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // BARRA INFERIOR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: hasPhotos ? () {
                  // Guardar fotos y navegar
                  List<String> rutasDeFotos = _takenPhotos.map((f) => f.path).toList();
                  if (widget.furnitureItems.isNotEmpty) {
                    widget.furnitureItems.last['photos'] = rutasDeFotos;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationMapScreen(
                        selectedService: widget.selectedService,
                        furnitureItems: widget.furnitureItems,
                        itemsTotal: widget.itemsTotal,
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mubBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text("Continuar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}