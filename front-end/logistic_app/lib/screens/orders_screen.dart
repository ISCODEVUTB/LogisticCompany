import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState( ) => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isLoading = true;
  List<dynamic> orders = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Intenta obtener datos del backend
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/orders' ),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Si hay error, usar datos de muestra
        setState(() {
          orders = sampleOrders;
          isLoading = false;
          errorMessage = 'No se pudieron cargar los datos del servidor. Mostrando datos de muestra.';
        });
      }
    } catch (e) {
      // En caso de error de conexión, usar datos de muestra
      setState(() {
        orders = sampleOrders;
        isLoading = false;
        errorMessage = 'Error de conexión: $e. Mostrando datos de muestra.';
      });
    }
  }

  // Datos de muestra para desarrollo
  final List<dynamic> sampleOrders = [
    {
      'id': 'ORD-001',
      'customer': 'Juan Pérez',
      'destination': 'Calle Principal 123, Cartagena',
      'status': 'En tránsito',
      'date': '2025-05-28',
      'items': 3,
      'total': 250000,
      'driver': 'Carlos Rodríguez',
      'estimatedDelivery': '2025-06-01'
    },
    {
      'id': 'ORD-002',
      'customer': 'María López',
      'destination': 'Avenida Central 456, Barranquilla',
      'status': 'Entregado',
      'date': '2025-05-25',
      'items': 1,
      'total': 120000,
      'driver': 'Ana Martínez',
      'estimatedDelivery': '2025-05-30'
    },
    {
      'id': 'ORD-003',
      'customer': 'Pedro Gómez',
      'destination': 'Carrera 78 #45-12, Medellín',
      'status': 'Pendiente',
      'date': '2025-05-30',
      'items': 5,
      'total': 450000,
      'driver': 'Pendiente asignación',
      'estimatedDelivery': '2025-06-03'
    },
    {
      'id': 'ORD-004',
      'customer': 'Laura Torres',
      'destination': 'Calle 23 #12-45, Bogotá',
      'status': 'En preparación',
      'date': '2025-05-31',
      'items': 2,
      'total': 180000,
      'driver': 'Pendiente asignación',
      'estimatedDelivery': '2025-06-04'
    },
    {
      'id': 'ORD-005',
      'customer': 'Roberto Sánchez',
      'destination': 'Avenida Libertador 789, Santa Marta',
      'status': 'En tránsito',
      'date': '2025-05-27',
      'items': 4,
      'total': 320000,
      'driver': 'Miguel Díaz',
      'estimatedDelivery': '2025-06-02'
    },
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return Colors.green;
      case 'en tránsito':
        return Colors.blue;
      case 'pendiente':
        return Colors.orange;
      case 'en preparación':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Pedido ${order['id']}'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Cliente', order['customer']),
                _buildDetailRow('Destino', order['destination']),
                _buildDetailRow('Estado', order['status'], color: _getStatusColor(order['status'])),
                _buildDetailRow('Fecha de pedido', order['date']),
                _buildDetailRow('Artículos', order['items'].toString()),
                _buildDetailRow('Total', '\$${order['total']}'),
                _buildDetailRow('Conductor', order['driver']),
                _buildDetailRow('Entrega estimada', order['estimatedDelivery']),
                SizedBox(height: 20),
                Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Editar'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a la pantalla de edición
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.location_on),
                      label: Text('Rastrear'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a la pantalla de tracking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pedidos'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchOrders,
            tooltip: 'Actualizar pedidos',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar pedidos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.filter_list),
                  label: Text('Filtros'),
                  onPressed: () {
                    // Implementar filtros
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Mensaje de error si existe
          if (errorMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.amber[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[800]),
                  SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        errorMessage = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Lista de pedidos
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(child: Text('No hay pedidos disponibles'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order['status']),
                                child: Text(
                                  order['id'].substring(order['id'].length - 2),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '${order['id']} - ${order['customer']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text('Destino: ${order['destination']}'),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order['status']).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          order['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(order['status']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Entrega: ${order['estimatedDelivery']}'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () => _showOrderDetails(order),
                              ),
                              onTap: () => _showOrderDetails(order),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar creación de nuevo pedido
        },
        backgroundColor: Colors.blueGrey[700],
        child: Icon(Icons.add),
        tooltip: 'Nuevo pedido',
      ),
    );
  }
}
