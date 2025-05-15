import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String adminUser = "Admin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Gestión Logística'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("Usuario: $adminUser")),
          )
        ],
      ),
      body: Row(
        children: [
          NavigationPanel(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  InfoCard(
                    title: "Pedidos Activos",
                    content: "Total: 25\nEn tránsito: 10",
                    icon: Icons.local_shipping,
                  ),
                  InfoCard(
                    title: "Conductores Disponibles",
                    content: "Disponibles: 8\nAsignados: 5",
                    icon: Icons.person,
                  ),
                  InfoCard(
                    title: "Rutas en Curso",
                    content: "Rutas Activas: 4",
                    icon: Icons.route,
                  ),
                  InfoCard(
                    title: "Eventos de Tracking",
                    content: "Últimos eventos registrados: 13",
                    icon: Icons.location_on,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.grey.shade200,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              'Menú',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text('Pedidos'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Conductores'),
          ),
          ListTile(
            leading: Icon(Icons.route),
            title: Text('Rutas'),
          ),
          ListTile(
            leading: Icon(Icons.track_changes),
            title: Text('Tracking'),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  InfoCard({required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(content, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
