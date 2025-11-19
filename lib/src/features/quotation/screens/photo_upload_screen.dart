import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final Map<String, XFile?> _images = {
    'Frente': null,
    'Atrás': null,
    'Lado izquierdo': null,
    'Lado derecho': null,
    'Zona Afectada': null,
  };

  final ImagePicker _picker = ImagePicker();
  bool _isConfirmButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkConfirmationEligibility();
  }

  Future<void> _pickImage(String type) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _images[type] = pickedFile;
          _checkConfirmationEligibility();
        });
      }
    }
  }

  void _checkConfirmationEligibility() {
    setState(() {
      _isConfirmButtonEnabled = _images['Zona Afectada'] != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotos del mueble'),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toma o sube fotos de tu mueble para revisar mejor su estado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildPhotoCard('Frente', 'Frente', Icons.camera_alt),
                        _buildPhotoCard('Atrás', 'Atrás', Icons.camera_alt),
                        _buildPhotoCard('Zona Afectada', 'Zona Afectada', Icons.warning),
                        _buildPhotoCard('Lado izquierdo', 'Lado izquierdo', Icons.camera_alt),
                        _buildPhotoCard('Lado derecho', 'Lado derecho', Icons.camera_alt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Las fotos nos ayudarán a evaluar mejor la suciedad, el material y los detalles del mueble antes del servicio.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: _isConfirmButtonEnabled
                    ? () {
                        // TODO: Implement navigation and pass image data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Fotos confirmadas (Navegar)'),),
                        );
                        Navigator.pop(context); // For demonstration
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'Confirmar fotos',
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

  Widget _buildPhotoCard(String type, String title, IconData icon) {
    final bool hasImage = _images[type] != null;
    final bool isAffectedArea = type == 'Zona Afectada';

    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAffectedArea
                ? Colors.red.shade400
                : (hasImage ? const Color(0xFF0A7AFF) : Colors.grey.shade300),
            width: isAffectedArea ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_images[type]!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}