import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Activos y Anteriores
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          title: const Text("Mis Servicios", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Color(0xFF0A7AFF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0A7AFF),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: "Activos"),
              Tab(text: "Anteriores"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveServices(),
            _buildPastServices(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveServices() {
    final List<Map<String, dynamic>> activeServices = [
      {'service': 'Lavado de Sala en L', 'status': 'Cotización Pendiente', 'date': 'Solicitado el 12 Nov', 'color': const Color(0xFFFFA000), 'icon': Icons.access_time_filled},
      {'service': 'Limpieza de Colchón King', 'status': 'Agendado', 'date': 'Viernes, 15 Nov - 10:00 AM', 'color': const Color(0xFF0A7AFF), 'icon': Icons.calendar_today},
    ];
    if (activeServices.isEmpty) {
      return _buildEmptyState("No tienes servicios en curso");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activeServices.length,
      itemBuilder: (context, index) {
        return _ServiceCard(data: activeServices[index]);
      },
    );
  }

  Widget _buildPastServices() {
    final List<Map<String, dynamic>> pastServices = [
      {'service': 'Lavado de Alfombra', 'status': 'Finalizado', 'date': '20 Octubre 2023', 'color': Colors.green, 'icon': Icons.check_circle},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pastServices.length,
      itemBuilder: (context, index) {
        return _ServiceCard(data: pastServices[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// WIDGET DE TARJETA DE SERVICIO
class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (data['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(data['icon'], size: 14, color: data['color']),
                    const SizedBox(width: 5),
                    Text(
                      data['status'],
                      style: TextStyle(
                        color: data['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['service'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            data['date'],
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}