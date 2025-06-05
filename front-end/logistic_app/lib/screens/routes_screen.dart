import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoutesScreen extends StatefulWidget {
  final http.Client? client;
  const RoutesScreen({super.key, this.client});
  
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  bool isLoading = true;
  List<dynamic> routes = [];
  String errorMessage = '';
  String filterStatus = 'Todas';

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = widget.client != null
          ? await widget.client!.get(Uri.parse('http://localhost:8004/routes'))
          : await http.get(Uri.parse('http://localhost:8004/routes'));

      if (response.statusCode == 200) {
        List<dynamic> decodedData = json.decode(response.body);
        debugPrint('_RoutesScreenState fetchRoutes - Decoded Data: $decodedData');
        setState(() {
          routes = decodedData;
          isLoading = false;
        });
      } else {
        setState(() {
          routes = sampleRoutes;
          isLoading = false;
          errorMessage = 'No se pudieron cargar los datos del servidor. Mostrando datos de muestra.';
        });
      }
    } catch (e) {
      setState(() {
        routes = sampleRoutes;
        isLoading = false;
        errorMessage = 'Error de conexión: $e. Mostrando datos de muestra.';
      });
    }
  }

  final List<dynamic> sampleRoutes = [
    {
      'id': 'RUT-001', 'name': 'Ruta Cartagena - Barranquilla', 'status': 'Activa', 'driver': 'Carlos Rodríguez', 'vehicle': 'Camión - XYZ123',
      'startLocation': 'Centro de Distribución Cartagena', 'endLocation': 'Centro Logístico Barranquilla', 'distance': 120, 'estimatedTime': '2h 30min',
      'departureTime': '2025-05-31T08:00:00', 'arrivalTime': '2025-05-31T10:30:00', 'stops': 3, 'orders': ['ORD-001', 'ORD-005'], 'progress': 65,
      'currentLocation': {'latitude': 10.9878, 'longitude': -74.7889, 'lastUpdate': '2025-05-31T09:15:00'}
    },
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa': return Colors.blue;
      case 'programada': return Colors.purple;
      case 'completada': return Colors.green;
      case 'cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showRouteDetails(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (BuildContext context) { // Ensure this context is used for things inside dialog if needed
        return AlertDialog(
          title: const Text('Detalles de la Ruta'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text( route['name'] ?? 'N/A', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(route['status'] ?? 'Desconocido').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      route['status'] ?? 'N/A',
                      style: TextStyle(color: _getStatusColor(route['status'] ?? 'Desconocido'), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _buildDetailRow('ID', route['id']),
                  _buildDetailRow('Conductor', route['driver']), // Will use 'N/A' if null
                  _buildDetailRow('Vehículo', route['vehicle']), // Will use 'N/A' if null
                  _buildDetailRow('Origen', route['startLocation']),
                  _buildDetailRow('Destino', route['endLocation']),
                  _buildDetailRow('Distancia', route['distance'] != null ? '${route['distance']} km' : 'N/A'),
                  _buildDetailRow('Tiempo estimado', route['estimatedTime']),
                  _buildDetailRow('Salida', route['departureTime'] != null ? _formatDateTime(route['departureTime']) : 'N/A'),
                  _buildDetailRow('Llegada estimada', route['arrivalTime'] != null ? _formatDateTime(route['arrivalTime']) : 'N/A'),
                  _buildDetailRow('Paradas', route['stops']?.toString()),
                  _buildDetailRow('Pedidos', (route['orders'] as List<dynamic>?)?.join(', ')),
                  const SizedBox(height: 20),
                  const Text('Progreso de la Ruta', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (route['progress'] as num? ?? 0) / 100.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(route['status'] ?? 'Desconocido')),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 4),
                  Text('${route['progress'] ?? 0}%'),
                  const SizedBox(height: 20),
                  if (route['currentLocation'] != null && route['currentLocation'] is Map) ...[
                    const Text('Ubicación Actual', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container( /* ... map placeholder ... */ ),
                  ],
                  const SizedBox(height: 20),
                  const Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(icon: const Icon(Icons.edit), label: const Text('Editar'), onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
                      ElevatedButton.icon(icon: const Icon(Icons.map), label: const Text('Ver Mapa'), onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Asignar Conductor'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showDriverSelectionDialog(route);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Completar Ruta'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          final String routeId = route['id'];
                          final BuildContext detailsDialogContext = context; // Capture context

                          try {
                            final uri = Uri.parse('http://localhost:8004/routes/$routeId/complete');
                            final response = widget.client != null
                                ? await widget.client!.patch(uri)
                                : await http.patch(uri);

                            if (!mounted) return;

                            // Pop dialog first
                            Navigator.of(detailsDialogContext).pop();

                            if (response.statusCode == 200) {
                              fetchRoutes(); // Refresh list
                              if (!mounted) return; // Check mounted again before using this.context
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Ruta marcada como completada')),
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(content: Text('Error al completar ruta: ${response.body}')),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error de conexión al completar ruta: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [ TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
        );
      },
    );
  }

  void _showDriverSelectionDialog(Map<String, dynamic> route) async {
    List<dynamic> availableDrivers = [];
    try {
      final response = widget.client != null
          ? await widget.client!.get(Uri.parse('http://localhost:8001/drivers?status=Disponible'))
          : await http.get(Uri.parse('http://localhost:8001/drivers?status=Disponible'));
      if (response.statusCode == 200) {
        availableDrivers = json.decode(response.body);
      } else { /* Handle error */ }
    } catch (e) { /* Handle error */ }

    if (!mounted) return; // Changed from context.mounted

    final selectedDriver = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) { // Use different context name
        return AlertDialog(
          title: const Text('Seleccionar Conductor'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableDrivers.isEmpty
                ? const Text('No hay conductores disponibles o error al cargar.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableDrivers.length,
                    itemBuilder: (itemContext, index) { // Use different context name
                      final driver = availableDrivers[index];
                      return ListTile(
                        title: Text(driver['name'] ?? 'Nombre no disponible'),
                        onTap: () => Navigator.of(dialogContext).pop(driver),
                      );
                    },
                  ),
          ),
          actions: [ TextButton(onPressed: () => Navigator.of(dialogContext).pop(null), child: const Text('Cancelar'))],
        );
      },
    );

    if (selectedDriver != null) {
      final String routeId = route['id'];
      final String driverId = selectedDriver['id']; // Assuming selectedDriver has an 'id' field
      debugPrint('Assigning Driver ID: $driverId to Route ID: $routeId');

      // Capture the context for use after async operations if mounted
      final currentContext = context; // Assuming 'context' is the BuildContext of _showDriverSelectionDialog

      try {
        final uri = Uri.parse('http://localhost:8004/routes/$routeId/driver');
        final headers = {'Content-Type': 'application/json; charset=utf-8'};
        final body = json.encode({'driver_id': driverId});

        final response = widget.client != null
            ? await widget.client!.patch(uri, headers: headers, body: body)
            : await http.patch(uri, headers: headers, body: body);

        // Check mounted before using context after await
        // This check should ideally use a State's mounted property,
        // but since this is a method, we rely on the calling widget being mounted.
        // For robust_ness, if _showDriverSelectionDialog is part of a State<StatefulWidget>,
        // it's better to check that State's mounted property.
        // However, given the current structure, we'll proceed with a direct context check if possible,
        // or rely on the try-catch to handle cases where context might be invalid.

        if (response.statusCode == 200) { // Backend now returns 200 with updated route
          if (!Navigator.of(currentContext).mounted) return; // Check before using context
          Navigator.of(currentContext).pop(selectedDriver); // Close driver selection dialog, pass back selected driver

          // Potentially pop the details dialog as well, or let the caller handle it.
          // For now, just pop the selection dialog.
          // The caller of _showDriverSelectionDialog would then call fetchRoutes().

          if (!mounted) return; // Check before using context for ScaffoldMessenger
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conductor asignado a la ruta.')),
          );
          fetchRoutes(); // Refresh the routes list on the main screen
        } else {
          if (!mounted) return; // Check before using context for ScaffoldMessenger
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al asignar conductor: ${response.body} (Status: ${response.statusCode})')),
          );
        }
      } catch (e) {
        if (!mounted) return; // Check before using context for ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión al asignar conductor: $e')),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String? value) { // Changed to String?
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value ?? 'N/A')), // Ensured null check here
        ],
      ),
    );
  }

  List<dynamic> _getFilteredRoutes() {
    if (filterStatus == 'Todas') return routes;
    return routes.where((route) => route['status'] == filterStatus).toList();
  }

  void _showCreateRouteDialog() {
    final formKey = GlobalKey<FormState>();
    String origin = '';
    String destination = '';
    String estimatedTimeStr = '';
    String distanceKmStr = '';
    String driverId = '';
    String orderIdsStr = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nueva Ruta'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Origen'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el origen' : null,
                    onSaved: (value) => origin = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Destino'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el destino' : null,
                    onSaved: (value) => destination = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tiempo Estimado (minutos)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el tiempo estimado' : null,
                    onSaved: (value) => estimatedTimeStr = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Distancia (km)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese la distancia' : null,
                    onSaved: (value) => distanceKmStr = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'ID del Conductor (opcional)'),
                    onSaved: (value) => driverId = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'IDs de Pedidos (separados por coma, opcional)'),
                    onSaved: (value) => orderIdsStr = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Crear'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  // Process the form data
                  final int estimatedTimeMinutes = int.tryParse(estimatedTimeStr) ?? 0;
                  final int distanceKm = int.tryParse(distanceKmStr) ?? 0;
                  
                  // Format estimated time as "Xh Ymin"
                  final String formattedTime = estimatedTimeMinutes >= 60
                      ? '${estimatedTimeMinutes ~/ 60}h ${estimatedTimeMinutes % 60}min'
                      : '${estimatedTimeMinutes}min';
                  
                  // Process order IDs if provided
                  final List<String> orderIds = orderIdsStr.isNotEmpty
                      ? orderIdsStr.split(',').map((e) => e.trim()).toList()
                      : [];
                  
                  // Create route data
                  final Map<String, dynamic> routeData = {
                    'startLocation': origin,
                    'endLocation': destination,
                    'estimatedTime': formattedTime,
                    'distance': distanceKm,
                    'status': 'Programada',
                  };
                  
                  // Add driver ID if provided
                  if (driverId.isNotEmpty) {
                    routeData['driver_id'] = driverId;
                  }
                  
                  // Add order IDs if provided
                  if (orderIds.isNotEmpty) {
                    routeData['order_ids'] = orderIds;
                  }
                  
                  try {
                    final response = await http.post(
                      Uri.parse('http://localhost:8004/routes'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(routeData),
                    );
                    
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close dialog
                    
                    if (response.statusCode == 201) {
                      fetchRoutes(); // Refresh routes list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ruta creada exitosamente')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear ruta: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _getFilteredRoutes();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rutas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                filterStatus = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Todas',
                child: Text('Todas las rutas'),
              ),
              const PopupMenuItem<String>(
                value: 'Activa',
                child: Text('Rutas activas'),
              ),
              const PopupMenuItem<String>(
                value: 'Programada',
                child: Text('Rutas programadas'),
              ),
              const PopupMenuItem<String>(
                value: 'Completada',
                child: Text('Rutas completadas'),
              ),
              const PopupMenuItem<String>(
                value: 'Cancelada',
                child: Text('Rutas canceladas'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.amber.shade100,
              width: double.infinity,
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRoutes.isEmpty
                    ? const Center(child: Text('No hay rutas disponibles'))
                    : ListView.builder(
                        itemCount: filteredRoutes.length,
                        itemBuilder: (context, index) {
                          final route = filteredRoutes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                route['name'] ?? 'Ruta sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('${route['startLocation']} → ${route['endLocation']}'),
                                  const SizedBox(height: 4),
                                  Text('Conductor: ${route['driver'] ?? 'No asignado'}'),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (route['progress'] as num? ?? 0) / 100.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(route['status'] ?? 'Desconocido')),
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Progreso: ${route['progress'] ?? 0}%'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(route['status'] ?? 'Desconocido').withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  route['status'] ?? 'Desconocido',
                                  style: TextStyle(
                                    color: _getStatusColor(route['status'] ?? 'Desconocido'),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _showRouteDetails(route),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRouteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
