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
      final client = widget.client ?? http.Client();
      final response = await client.get(Uri.parse('http://localhost:8000/api/orders'));
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
                // Dropdown and button for status update
                Builder( // Use Builder to get a context within the Dialog for ScaffoldMessenger
                  builder: (dialogContext) {
                    String? newSelectedStatus = order['status']; // Initialize with current status
                    final List<String> possibleStatuses = ['Pendiente', 'En preparación', 'En tránsito', 'Entregado', 'Cancelado'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: newSelectedStatus,
                          hint: const Text('Seleccionar nuevo estado'),
                          items: possibleStatuses
                              .map((status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            newSelectedStatus = value;
                          },
                          decoration: const InputDecoration(labelText: 'Nuevo Estado del Pedido'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          child: const Text('Actualizar Estado'),
                          onPressed: () async {
                            if (newSelectedStatus == null || newSelectedStatus == order['status']) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('No se ha seleccionado un nuevo estado o el estado es el mismo.')),
                              );
                              return;
                            }
                            final String orderId = order['id'];
                            final String statusToUpdate = newSelectedStatus!;

                            try {
                              final uri = Uri.parse('http://localhost:8002/orders/$orderId/status?status=$statusToUpdate');
                              final response = widget.client != null
                                  ? await widget.client!.patch(uri)
                                  : await http.patch(uri);

                              if (!mounted) return;

                              if (response.statusCode == 200 || response.statusCode == 204) {
                                Navigator.of(context).pop(); // Close the details dialog
                                fetchOrders(); // Refresh the list
                                ScaffoldMessenger.of(context).showSnackBar( // Use main context for SnackBar after dialog is closed
                                  const SnackBar(content: Text('Estado actualizado correctamente')),
                                );
                              } else {
                                ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialog context for SnackBar if dialog is still open
                                  SnackBar(content: Text('Error al actualizar estado: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                               ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Error de conexión: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 20),
                const Text('Otras Acciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar (Placeholder)'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a la pantalla de edición
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar Pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        // Store the details dialog context
                        final BuildContext detailsDialogContext = context;
                        showDialog(
                          context: detailsDialogContext, // Use details dialog's context to show confirmation on top
                          builder: (BuildContext confirmDialogContext) { // This is the context for the confirmation dialog itself
                            return AlertDialog(
                              title: const Text('Confirmar Cancelación'),
                              content: const Text('¿Está seguro de que desea cancelar este pedido? Esta acción no se puede deshacer.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('No'),
                                  onPressed: () {
                                    Navigator.of(confirmDialogContext).pop(); // Close confirmation dialog
                                  },
                                ),
                                TextButton(
                                  child: const Text('Sí'),
                                  onPressed: () async {
                                    final String orderId = order['id'];
                                    try {
                                      final uri = Uri.parse('http://localhost:8002/orders/$orderId/cancel');
                                      final response = widget.client != null
                                          ? await widget.client!.post(uri) // Assuming POST for cancel as per backend
                                          : await http.post(uri);

                                      if (!mounted) return;

                                      Navigator.of(confirmDialogContext).pop(); // Close confirmation dialog

                                      if (response.statusCode == 200 || response.statusCode == 204) {
                                        Navigator.of(detailsDialogContext).pop(); // Close details dialog
                                        fetchOrders(); // Refresh list
                                        ScaffoldMessenger.of(detailsDialogContext).showSnackBar( // Or use the main screen's context if detailsDialogContext is problematic after pop
                                          const SnackBar(content: Text('Pedido cancelado correctamente')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(detailsDialogContext).showSnackBar(
                                          SnackBar(content: Text('Error al cancelar pedido: ${response.body}')),
                                        );
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      Navigator.of(confirmDialogContext).pop(); // Close confirmation dialog on error too
                                      ScaffoldMessenger.of(detailsDialogContext).showSnackBar(
                                        SnackBar(content: Text('Error de conexión al cancelar: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
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
                                      Expanded(
                                        child: Text('Entrega: ${order['estimatedDelivery']}'),
                                      ),
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
    String senderName = '';
    String senderAddress = '';
    String senderPhone = '';
    String receiverName = '';
    String receiverAddress = '';
    String receiverPhone = '';
    String pickupDateRaw = '';
    String packageWeight = '';
    String packageDimensions = '';

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
                    key: const Key('input_sender_name'),
                    decoration: const InputDecoration(labelText: 'Nombre Remitente'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del remitente' : null,
                    onSaved: (value) => senderName = value!,
                  ),
                  TextFormField(
                    key: const Key('input_sender_address'),
                    decoration: const InputDecoration(labelText: 'Dirección Remitente'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese la dirección del remitente' : null,
                    onSaved: (value) => senderAddress = value!,
                  ),
                  TextFormField(
                    key: const Key('input_sender_phone'),
                    decoration: const InputDecoration(labelText: 'Teléfono Remitente'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el teléfono del remitente' : null,
                    onSaved: (value) => senderPhone = value!,
                  ),
                  TextFormField(
                    key: const Key('input_receiver_name'),
                    decoration: const InputDecoration(labelText: 'Nombre Destinatario'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del destinatario' : null,
                    onSaved: (value) => receiverName = value!,
                  ),
                  TextFormField(
                    key: const Key('input_receiver_address'),
                    decoration: const InputDecoration(labelText: 'Dirección Destinatario'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese la dirección del destinatario' : null,
                    onSaved: (value) => receiverAddress = value!,
                  ),
                  TextFormField(
                    key: const Key('input_receiver_phone'),
                    decoration: const InputDecoration(labelText: 'Teléfono Destinatario'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el teléfono del destinatario' : null,
                    onSaved: (value) => receiverPhone = value!,
                  ),
                  TextFormField(
                    key: const Key('input_pickup_date'),
                    decoration: const InputDecoration(labelText: 'Fecha Recogida (YYYY-MM-DD HH:MM:SS)'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese la fecha de recogida' : null,
                    onSaved: (value) => pickupDateRaw = value!,
                  ),
                  TextFormField(
                    key: const Key('input_peso'), // Reuse key if it makes sense, or create 'input_package_weight'
                    decoration: const InputDecoration(labelText: 'Peso Paquete (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el peso del paquete' : null,
                    onSaved: (value) => packageWeight = value!,
                  ),
                  TextFormField(
                    key: const Key('input_package_dimensions'),
                    decoration: const InputDecoration(labelText: 'Dimensiones Paquete (LxWxH)'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese las dimensiones del paquete' : null,
                    onSaved: (value) => packageDimensions = value!,
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

                  String pickupDateISO = '';
                  try {
                    // Assuming pickupDateRaw is "YYYY-MM-DD HH:MM:SS"
                    DateTime parsedDate = DateTime.parse(pickupDateRaw.replaceFirst(' ', 'T'));
                    pickupDateISO = '${parsedDate.toIso8601String()}Z'; // Append Z for UTC
                  } catch (e) {
                    // Handle parsing error, maybe show a message to the user
                    debugPrint("Error parsing date: $e");
                    // For now, let it proceed, backend might catch it or use a default
                  }


                  final orderData = {
                    "sender": {
                      "name": senderName,
                      "address": senderAddress,
                      "phone": senderPhone
                    },
                    "receiver": {
                      "name": receiverName,
                      "address": receiverAddress,
                      "phone": receiverPhone
                    },
                    "pickup_date": pickupDateISO,
                    "package": {
                      "weight": double.tryParse(packageWeight) ?? 0.0,
                      "dimensions": packageDimensions
                    }
                  };

                  try {
                    final response = widget.client != null
                        ? await widget.client!.post(
                            Uri.parse('http://localhost:8002/orders'),
                            headers: {'Content-Type': 'application/json; charset=utf-8'},
                            body: json.encode(orderData),
                          )
                        : await http.post(
                            Uri.parse('http://localhost:8002/orders'),
                            headers: {'Content-Type': 'application/json; charset=utf-8'},
                            body: json.encode(orderData),
                          );

                    // Check mounted before using context after await
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close dialog

                    if (response.statusCode == 201 || response.statusCode == 200) { // 201 is typical for created, 200 if it returns the object
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pedido creado correctamente')),
                      );
                      fetchOrders(); // Refresh the list
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear pedido: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close dialog
                    if (!mounted) return;
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
