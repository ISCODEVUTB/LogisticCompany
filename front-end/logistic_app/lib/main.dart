import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/orders_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/routes_screen.dart';

void main( ) {
  runApp(const LogisticDashboardApp());
}

class LogisticDashboardApp extends StatelessWidget {
  final http.Client? client;
  const LogisticDashboardApp({this.client, super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel de Gestión Logística',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(client: client),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final http.Client? client;
  const DashboardScreen({super.key, this.client});
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
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
      final uri = Uri.parse('http://localhost:8000/api/dashboard'); // Changed URI
      final response = widget.client != null
          ? await widget.client!.get(uri)
          : await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedData = json.decode(response.body);
        debugPrint('DashboardScreen _fetchDashboardData - Parsed Data from /api/dashboard: $parsedData'); // Updated log
        setState(() {
          dashboardData = parsedData;
        });
      } else {
        // Handle error or fallback for /api/dashboard if needed
        debugPrint('Error fetching /api/dashboard: ${response.statusCode}');
        // Consider if dashboard_disabled should be tried here as a fallback
      }
    } catch (e) {
      debugPrint('Error al cargar datos del dashboard: $e');
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
        return OrdersScreen(client: widget.client); // Pass client
      case 2:
        return DriversScreen(client: widget.client); // Pass client
      case 3:
        return RoutesScreen(client: widget.client); // Pass client (will be refactored later)
      case 4:
        return TrackingScreen(client: widget.client); // Pass client (will be refactored later)
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
    debugPrint('DashboardScreen build - Current dashboardData: $dashboardData');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Gestión Logística'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Usuario: $adminUser", 
                style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ),
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

  const NavigationPanel({
    super.key,
    required this.selectedIndex, 
    required this.onItemTapped
  });

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
            child: const Column(
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
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[600]),
            title: const Text('Configuración'),
            onTap: () {
              // Implementar navegación a configuración
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.grey[600]),
            title: const Text('Ayuda'),
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
      leading: Icon(
        icon, 
        color: selectedIndex == index ? Colors.blueGrey[700] : Colors.grey[600]
      ),
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

  const InfoCard({
    super.key,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black45),
              Expanded(
                child: Text(
                  content, 
                  style: const TextStyle(
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

