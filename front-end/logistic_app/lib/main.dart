import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/orders_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/routes_screen.dart';

void main( ) {
  runApp(LogisticDashboardApp());
}

class LogisticDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel de Gestión Logística',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String adminUser = "Admin";
  int _selectedIndex = 0;
  
  // Datos para el dashboard
  Map<String, dynamic> dashboardData = {
    'pedidos': {'total': 25, 'enTransito': 10},
    'conductores': {'disponibles': 8, 'asignados': 5},
    'rutas': {'activas': 4},
    'tracking': {'eventos': 13}
  };

  @override
  void initState() {
    super.initState();
    // Cargar datos del backend
    _fetchDashboardData();
  }

  // Método para obtener datos del backend
  Future<void> _fetchDashboardData() async {
    try {
      // Esta URL debe ser reemplazada por la URL real de tu API
      final response = await http.get(Uri.parse('http://localhost:8000/api/dashboard' ));
      
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      // Usar datos de muestra en caso de error
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return OrdersScreen();
      case 2:
        return DriversScreen();
      case 3:
        return RoutesScreen();
      case 4:
        return TrackingScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          InfoCard(
            title: "Pedidos Activos",
            content: "Total: ${dashboardData['pedidos']['total']}\nEn tránsito: ${dashboardData['pedidos']['enTransito']}",
            icon: Icons.local_shipping,
            color: Colors.blue[100]!,
            iconColor: Colors.blue[700]!,
            onTap: () => _onItemTapped(1),
          ),
          InfoCard(
            title: "Conductores Disponibles",
            content: "Disponibles: ${dashboardData['conductores']['disponibles']}\nAsignados: ${dashboardData['conductores']['asignados']}",
            icon: Icons.person,
            color: Colors.green[100]!,
            iconColor: Colors.green[700]!,
            onTap: () => _onItemTapped(2),
          ),
          InfoCard(
            title: "Rutas en Curso",
            content: "Rutas Activas: ${dashboardData['rutas']['activas']}",
            icon: Icons.route,
            color: Colors.orange[100]!,
            iconColor: Colors.orange[700]!,
            onTap: () => _onItemTapped(3),
          ),
          InfoCard(
            title: "Eventos de Tracking",
            content: "Últimos eventos registrados: ${dashboardData['tracking']['eventos']}",
            icon: Icons.location_on,
            color: Colors.purple[100]!,
            iconColor: Colors.purple[700]!,
            onTap: () => _onItemTapped(4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Gestión Logística'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("Usuario: $adminUser", style: TextStyle(fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Row(
        children: [
          NavigationPanel(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }
}

class NavigationPanel extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  NavigationPanel({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.grey.shade200,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Menú',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Sistema de Gestión Logística',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          _buildNavItem(0, Icons.dashboard, 'Dashboard'),
          _buildNavItem(1, Icons.local_shipping, 'Pedidos'),
          _buildNavItem(2, Icons.person, 'Conductores'),
          _buildNavItem(3, Icons.route, 'Rutas'),
          _buildNavItem(4, Icons.track_changes, 'Tracking'),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[600]),
            title: Text('Configuración'),
            onTap: () {
              // Implementar navegación a configuración
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.grey[600]),
            title: Text('Ayuda'),
            onTap: () {
              // Implementar navegación a ayuda
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: selectedIndex == index ? Colors.blueGrey[700] : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          color: selectedIndex == index ? Colors.blueGrey[700] : Colors.black87,
        ),
      ),
      selected: selectedIndex == index,
      onTap: () => onItemTapped(index),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  InfoCard({
    required this.title, 
    required this.content, 
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40, color: iconColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black45),
              Expanded(
                child: Text(
                  content, 
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
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
