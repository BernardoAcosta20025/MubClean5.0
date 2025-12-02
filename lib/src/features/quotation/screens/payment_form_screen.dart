import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mubclean/src/features/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mubclean/src/features/quotation/screens/booking_confirmed_screen.dart'; // Reutilizamos tu pantalla de éxito (o creamos una nueva)

class PaymentFormScreen extends StatefulWidget {
  final String bookingId;
  final double totalAmount;

  const PaymentFormScreen({
    super.key,
    required this.bookingId,
    required this.totalAmount,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simular banco

    try {
      await Supabase.instance.client
          .from('bookings')
          .update({
            'status': 'scheduled',
            'payment_status': 'paid',
            'payment_method': 'card',
          })
          .eq('id', widget.bookingId);

      if (mounted) {
        // IR A PANTALLA FINAL
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentSuccessScreen(),
          ), // Nueva pantalla abajo
          (route) => false,
        );
      }
    } catch (e) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Método de Pago")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total a pagar: \$${widget.totalAmount}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // TARJETA (16 DÍGITOS)
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: "Número de Tarjeta",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                  counterText: "",
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    (v?.length != 16) ? "Debe tener 16 dígitos" : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // FECHA (MM/AA)
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      decoration: const InputDecoration(
                        labelText: "Vencimiento (MM/AA)",
                        hintText: "12/25",
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      validator: (v) {
                        if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v))
                          return "Usar formato MM/AA";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // CVV (3-4 DÍGITOS)
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: "CVV",
                        border: OutlineInputBorder(),
                        counterText: "",
                        suffixIcon: Icon(Icons.lock_outline),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          (v!.length < 3) ? "Mínimo 3 dígitos" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A7AFF),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "PAGAR AHORA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

// Pantalla Final Sencilla
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "¡Pago Exitoso!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Tu servicio ha sido agendado."),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: const Text("Volver al Inicio"),
            ),
          ],
        ),
      ),
    );
  }
}
