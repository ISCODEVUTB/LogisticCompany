import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic> data = {
    'totalOrders': '...',
    'activeDrivers': '...',
    'activeRoutes': '...',
    'trackingEvents': '...',
  };

  @override
  void initState() {
    super.initState();
    fetchData(); // Llama a los microservicios
  }

  Future<void> fetchData() async {
    try {
      // Simulaciones (reemplazar por tu IP/localhost)
      final orderRes = await http.get(Uri.parse('http://localhost:8002/orders'));
      final driverRes = await http.get(Uri.parse('http://localhost:8001/drivers'));
      final routeRes = await http.get(Uri.parse('http://localhost:8004/routes/active'));
      final trackRes = await http.get(Uri.parse('http://localhost:8003/track/TRK12345678')); // uno específico

      setState(() {
        data['totalOrders'] = jsonDecode(orderRes.body).length.toString();
        data['activeDrivers'] = jsonDecode(driverRes.body).length.toString();
        data['activeRoutes'] = jsonDecode(routeRes.body).length.toString();
        data['trackingEvents'] = jsonDecode(trackRes.body)['history']?.length.toString() ?? '0';
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 36, color: color),
        title: Text(title),
        subtitle: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración - Admin'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildCard('Total de Pedidos', data['totalOrders'], Icons.inventory_2, Colors.blue),
            buildCard('Conductores Activos', data['activeDrivers'], Icons.directions_car, Colors.green),
            buildCard('Rutas Activas', data['activeRoutes'], Icons.alt_route, Colors.orange),
            buildCard('Eventos de Rastreo', data['trackingEvents'], Icons.track_changes, Colors.purple),
          ],
        ),
      ),
    );
  }
}
