import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quotation_model.dart';
// ELIMINADO: import 'photo_upload_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final Quotation quotation;
  final double totalPrice;
  final DateTime selectedDate;

  const BookingConfirmedScreen({
    super.key,
    required this.quotation,
    required this.totalPrice,
    required this.selectedDate,
  });

  // ELIMINADO: Función _goToPhotoUpload

  // Función para volver al inicio
  void _goToHome(BuildContext context) {
    // Esto saca todas las pantallas de cotización y te deja en el Home
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat.yMMMMEEEEd(
      'es_ES',
    ).format(selectedDate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('¡Reserva Confirmada!'),
        automaticallyImplyLeading: false, // Oculta la flecha de "atrás"
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: Center(
        // Padding ajustado
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de Éxito
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                // Mensaje de confirmación
                Text(
                  '¡Tu reserva está confirmada!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hemos recibido tu pago y agendado tu servicio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Mini-Resumen ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Fecha del Servicio:',
                        value: formattedDate,
                      ),
                      const Divider(height: 20),
                      _buildSummaryRow(
                        context,
                        icon: Icons.receipt_long,
                        title: 'Total Pagado:',
                        value: '\$${totalPrice.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ELIMINADO: Botón de "Subir Fotos Ahora"

                // --- Botón de Volver al Inicio ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Volver al Inicio',
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
        ),
      ),
    );
  }

  // Helper corregido (Vertical Layout para evitar overflow)
  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        // Título
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
            softWrap: true,
          ),
        ),
        const SizedBox(width: 16),
        // Valor (Expanded para evitar overflow)
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
