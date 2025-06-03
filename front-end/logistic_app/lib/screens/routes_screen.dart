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
          ? await widget.client!.get(Uri.parse('http://localhost:8000/api/routes'))
          : await http.get(Uri.parse('http://localhost:8000/api/routes'));

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
          ? await widget.client!.get(Uri.parse('http://localhost:8000/api/drivers?status=Disponible'))
          : await http.get(Uri.parse('http://localhost:8000/api/drivers?status=Disponible'));
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
      final String driverId = selectedDriver['id'];
      debugPrint('Assigning Driver ID: $driverId to Route ID: $routeId');
      try {
        final assignResponse = widget.client != null
            ? await widget.client!.patch( Uri.parse('http://localhost:8000/api/routes/$routeId/assign-driver'), headers: {'Content-Type': 'application/json; charset=utf-8'}, body: json.encode({'driver_id': driverId}))
            : await http.patch( Uri.parse('http://localhost:8000/api/routes/$routeId/assign-driver'), headers: {'Content-Type': 'application/json; charset=utf-8'}, body: json.encode({'driver_id': driverId}));
        if (!mounted) return; // Changed from context.mounted
        if (assignResponse.statusCode == 200) {
          debugPrint('Driver assigned successfully to route $routeId');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conductor asignado correctamente')));
          fetchRoutes();
        } else {
          debugPrint('Failed to assign driver. Status: ${assignResponse.statusCode}, Body: ${assignResponse.body}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al asignar conductor: ${assignResponse.body}')));
        }
      } catch (e) {
        if (!mounted) return; // Changed from context.mounted
        debugPrint('Error assigning driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión al asignar conductor: $e')));
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

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _getFilteredRoutes();
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Rutas'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: fetchRoutes)]),
      body: Column(
        children: [
          const Text("Filtros y búsqueda placeholder"), // Placeholder for brevity
          if (errorMessage.isNotEmpty) Text(errorMessage),
          const Text("Estadísticas placeholder"), // Placeholder
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
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(route['name'] ?? 'N/A'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Conductor: ${route['driver'] ?? 'N/A'} | Vehículo: ${route['vehicle'] ?? 'N/A'}'),
                                      Row(children: [
                                        Text(route['status'] ?? 'N/A'),
                                        Text('Salida: ${route['departureTime'] != null ? _formatDateTime(route['departureTime']) : 'N/A'}'),
                                      ]),
                                    ],
                                  ),
                                  onTap: () => _showRouteDetails(route),
                                ),
                                if (route['status'] == 'Activa')
                                  Padding(
                                    padding: const EdgeInsets.all(8.0), // Simplified padding
                                    child: Text('Progreso: ${route['progress'] ?? 0}%'),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, tooltip: 'Nueva ruta', child: const Icon(Icons.add)),
    );
  }
}
