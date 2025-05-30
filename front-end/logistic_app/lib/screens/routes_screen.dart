import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoutesScreen extends StatefulWidget {
  @override
  _RoutesScreenState createState( ) => _RoutesScreenState();
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
      // Intenta obtener datos del backend
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/routes' ),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          routes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Si hay error, usar datos de muestra
        setState(() {
          routes = sampleRoutes;
          isLoading = false;
          errorMessage = 'No se pudieron cargar los datos del servidor. Mostrando datos de muestra.';
        });
      }
    } catch (e) {
      // En caso de error de conexión, usar datos de muestra
      setState(() {
        routes = sampleRoutes;
        isLoading = false;
        errorMessage = 'Error de conexión: $e. Mostrando datos de muestra.';
      });
    }
  }

  // Datos de muestra para desarrollo
  final List<dynamic> sampleRoutes = [
    {
      'id': 'RUT-001',
      'name': 'Ruta Cartagena - Barranquilla',
      'status': 'Activa',
      'driver': 'Carlos Rodríguez',
      'vehicle': 'Camión - XYZ123',
      'startLocation': 'Centro de Distribución Cartagena',
      'endLocation': 'Centro Logístico Barranquilla',
      'distance': 120,
      'estimatedTime': '2h 30min',
      'departureTime': '2025-05-31T08:00:00',
      'arrivalTime': '2025-05-31T10:30:00',
      'stops': 3,
      'orders': ['ORD-001', 'ORD-005'],
      'progress': 65,
      'currentLocation': {
        'latitude': 10.9878,
        'longitude': -74.7889,
        'lastUpdate': '2025-05-31T09:15:00'
      }
    },
    {
      'id': 'RUT-002',
      'name': 'Ruta Medellín - Bogotá',
      'status': 'Programada',
      'driver': 'Laura Gómez',
      'vehicle': 'Furgoneta - GHI789',
      'startLocation': 'Centro de Distribución Medellín',
      'endLocation': 'Centro Logístico Bogotá',
      'distance': 415,
      'estimatedTime': '8h 15min',
      'departureTime': '2025-06-01T06:00:00',
      'arrivalTime': '2025-06-01T14:15:00',
      'stops': 5,
      'orders': ['ORD-003', 'ORD-004'],
      'progress': 0,
      'currentLocation': null
    },
    {
      'id': 'RUT-003',
      'name': 'Ruta Santa Marta - Cartagena',
      'status': 'Activa',
      'driver': 'Miguel Díaz',
      'vehicle': 'Camión - DEF456',
      'startLocation': 'Centro de Distribución Santa Marta',
      'endLocation': 'Centro Logístico Cartagena',
      'distance': 235,
      'estimatedTime': '4h 45min',
      'departureTime': '2025-05-31T07:30:00',
      'arrivalTime': '2025-05-31T12:15:00',
      'stops': 2,
      'orders': ['ORD-002'],
      'progress': 80,
      'currentLocation': {
        'latitude': 10.4195,
        'longitude': -75.5270,
        'lastUpdate': '2025-05-31T11:30:00'
      }
    },
    {
      'id': 'RUT-004',
      'name': 'Ruta Barranquilla - Santa Marta',
      'status': 'Completada',
      'driver': 'Ana Martínez',
      'vehicle': 'Furgoneta - ABC789',
      'startLocation': 'Centro de Distribución Barranquilla',
      'endLocation': 'Centro Logístico Santa Marta',
      'distance': 100,
      'estimatedTime': '2h 00min',
      'departureTime': '2025-05-30T14:00:00',
      'arrivalTime': '2025-05-30T16:00:00',
      'stops': 1,
      'orders': ['ORD-006'],
      'progress': 100,
      'currentLocation': null
    },
    {
      'id': 'RUT-005',
      'name': 'Ruta Bogotá - Medellín',
      'status': 'Cancelada',
      'driver': 'Roberto Sánchez',
      'vehicle': 'Camión - JKL012',
      'startLocation': 'Centro de Distribución Bogotá',
      'endLocation': 'Centro Logístico Medellín',
      'distance': 415,
      'estimatedTime': '8h 15min',
      'departureTime': '2025-05-29T05:00:00',
      'arrivalTime': '2025-05-29T13:15:00',
      'stops': 4,
      'orders': ['ORD-007', 'ORD-008'],
      'progress': 0,
      'currentLocation': null
    },
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return Colors.blue;
      case 'programada':
        return Colors.purple;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showRouteDetails(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Ruta'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(route['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    route['status'],
                    style: TextStyle(
                      color: _getStatusColor(route['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                _buildDetailRow('ID', route['id']),
                _buildDetailRow('Conductor', route['driver']),
                _buildDetailRow('Vehículo', route['vehicle']),
                _buildDetailRow('Origen', route['startLocation']),
                _buildDetailRow('Destino', route['endLocation']),
                _buildDetailRow('Distancia', '${route['distance']} km'),
                _buildDetailRow('Tiempo estimado', route['estimatedTime']),
                _buildDetailRow('Salida', _formatDateTime(route['departureTime'])),
                _buildDetailRow('Llegada estimada', _formatDateTime(route['arrivalTime'])),
                _buildDetailRow('Paradas', route['stops'].toString()),
                _buildDetailRow('Pedidos', route['orders'].join(', ')),
                
                SizedBox(height: 20),
                Text('Progreso de la Ruta', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: route['progress'] / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(route['status'])),
                  minHeight: 10,
                ),
                SizedBox(height: 4),
                Text('${route['progress']}%'),
                
                SizedBox(height: 20),
                if (route['currentLocation'] != null) ...[
                  Text('Ubicación Actual', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text(
                            'Mapa de ubicación',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Lat: ${route['currentLocation']['latitude']}, Long: ${route['currentLocation']['longitude']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Última actualización: ${_formatDateTime(route['currentLocation']['lastUpdate'])}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
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
                      icon: Icon(Icons.map),
                      label: Text('Ver Mapa'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la navegación a la pantalla de mapa
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

  Widget _buildDetailRow(String label, String value) {
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
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredRoutes() {
    if (filterStatus == 'Todas') {
      return routes;
    } else {
      return routes.where((route) => route['status'] == filterStatus).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _getFilteredRoutes();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Rutas'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchRoutes,
            tooltip: 'Actualizar rutas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar rutas...',
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
                        // Implementar filtros adicionales
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todas'),
                      _buildFilterChip('Activa'),
                      _buildFilterChip('Programada'),
                      _buildFilterChip('Completada'),
                      _buildFilterChip('Cancelada'),
                    ],
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
          
          // Estadísticas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Total', routes.length.toString(), Colors.blue),
                _buildStatCard(
                  'Activas', 
                  routes.where((r) => r['status'] == 'Activa').length.toString(),
                  Colors.green
                ),
                _buildStatCard(
                  'Programadas', 
                  routes.where((r) => r['status'] == 'Programada').length.toString(),
                  Colors.purple
                ),
              ],
            ),
          ),
          
          // Lista de rutas
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredRoutes.isEmpty
                    ? Center(child: Text('No hay rutas disponibles'))
                    : ListView.builder(
                        itemCount: filteredRoutes.length,
                        itemBuilder: (context, index) {
                          final route = filteredRoutes[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          route['name'],
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(route['status']).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          route['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(route['status']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 16, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(route['driver']),
                                          SizedBox(width: 16),
                                          Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(route['vehicle'].split(' - ')[0]),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Expanded(child: Text('${route['startLocation']} → ${route['endLocation']}')),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, size: 16, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(_formatDateTime(route['departureTime'])),
                                          Text(' - '),
                                          Text(_formatDateTime(route['arrivalTime'])),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: route['progress'] / 100,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(route['status'])),
                                        minHeight: 6,
                                      ),
                                      SizedBox(height: 4),
                                      Text('Progreso: ${route['progress']}%'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () => _showRouteDetails(route),
                                  ),
                                  onTap: () => _showRouteDetails(route),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar creación de nueva ruta
        },
        backgroundColor: Colors.blueGrey[700],
        child: Icon(Icons.add),
        tooltip: 'Nueva ruta',
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = filterStatus == status;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            filterStatus = status;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blueGrey[100],
        checkmarkColor: Colors.blueGrey[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blueGrey[700] : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
