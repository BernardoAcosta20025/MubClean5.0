import 'dart:io'; // <--- NUEVO: OBLIGATORIO PARA LEER LAS FOTOS
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/src/features/quotation/screens/booking_confirmed_screen.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String selectedService;
  final List<Map<String, dynamic>> furnitureItems;
  final String address;
  final String receiverName;
  final double totalToPay;
  final DateTime serviceDate;
  final String serviceTime;

  const PaymentCheckoutScreen({
    super.key,
    required this.selectedService,
    required this.furnitureItems,
    required this.address,
    required this.receiverName,
    required this.totalToPay,
    required this.serviceDate,
    required this.serviceTime,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  bool _isLoading = false;

  // --- FUNCIÓN QUE GUARDA EN LA BASE DE DATOS Y SUBE FOTOS ---
  Future<void> _procesarPagoYGuardar() async {
    setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No has iniciado sesión")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. GUARDAR LA RESERVA PRINCIPAL (Tabla bookings)
      final bookingResponse = await supabase
          .from('bookings')
          .insert({
            'user_id': user.id,
            'status': 'confirmed',
            'payment_status': 'paid',
            'total_price': widget.totalToPay,
            'payment_method': 'card',
            'transaction_id': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
            'scheduled_date': widget.serviceDate.toIso8601String().split(
              'T',
            )[0],
            'scheduled_time': widget.serviceTime,
            'address_street': widget.address,
            'receiver_name': widget.receiverName,
          })
          .select()
          .single();

      final bookingId = bookingResponse['id']; // Tenemos el ID de la reserva

      // 2. PREPARAR LOS MUEBLES Y LAS FOTOS
      List<Map<String, dynamic>> itemsParaInsertar = [];
      List<Map<String, dynamic>> evidenciasParaInsertar =
          []; // <--- NUEVO: Lista para fotos

      for (var mueble in widget.furnitureItems) {
        // A) Preparamos el mueble (Texto)
        itemsParaInsertar.add({
          'booking_id': bookingId,
          'item_name': mueble['type'] ?? 'Mueble',
          'quantity': mueble['quantity'] ?? 1,
          'unit_price': mueble['price'] ?? 0,
          'attributes': {
            'size': mueble['size'],
            'material': mueble['material'],
            'dirt_level': mueble['dirt_level'],
          },
          'stains': mueble['stains'] ?? [],
        });

        // B) LOGICA DE FOTOS (Lo que faltaba)
        // Verificamos si este mueble trae fotos
        if (mueble['photos'] != null && (mueble['photos'] as List).isNotEmpty) {
          List<String> rutasFotos = mueble['photos'];

          for (String rutaLocal in rutasFotos) {
            final file = File(rutaLocal);
            // Creamos un nombre único para el archivo en la nube
            final fileExt = rutaLocal.split('.').last;
            final fileName =
                '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${itemsParaInsertar.length}.$fileExt';

            // 1. Subir el archivo al Bucket 'evidence'
            await supabase.storage
                .from('evidence')
                .upload(
                  fileName,
                  file,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );

            // 2. Obtener el Link Público
            final imageUrl = supabase.storage
                .from('evidence')
                .getPublicUrl(fileName);

            // 3. Guardar en la lista para insertar en la BD
            evidenciasParaInsertar.add({
              'booking_id': bookingId,
              'photo_url': imageUrl,
              'description': 'Evidencia de ${mueble['type']}',
            });
          }
        }
      }

      // 3. INSERTAR TODO EN LA BASE DE DATOS

      // Insertamos los muebles
      if (itemsParaInsertar.isNotEmpty) {
        await supabase.from('booking_items').insert(itemsParaInsertar);
      }

      // Insertamos las evidencias (links de fotos) <--- NUEVO
      if (evidenciasParaInsertar.isNotEmpty) {
        await supabase.from('booking_evidence').insert(evidenciasParaInsertar);
      }

      // 4. ÉXITO
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingConfirmedScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error Supabase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al procesar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMMEEEEd('es_ES').format(widget.serviceDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Resumen y Pago")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESUMEN COMPLETO
            Card(
              elevation: 0,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowInfo(
                      Icons.cleaning_services,
                      "Servicio",
                      widget.selectedService,
                    ),
                    const SizedBox(height: 5),
                    _rowInfo(
                      Icons.calendar_month,
                      "Fecha",
                      "$dateStr - ${widget.serviceTime}",
                    ),
                    const SizedBox(height: 5),
                    _rowInfo(Icons.location_on, "Dirección", widget.address),
                    const SizedBox(height: 5),
                    _rowInfo(Icons.person, "Recibe", widget.receiverName),
                    const Divider(),
                    const Text(
                      "Muebles:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...widget.furnitureItems.map(
                      (i) => Text(
                        "• ${i['quantity']}x ${i['type']} (${i['size']}) - \$${i['price']}",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TARJETA
            const Text(
              "Pago con Tarjeta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: "Número de Tarjeta",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "MM/AA",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // BOTÓN DE PAGAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _procesarPagoYGuardar();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.blue.shade200,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Pagar \$${widget.totalToPay.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
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

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue[800]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
