import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logistic_company_web/screens/tracking_screen.dart'; // Added import

class OrdersScreen extends StatefulWidget {
  final http.Client? client;

  const OrdersScreen({super.key, this.client});
  
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
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
      final response = widget.client != null
          ? await widget.client!.get(Uri.parse('http://localhost:8000/api/orders'))
          : await http.get(Uri.parse('http://localhost:8000/api/orders'));

      // Simulating timeout for the widget.client != null case as well for consistency
      // Note: Real timeout handling for a passed client would be more complex or assumed to be handled by the client's configuration.
      // For this example, we'll assume the passed client handles its own timeouts or we simplify.
      // If direct timeout application is needed, it would be:
      // final response = await (widget.client != null
      //     ? widget.client!.get(Uri.parse('http://localhost:8000/api/orders'))
      //     : http.get(Uri.parse('http://localhost:8000/api/orders'))
      // ).timeout(const Duration(seconds: 5));
      // However, MockClient doesn't inherently support .timeout in the same way as a direct http.get future.
      // So, we'll proceed without explicit timeout on the widget.client path for now, assuming the mock handles it.


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
        content: SizedBox(
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
                const SizedBox(height: 20),
                const Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a la pantalla de edición
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text('Rastrear'),
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackingScreen(
                              orderId: order['id'], // Pass the order ID
                              client: widget.client, // Pass the client
                            ),
                          ),
                        );
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
            child: const Text('Cerrar'),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
        title: const Text('Gestión de Pedidos'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
            tooltip: 'Actualizar pedidos',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar pedidos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtros'),
                  onPressed: () {
                    // Implementar filtros
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Mensaje de error si existe
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                  IconButton(
                    icon: const Icon(Icons.close),
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
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('No hay pedidos disponibles'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order['status']),
                                child: Text(
                                  order['id'].substring(order['id'].length - 2),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '${order['id']} - ${order['customer']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Destino: ${order['destination']}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                      const SizedBox(width: 8),
                                      Text('Entrega: ${order['estimatedDelivery']}'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
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
        onPressed: _showCreateOrderDialog,
        backgroundColor: Colors.blueGrey[700],
        tooltip: 'Nuevo Pedido', // Matched to test
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateOrderDialog() {
    final formKey = GlobalKey<FormState>();
    String cliente = '';
    String origen = '';
    String destino = '';
    String peso = ''; // Assuming weight is entered as string then parsed

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Pedido'),
          content: SingleChildScrollView( // To prevent overflow if keyboard appears
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: const Key('input_cliente'),
                    decoration: const InputDecoration(labelText: 'Cliente'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el cliente' : null,
                    onSaved: (value) => cliente = value!,
                  ),
                  TextFormField(
                    key: const Key('input_origen'),
                    decoration: const InputDecoration(labelText: 'Origen'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el origen' : null,
                    onSaved: (value) => origen = value!,
                  ),
                  TextFormField(
                    key: const Key('input_destino'),
                    decoration: const InputDecoration(labelText: 'Destino'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el destino' : null,
                    onSaved: (value) => destino = value!,
                  ),
                  TextFormField(
                    key: const Key('input_peso'),
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el peso' : null,
                    onSaved: (value) => peso = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              key: const Key('guardar_button'), // Key for the save button
              child: const Text('Guardar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  // Prepare data for POST request
                  // This structure needs to match what your backend expects
                  final orderData = {
                    'customer': cliente, // Assuming backend expects 'customer'
                    'origin': origen,
                    'destination': destino,
                    'package': { // Assuming package details are nested
                       'weight': double.tryParse(peso) ?? 0.0,
                       // Add other package details if needed by backend e.g. dimensions
                    },
                    // Add other fields your backend expects for order creation:
                    // e.g., 'pickup_date', 'sender_details', 'receiver_details'
                    // For now, keeping it simple based on form fields.
                    'status': 'Pendiente', // Default status
                    'date': DateTime.now().toIso8601String().substring(0,10), // Today's date
                    'items': 1, // Example
                    'driver': 'Pendiente asignación',
                    'estimatedDelivery': DateTime.now().add(const Duration(days:3)).toIso8601String().substring(0,10)

                  };

                  try {
                    final response = widget.client != null
                        ? await widget.client!.post(
                            Uri.parse('http://localhost:8000/api/orders'),
                            headers: {'Content-Type': 'application/json; charset=utf-8'},
                            body: json.encode(orderData),
                          )
                        : await http.post(
                            Uri.parse('http://localhost:8000/api/orders'),
                            headers: {'Content-Type': 'application/json; charset=utf-8'},
                            body: json.encode(orderData),
                          );

                    Navigator.of(context).pop(); // Close dialog

                    if (response.statusCode == 201 || response.statusCode == 200) { // 201 is typical for created, 200 if it returns the object
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pedido creado correctamente')),
                      );
                      fetchOrders(); // Refresh the list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear pedido: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error de conexión: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
