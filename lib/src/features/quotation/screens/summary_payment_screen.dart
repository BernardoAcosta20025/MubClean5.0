// lib/src/features/quotation/screens/summary_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mubclean/src/features/quotation/screens/booking_confirmed_screen.dart';
import '../models/quotation_model.dart';

// ✨ CAMBIO 1: Ahora es un StatefulWidget para poder cambiar el método de pago
class SummaryPaymentScreen extends StatefulWidget {
  final Quotation quotation;
  final double totalPrice;
  final DateTime selectedDate;

  const SummaryPaymentScreen({
    super.key,
    required this.quotation,
    required this.totalPrice,
    required this.selectedDate,
  });

  @override
  State<SummaryPaymentScreen> createState() => _SummaryPaymentScreenState();
}

class _SummaryPaymentScreenState extends State<SummaryPaymentScreen> {
  // ✨ CAMBIO 2: Variable para controlar el método de pago seleccionado
  // Valores posibles: 'card' o 'cash'
  String _paymentMethod = 'card'; 

  // Función para mostrar el menú de selección (Bottom Sheet)
  void _showPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal sea más alto
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Una pequeña barra gris para indicar que se puede deslizar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              
              const Text(
                'Selecciona método de pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Opción: Tarjeta
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card, color: Color(0xFF0A7AFF)),
                ),
                title: const Text('Tarjeta de Crédito/Débito', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('**** 1234'),
                trailing: _paymentMethod == 'card' 
                    ? const Icon(Icons.check_circle, color: Color(0xFF0A7AFF)) 
                    : null,
                onTap: () {
                  setState(() => _paymentMethod = 'card');
                  Navigator.pop(context); // Cierra el menú
                },
              ),
              
              const SizedBox(height: 10), // Espacio entre opciones
              
              // Opción: Efectivo
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.money, color: Colors.green),
                ),
                title: const Text('Efectivo en sitio', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Paga al finalizar el servicio'),
                trailing: _paymentMethod == 'cash' 
                    ? const Icon(Icons.check_circle, color: Color(0xFF0A7AFF)) 
                    : null,
                onTap: () {
                  setState(() => _paymentMethod = 'cash');
                  Navigator.pop(context); // Cierra el menú
                },
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para el botón "Pagar"
  void _processPayment(BuildContext context) {
    // Aquí podrías guardar en la base de datos si fue 'card' o 'cash'
    print("Procesando pago con: $_paymentMethod");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmedScreen(
          quotation: widget.quotation,
          totalPrice: widget.totalPrice,
          selectedDate: widget.selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat.yMMMMEEEEd('es_ES').format(widget.selectedDate);
    final String formattedTime = DateFormat.jm('es_ES').format(widget.selectedDate);
    
    final String furnitureSummary = widget.quotation.furnitureType.isEmpty
        ? 'Ningún mueble seleccionado'
        : [widget.quotation.furnitureType] // Wrap in a list to use map
            .map((type) => '• $type') // Directly use the furnitureType
            .join('\n'); 

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Resumen y Pago'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // --- 1. Resumen del Servicio ---
                Text(
                  'Resumen del Servicio',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSummaryCard(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSummaryColumnItem(
                            'Fecha:', 
                            formattedDate
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryColumnItem(
                            'Hora (aprox.):', 
                            formattedTime
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildSummaryColumnItem(
                      'Artículos a limpiar:', 
                      furnitureSummary
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 2. Resumen del Pago ---
                Text(
                  'Detalles del Pago',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSummaryCard(
                  children: [
                    _buildSummaryItem('Precio Base:', '\$${widget.totalPrice.toStringAsFixed(2)}'),
                    _buildSummaryItem('Tarifa de Servicio:', '\$0.00'),
                    _buildSummaryItem('Descuento:', '-\$0.00'),
                    const Divider(height: 20, thickness: 1.5),
                    _buildSummaryItem(
                      'Total a Pagar:',
                      '\$${widget.totalPrice.toStringAsFixed(2)}',
                      isTotal: true, 
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 3. Método de Pago (DINÁMICO) ---
                Text(
                  'Método de Pago',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  children: [
                    // ✨ CAMBIO 3: El contenido cambia según la selección
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono dinámico
                        Icon(
                          _paymentMethod == 'card' ? Icons.credit_card : Icons.money,
                          color: _paymentMethod == 'card' ? theme.colorScheme.primary : Colors.green, 
                          size: 28
                        ),
                        const SizedBox(width: 16),
                        
                        // Texto dinámico
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _paymentMethod == 'card' ? 'Tarjeta de Crédito' : 'Efectivo',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _paymentMethod == 'card' ? '**** 1234' : 'Pagar al finalizar',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Botón Cambiar
                        TextButton(
                          onPressed: _showPaymentMethodSelector, // Llama al menú
                          child: const Text('Cambiar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- BOTÓN DE NAVEGACIÓN ---
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF2F2F7))),
            ),
            child: ElevatedButton(
              onPressed: () => _processPayment(context),
              child: const Text('Confirmar Reserva y Pagar'),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helpers ---
Widget _buildSummaryCard({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(20), 
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// Helper Vertical (Título arriba, Valor abajo)
Widget _buildSummaryColumnItem(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 15, color: Colors.black54)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold, height: 1.4)),
    ],
  );
}

// Helper para lista de precios (Título izq, Valor der)
Widget _buildSummaryItem(String title, String value, {bool isTotal = false}) {
  final titleStyle = TextStyle(fontSize: 16, color: Colors.grey[600]);
  final valueStyle = TextStyle(fontSize: isTotal ? 24 : 20, color: Colors.black, fontWeight: FontWeight.bold);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0), 
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Expanded(flex: 2, child: Text(title, style: titleStyle)),
        const SizedBox(width: 8),
        Expanded(flex: 1, child: Text(value, style: valueStyle, textAlign: TextAlign.right)),
      ],
    ),
  );
}
