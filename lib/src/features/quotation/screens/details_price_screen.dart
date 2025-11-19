// lib/src/features/quotation/screens/details_price_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/quotation_model.dart';
import 'summary_payment_screen.dart';

class DetailsPriceScreen extends StatefulWidget {
  final Quotation quotation;
  const DetailsPriceScreen({super.key, required this.quotation});
  @override
  State<DetailsPriceScreen> createState() => _DetailsPriceScreenState();
}

class _DetailsPriceScreenState extends State<DetailsPriceScreen> {
  // --- Lógica de negocio de Precios ---
  static const Map<String, double> _basePrices = {
    'Sillón': 500.0,
    'Cama': 600.0,
    'Silla': 100.0,
    'Mesa': 200.0,
    'Escritorio': 250.0,
    'Alfombra': 350.0,
  };
  static const double _minimumCharge = 400.0;
  late double _totalPrice;

  // --- Estado de selección de Fecha y Hora ---
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  DateTime _focusedDay = DateTime.now();
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    double calculatedPrice =
        _basePrices[widget.quotation.furnitureType] ?? 150.0;
    calculatedPrice *= widget.quotation.furnitureQuantity;

    // Multiplicador por nivel de suciedad
    switch (widget.quotation.dirtLevel) {
      case 'Medio':
        calculatedPrice *= 1.25;
        break;
      case 'Alto':
        calculatedPrice *= 1.5;
        break;
    }

    // Costos adicionales por preferencias
    if (widget.quotation.petFriendly) calculatedPrice += 50.0;
    if (widget.quotation.ecoFriendly) calculatedPrice += 50.0;

    // Aplicar cargo mínimo si es necesario
    if (calculatedPrice < _minimumCharge) {
      _totalPrice = _minimumCharge;
    } else {
      _totalPrice = calculatedPrice;
    }
  }

  void _goToSummary() {
    // Aquí se deberían pasar los datos finales a la pantalla de pago/resumen
    // La pantalla `SummaryPaymentScreen` también necesitaría ser actualizada
    // para aceptar el nuevo modelo de Quotation.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPaymentScreen(
          quotation: widget.quotation,
          totalPrice: _totalPrice,
          selectedDate: DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
            int.parse(_selectedTimeSlot!.split(':')[0]),
            int.parse(_selectedTimeSlot!.split(':')[1].split(' ')[0]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSelectionComplete =
        _selectedDay != null && _selectedTimeSlot != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detalles y Agenda'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildQuotationSummary(), // NUEVO: Resumen de la cotización
                const SizedBox(height: 30),

                // --- SECCIÓN DE PRECIO ---
                Text(
                  'Precio Estimado',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total a pagar',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A7AFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'El precio final puede variar ligeramente según la evaluación de las fotos que subas (paso no implementado).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- SECCIÓN DE AGENDA ---
                Text(
                  '1. Selecciona el Día',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (day, focused) => setState(() {
                      _selectedDay = day;
                      _focusedDay = focused;
                      _selectedTimeSlot = null;
                    }),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFF0A7AFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  '2. Selecciona la Hora',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimeSlots(),
                const SizedBox(height: 30),
                _buildSummaryBlock(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF2F2F7))),
            ),
            child: ElevatedButton(
              onPressed: isSelectionComplete ? _goToSummary : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelectionComplete
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
              child: const Text('Confirmar Agendamiento'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de tu Servicio',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20, thickness: 1),
          _buildSummaryRow('Servicio:', widget.quotation.selectedService),
          _buildSummaryRow(
            'Mueble:',
            '${widget.quotation.furnitureType} (x${widget.quotation.furnitureQuantity})',
          ),
          _buildSummaryRow('Nivel de Suciedad:', widget.quotation.dirtLevel),
          if (widget.quotation.stainTypes.isNotEmpty)
            _buildSummaryRow(
              'Tipos de Mancha:',
              widget.quotation.stainTypes.join(', '),
            ),
          if (widget.quotation.petFriendly)
            _buildSummaryRow('Preferencia:', 'Productos Pet-Friendly'),
          if (widget.quotation.ecoFriendly)
            _buildSummaryRow('Preferencia:', 'Productos Ecológicos'),
          if (widget.quotation.notes.isNotEmpty)
            _buildSummaryRow('Notas:', widget.quotation.notes),
          _buildSummaryRow(
            'Dirección:',
            widget.quotation.address.isEmpty
                ? 'No especificada'
                : widget.quotation.address,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[900], fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTimeSlot == time;
        return ChoiceChip(
          label: Text(time),
          selected: isSelected,
          onSelected: (selected) => setState(() => _selectedTimeSlot = time),
          selectedColor: const Color(0xFF0A7AFF),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF0A7AFF)
                  : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryBlock() {
    if (_selectedDay != null && _selectedTimeSlot != null) {
      final String formattedDate = DateFormat.yMMMMEEEEd(
        'es_ES',
      ).format(_selectedDay!);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          'Cita: $formattedDate | $_selectedTimeSlot',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
