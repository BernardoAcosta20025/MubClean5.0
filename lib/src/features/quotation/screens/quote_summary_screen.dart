import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/src/features/quotation/screens/payment_form_screen.dart'; // Siguiente paso

class QuoteSummaryScreen extends StatefulWidget {
  final String bookingId;
  const QuoteSummaryScreen({super.key, required this.bookingId});

  @override
  State<QuoteSummaryScreen> createState() => _QuoteSummaryScreenState();
}

class _QuoteSummaryScreenState extends State<QuoteSummaryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('bookings')
          .select('*, booking_items(*)')
          .eq('id', widget.bookingId)
          .single();
      setState(() {
        _bookingData = response;
        _isLoading = false;
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _bookingData?['total_price'] ?? 0.0;
    final items = _bookingData?['booking_items'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text("Resumen de Cotización")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      const Text("Detalle del Servicio", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      _infoRow("Fecha:", "${_bookingData?['scheduled_date']}"),
                      _infoRow("Hora:", "${_bookingData?['scheduled_time']}"),
                      _infoRow("Dirección:", "${_bookingData?['address_street']}"),
                      const SizedBox(height: 20),
                      const Text("Muebles:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...items.map((i) => Text("• ${i['quantity']}x ${i['item_name']} (${i['attributes']['size']})")),
                      const Divider(height: 40, thickness: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total a Pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("\$$total", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A7AFF))),
                        ],
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
                onPressed: () {
                  // IR AL FORMULARIO DE PAGO
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentFormScreen(
                        bookingId: widget.bookingId,
                        totalAmount: total.toDouble(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A7AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Continuar al Pago", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}