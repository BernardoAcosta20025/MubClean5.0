import 'dart:io'; // Necesario para manejar los archivos de las fotos
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:mubclean/src/features/quotation/screens/location_map_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  // Datos que vienen de la pantalla anterior
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
  // Lista para guardar las fotos tomadas
  final List<XFile> _takenPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxPhotos = 5; 

  // Función para abrir la cámara
  Future<void> _takePhoto() async {
    if (_takenPhotos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ya has tomado el máximo de 5 fotos.")));
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Optimizar tamaño para subir más rápido a Supabase
      );

      if (photo != null) {
        setState(() {
          _takenPhotos.add(photo);
        });
      }
    } catch (e) {
       debugPrint("Error al tomar foto: $e");
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir la cámara.")));
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
    bool canContinue = _takenPhotos.isNotEmpty;

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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Evidencia Fotográfica del Mueble",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                      children: const [
                        TextSpan(text: "Las fotos nos permiten evaluar con precisión el estado de tu mueble.\n\n"),
                        TextSpan(
                          text: "📸 Recomendación: ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: mubBlue),
                        ),
                        TextSpan(text: "Toma fotos de la zona más afectada."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. BOTÓN GIGANTE DE CÁMARA
                  Center(
                    child: GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: mubBlue.withAlpha(77), width: 4),
                          boxShadow: [
                            BoxShadow(color: mubBlue.withAlpha(51), blurRadius: 20, spreadRadius: 5)
                          ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: mubBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Abrir Cámara",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mubBlue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. CARRUSEL DE FOTOS
                  Text(
                    "Fotos tomadas: ${_takenPhotos.length}/$_maxPhotos (Mínimo 1 requerida)",
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _maxPhotos,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index < _takenPhotos.length) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_takenPhotos[index].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        } else {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(child: Icon(Icons.add_a_photo, color: Colors.grey[400])),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // 4. BARRA INFERIOR MODIFICADA (SIN PRECIO, SOLO BOTÓN)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            // Usamos SizedBox con width infinity para que el botón ocupe todo el ancho
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canContinue ? () {
                  // --- LÓGICA VITAL PARA GUARDAR FOTOS ---
                  
                  // 1. Convertimos las fotos a una lista de rutas (Strings)
                  List<String> rutasDeFotos = _takenPhotos.map((foto) => foto.path).toList();

                  // 2. Guardamos las fotos en el ÚLTIMO mueble añadido
                  if (widget.furnitureItems.isNotEmpty) {
                    widget.furnitureItems.last['photos'] = rutasDeFotos;
                  }

                  // 3. Pasamos la lista YA ACTUALIZADA al mapa
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
                  padding: const EdgeInsets.symmetric(vertical: 16), // Más alto para que se vea bien
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  "Continuar", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}