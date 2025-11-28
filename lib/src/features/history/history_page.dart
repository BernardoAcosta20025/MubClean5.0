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
      {'service': 'Lavado de Sala en L', 'status': 'Cotización Pendiente', 'date': 'Solicitado hoy'},
      {'service': 'Limpieza de Colchón King', 'status': 'Agendado', 'date': 'Viernes, 15 Nov - 10:00 AM'},
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
      {'service': 'Lavado de Alfombra', 'status': 'Finalizado', 'date': '20 Octubre 2023', 'cost': '\$450.00'},
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
    final bool isFinished = data['status'] == 'Finalizado';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['service'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusChip(data['status']),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(data['date'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          if (isFinished && data.containsKey('cost')) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pagado", style: TextStyle(color: Colors.grey)),
                Text(data['cost'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Agendado': color = Colors.blue; break;
      case 'Finalizado': color = Colors.green; break;
      case 'Cotización Pendiente': color = Colors.orange; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}