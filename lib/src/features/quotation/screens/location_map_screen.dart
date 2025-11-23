import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mubclean/src/features/quotation/screens/payment_checkout_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationMapScreen extends StatefulWidget {
  final String selectedService;
  final List<Map<String, dynamic>> furnitureItems;
  final double itemsTotal;

  const LocationMapScreen({
    super.key,
    required this.selectedService,
    required this.furnitureItems,
    required this.itemsTotal,
  });

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  final _addressController = TextEditingController();
  final _receiverController = TextEditingController();

  // Configuración del Calendario
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedTime = "10:00 AM";

  // --- VARIABLES PARA EL MAPA ---
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(20.967370, -89.623540);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES');
    _selectedDay = DateTime.now();
  }

  // --- LÓGICA HÍBRIDA: BUSCAR DIRECCIÓN ---
  Future<void> _buscarDireccionEnMapa() async {
    String direccion = _addressController.text;
    if (direccion.isEmpty) return;
    FocusScope.of(context).unfocus();

    try {
      List<Location> locations = await locationFromAddress(direccion);
      if (!mounted) return;
      if (locations.isNotEmpty) {
        Location lugar = locations.first;
        LatLng nuevasCoordenadas = LatLng(lugar.latitude, lugar.longitude);
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(nuevasCoordenadas, 16.0),
        );
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(direccion),
              position: nuevasCoordenadas,
              infoWindow: InfoWindow(
                title: "Ubicación del servicio",
                snippet: direccion,
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se encontró la dirección. Intenta agregar 'Merida' o ser más específico.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    const Color mubBlue = Color(0xFF0A7AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Agenda y Ubicación'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SECCIÓN DE CALENDARIO
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Selecciona Fecha y Hora",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          // --- CALENDARIO AJUSTADO PARA EVITAR CORTES ---
                          TableCalendar(
                            locale: 'es_ES',
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                            focusedDay: _focusedDay,
                            currentDay: _selectedDay,
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Mes',
                            },
                            rowHeight: 42, // Altura optimizada
                            // Estilo de la cabecera
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              leftChevronIcon: const Icon(
                                Icons.chevron_left,
                                color: mubBlue,
                              ),
                              rightChevronIcon: const Icon(
                                Icons.chevron_right,
                                color: mubBlue,
                              ),
                              titleTextFormatter: (date, locale) {
                                final dateStr = DateFormat.yMMMM(
                                  locale,
                                ).format(date);
                                return "${dateStr[0].toUpperCase()}${dateStr.substring(1)}";
                              },
                            ),

                            // AJUSTE CLAVE 1: Letra más pequeña para los días (Dom, Lun...)
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black87,
                              ),
                              weekendStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.redAccent,
                              ),
                            ),

                            // AJUSTE CLAVE 2: Letra y márgenes optimizados para los números
                            calendarStyle: CalendarStyle(
                              cellMargin: const EdgeInsets.all(
                                2.0,
                              ), // Menos margen para que quepan
                              selectedDecoration: BoxDecoration(
                                color: mubBlue,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: mubBlue.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),

                              defaultTextStyle: const TextStyle(fontSize: 13.0),
                              weekendTextStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.redAccent,
                              ),
                              outsideTextStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey,
                              ),
                            ),

                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                          ),

                          // --- FIN DE AJUSTES ---
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              "Horarios Disponibles",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              children:
                                  [
                                    "09:00 AM",
                                    "10:00 AM",
                                    "11:00 AM",
                                    "12:00 PM",
                                    "03:00 PM",
                                    "04:00 PM",
                                    "05:00 PM",
                                  ].map((time) {
                                    bool isSelected = _selectedTime == time;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: ChoiceChip(
                                        label: Text(time),
                                        selected: isSelected,
                                        onSelected: (v) => setState(
                                          () => _selectedTime = time,
                                        ),
                                        selectedColor: mubBlue,
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. SECCIÓN DE MAPA
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 14.0,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                      ),
                    ),

                    // 3. FORMULARIO
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detalles de la Dirección",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            child: _buildAddressSearchField(context),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: _buildTextField(
                              null,
                              "Referencias (Opcional)",
                              Icons.visibility_outlined,
                              "Fachada color, portón...",
                              maxLines: 2,
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Recepción del Servicio",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Por seguridad, ¿quién recibe al equipo?",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: _buildTextField(
                              _receiverController,
                              "Nombre de la persona",
                              Icons.person_outline,
                              "Ej. Juan Pérez",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 4. BARRA INFERIOR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_addressController.text.isEmpty ||
                        _receiverController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Por favor ingresa la dirección y quién recibe.",
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentCheckoutScreen(
                          selectedService: widget.selectedService,
                          furnitureItems: widget.furnitureItems,
                          totalToPay: widget.itemsTotal + 50.0,
                          address: _addressController.text,
                          receiverName: _receiverController.text,
                          serviceDate: _selectedDay ?? DateTime.now(),
                          serviceTime: _selectedTime,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mubBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continuar al Pago",
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
      ),
    );
  }

  Widget _buildAddressSearchField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dirección Exacta",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          maxLines: 1,
          onSubmitted: (value) => _buscarDireccionEnMapa(),
          decoration: InputDecoration(
            hintText: "Calle, Número, Colonia, Merida...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.home_outlined, color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFF0A7AFF)),
              onPressed: _buscarDireccionEnMapa,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF0A7AFF), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController? controller,
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF0A7AFF), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
