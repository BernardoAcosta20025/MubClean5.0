import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mubclean/src/features/quotation/screens/quote_summary_screen.dart';
import 'package:mubclean/src/features/home/home_page.dart';
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userId == null 
          ? const Center(child: Text("Inicia sesión para ver notificaciones"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('notifications')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final notifications = snapshot.data!;

                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No tienes notificaciones aún"),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final date = DateTime.parse(notif['created_at']);
                    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.receipt_long, color: Color(0xFF0A7AFF)),
                        ),
                        title: Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['body']),
                            const SizedBox(height: 5),
                            Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        onTap: () {
                          if (notif['booking_id'] != null) {
                            // NAVEGAR AL RESUMEN (NO AL PAGO DIRECTO)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuoteSummaryScreen(
                                  bookingId: notif['booking_id'],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}