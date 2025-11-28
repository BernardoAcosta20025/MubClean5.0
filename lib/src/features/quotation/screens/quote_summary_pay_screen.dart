import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para los formateadores de texto
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/src/features/quotation/screens/booking_confirmed_screen.dart';

class QuoteSummaryPayScreen extends StatefulWidget {
  final String bookingId;

  const QuoteSummaryPayScreen({super.key, required this.bookingId});

  @override
  State<QuoteSummaryPayScreen> createState() => _QuoteSummaryPayScreenState();
}

class _QuoteSummaryPayScreenState extends State<QuoteSummaryPayScreen> {
  final _formKey = GlobalKey<FormState>(); // Para validar el formulario
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  Map<String, dynamic>? _bookingData;

  // Controladores de texto para la tarjeta
  final _cardNumberCtrl = TextEditingController();
  final _expiryDateCtrl = TextEditingController(); // MM/AA
  final _cvvCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  // 1. Obtener los datos REALES de la cotización desde Supabase
  Future<void> _fetchBookingDetails() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('bookings')
          .select('*, booking_items(*)') // Traemos info y los muebles
          .eq('id', widget.bookingId)
          .single();

      setState(() {
        _bookingData = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error cargando: $e")));
        Navigator.pop(context);
      }
    }
  }

  // 2. Procesar el Pago (Simulado + Actualización de BD)
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate())
      return; // Si hay errores en el form, no sigue

    setState(() => _isProcessingPayment = true);

    // Simulamos tiempo de red bancaria
    await Future.delayed(const Duration(seconds: 2));

    final supabase = Supabase.instance.client;

    try {
      // Actualizamos el estado a PAGADO
      await supabase
          .from('bookings')
          .update({
            'status': 'scheduled', // Ya está agendado
            'payment_status': 'paid',
            'payment_method': 'credit_card',
          })
          .eq('id', widget.bookingId);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error en el pago: $e")));
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mubBlue = Color(0xFF0A7AFF);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = _bookingData?['total_price'] ?? 0.0;
    final items = _bookingData?['booking_items'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text("Pagar Servicio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          // Envolvemos en Form para validar
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. RESUMEN DE LA COTIZACIÓN ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resumen del Servicio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Dirección: ${_bookingData?['address_street']}"),
                    Text("Fecha: ${_bookingData?['scheduled_date']}"),
                    const Divider(),
                    const Text(
                      "Detalle:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...items.map(
                      (item) => Text(
                        "• ${item['quantity']}x ${item['item_name']} (${item['attributes']['size']})",
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total a Pagar:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "\$${total.toString()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: mubBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Datos de la Tarjeta",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // --- 2. NÚMERO DE TARJETA (16 Dígitos) ---
              TextFormField(
                controller: _cardNumberCtrl,
                keyboardType: TextInputType.number,
                maxLength: 16, // Limita a 16 caracteres visualmente
                decoration: const InputDecoration(
                  labelText: "Número de Tarjeta",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                  counterText: "", // Oculta el contador 0/16
                ),
                // Validadores estrictos
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return "Requerido";
                  if (value.length != 16)
                    return "Debe tener 16 dígitos exactos";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 3. NOMBRE TITULAR ---
              TextFormField(
                controller: _holderNameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre del Titular",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? "Ingresa el nombre" : null,
              ),
              const SizedBox(height: 15),

              // --- 4. FECHA (MM/AA) y CVV ---
              Row(
                children: [
                  // FECHA (4 Dígitos)
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 5, // MM/AA son 5 caracteres contando la barra
                      decoration: const InputDecoration(
                        labelText: "Vencimiento (MM/AA)",
                        hintText: "MM/AA",
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Requerido";
                        // Regex para validar formato MM/AA
                        if (!RegExp(
                          r'^(0[1-9]|1[0-2])\/([0-9]{2})$',
                        ).hasMatch(value)) {
                          return "Formato inválido (Use MM/AA)";
                        }
                        return null;
                      },
                      // Formateador automático para poner la barra /
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                        LengthLimitingTextInputFormatter(5),
                        _ExpiryDateFormatter(), // Formateador personalizado abajo
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),

                  // CVV (3 o 4 Dígitos)
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: "CVV",
                        border: OutlineInputBorder(),
                        counterText: "",
                        suffixIcon: Icon(Icons.lock, size: 18),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Requerido";
                        if (value.length < 3 || value.length > 4) {
                          return "3 o 4 dígitos";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- 5. BOTÓN PAGAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mubBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessingPayment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Pagar \$${total.toString()}",
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
      ),
    );
  }
}

// Clase extra para poner la "/" automáticamente en la fecha
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
