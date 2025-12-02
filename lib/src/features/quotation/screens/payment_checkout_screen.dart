import 'dart:io';
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

  // --- FUNCIÓN SOLICITAR COTIZACIÓN ---
  Future<void> _solicitarCotizacion() async {
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
      // 1. GUARDAR LA SOLICITUD
      final bookingResponse = await supabase
          .from('bookings')
          .insert({
            'user_id': user.id,
            'status': 'pending_quote',
            'payment_status': 'unpaid',
            'total_price': widget.totalToPay,
            'payment_method': null,
            'transaction_id': null,
            'scheduled_date': widget.serviceDate.toIso8601String().split(
              'T',
            )[0],
            'scheduled_time': widget.serviceTime,
            'address_street': widget.address,
            'receiver_name': widget.receiverName,
          })
          .select()
          .single();

      final bookingId = bookingResponse['id'];

      // 2. PREPARAR LOS MUEBLES Y FOTOS
      List<Map<String, dynamic>> itemsParaInsertar = [];
      List<Map<String, dynamic>> evidenciasParaInsertar = [];

      for (var mueble in widget.furnitureItems) {
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

        if (mueble['photos'] != null && (mueble['photos'] as List).isNotEmpty) {
          List<String> rutasFotos = mueble['photos'];

          for (String rutaLocal in rutasFotos) {
            final file = File(rutaLocal);
            final fileExt = rutaLocal.split('.').last;
            final fileName =
                '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${itemsParaInsertar.length}.$fileExt';

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

            final imageUrl = supabase.storage
                .from('evidence')
                .getPublicUrl(fileName);

            evidenciasParaInsertar.add({
              'booking_id': bookingId,
              'photo_url': imageUrl,
              'description': 'Evidencia de ${mueble['type']}',
            });
          }
        }
      }

      // 3. INSERTAR EN TABLAS HIJAS
      if (itemsParaInsertar.isNotEmpty) {
        await supabase.from('booking_items').insert(itemsParaInsertar);
      }
      if (evidenciasParaInsertar.isNotEmpty) {
        await supabase.from('booking_evidence').insert(evidenciasParaInsertar);
      }

      // 4. ÉXITO -> IR A PANTALLA DE ESPERA
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingConfirmedScreen(),
          ),
          // ✨ AQUÍ ESTÁ EL CAMBIO IMPORTANTE:
          // Usamos 'route.isFirst' para NO borrar la pantalla de Inicio (Home)
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al solicitar: $e"),
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
      appBar: AppBar(title: const Text("Confirmar Solicitud")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Resumen de la Solicitud",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Revisa los detalles antes de enviarlos al técnico para cotización.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 4,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      _rowInfo(
                        Icons.cleaning_services,
                        "Servicio",
                        widget.selectedService,
                      ),
                      const SizedBox(height: 10),
                      _rowInfo(
                        Icons.calendar_month,
                        "Fecha Solicitada",
                        "$dateStr\n${widget.serviceTime}",
                      ),
                      const SizedBox(height: 10),
                      _rowInfo(Icons.location_on, "Dirección", widget.address),
                      const SizedBox(height: 10),
                      _rowInfo(Icons.person, "Recibe", widget.receiverName),
                      const Divider(height: 30, thickness: 1),
                      const Text(
                        "Detalle de Muebles:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...widget.furnitureItems.map(
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "• ${i['quantity']}x ${i['type']} (${i['size']}) - ${i['material']}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _solicitarCotizacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar Solicitud de Cotización",
                        style: TextStyle(
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
        Icon(icon, size: 20, color: Colors.blue[800]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
