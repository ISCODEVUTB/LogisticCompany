import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriversScreen extends StatefulWidget {
  final http.Client? client;
  const DriversScreen({super.key, this.client});
  
  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  bool isLoading = true;
  List<dynamic> drivers = [];
  String errorMessage = '';
  String filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Intenta obtener datos del backend
      final response = widget.client != null
          ? await widget.client!.get(Uri.parse('http://localhost:8000/api/drivers'))
          : await http.get(Uri.parse('http://localhost:8000/api/drivers'));
      // Note: Timeout handling for injected client is simplified here, similar to OrdersScreen.

      if (response.statusCode == 200) {
        setState(() {
          drivers = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Si hay error, usar datos de muestra
        setState(() {
          drivers = sampleDrivers;
          isLoading = false;
          errorMessage = 'No se pudieron cargar los datos del servidor. Mostrando datos de muestra.';
        });
      }
    } catch (e) {
      // En caso de error de conexión, usar datos de muestra
      setState(() {
        drivers = sampleDrivers;
        isLoading = false;
        errorMessage = 'Error de conexión: $e. Mostrando datos de muestra.';
      });
    }
  }

  // Datos de muestra para desarrollo
  final List<dynamic> sampleDrivers = [
    {
      'id': 'DRV-001',
      'name': 'Carlos Rodríguez',
      'phone': '+57 300 123 4567',
      'email': 'carlos.rodriguez@logistic.com',
      'status': 'Disponible',
      'vehicle': 'Camión - XYZ123',
      'rating': 4.8,
      'completedDeliveries': 128,
      'currentLocation': 'Barranquilla',
      'licenseExpiry': '2026-05-15',
      'joinDate': '2023-03-10',
      'photo': 'https://randomuser.me/api/portraits/men/32.jpg'
    },
    {
      'id': 'DRV-002',
      'name': 'Ana Martínez',
      'phone': '+57 311 987 6543',
      'email': 'ana.martinez@logistic.com',
      'status': 'En ruta',
      'vehicle': 'Furgoneta - ABC789',
      'rating': 4.9,
      'completedDeliveries': 95,
      'currentLocation': 'Cartagena',
      'licenseExpiry': '2025-11-22',
      'joinDate': '2023-06-15',
      'photo': 'https://randomuser.me/api/portraits/women/44.jpg'
    },
    {
      'id': 'DRV-003',
      'name': 'Miguel Díaz',
      'phone': '+57 315 456 7890',
      'email': 'miguel.diaz@logistic.com',
      'status': 'En ruta',
      'vehicle': 'Camión - DEF456',
      'rating': 4.7,
      'completedDeliveries': 112,
      'currentLocation': 'Santa Marta',
      'licenseExpiry': '2026-02-28',
      'joinDate': '2023-01-20',
      'photo': 'https://randomuser.me/api/portraits/men/67.jpg'
    },
    {
      'id': 'DRV-004',
      'name': 'Laura Gómez',
      'phone': '+57 320 789 0123',
      'email': 'laura.gomez@logistic.com',
      'status': 'Disponible',
      'vehicle': 'Furgoneta - GHI789',
      'rating': 4.6,
      'completedDeliveries': 78,
      'currentLocation': 'Medellín',
      'licenseExpiry': '2025-09-10',
      'joinDate': '2023-08-05',
      'photo': 'https://randomuser.me/api/portraits/women/22.jpg'
    },
    {
      'id': 'DRV-005',
      'name': 'Roberto Sánchez',
      'phone': '+57 310 234 5678',
      'email': 'roberto.sanchez@logistic.com',
      'status': 'Descanso',
      'vehicle': 'Camión - JKL012',
      'rating': 4.5,
      'completedDeliveries': 145,
      'currentLocation': 'Bogotá',
      'licenseExpiry': '2026-07-18',
      'joinDate': '2022-11-12',
      'photo': 'https://randomuser.me/api/portraits/men/45.jpg'
    },
  ];

  Color _getStatusColor(String status ) {
    switch (status.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'en ruta':
        return Colors.blue;
      case 'descanso':
        return Colors.orange;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Conductor'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(driver['photo']),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        driver['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(driver['status']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          driver['status'],
                          style: TextStyle(
                            color: _getStatusColor(driver['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            ' ${driver['rating']} (${driver['completedDeliveries']} entregas)',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                _buildDetailRow('ID', driver['id']),
                _buildDetailRow('Vehículo', driver['vehicle']),
                _buildDetailRow('Teléfono', driver['phone']),
                _buildDetailRow('Email', driver['email']),
                _buildDetailRow('Ubicación actual', driver['currentLocation']),
                _buildDetailRow('Licencia válida hasta', driver['licenseExpiry']),
                _buildDetailRow('Fecha de ingreso', driver['joinDate']),
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
                      icon: const Icon(Icons.phone),
                      label: const Text('Llamar'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí iría la funcionalidad de llamada
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredDrivers() {
    if (filterStatus == 'Todos') {
      return drivers;
    } else {
      return drivers.where((driver) => driver['status'] == filterStatus).toList();
    }
  }

  Widget _buildFilterChip(String status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(status),
        selected: filterStatus == status,
        onSelected: (selected) {
          setState(() {
            filterStatus = status;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blueGrey[100],
        checkmarkColor: Colors.blueGrey[700],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrivers = _getFilteredDrivers();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Conductores'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDrivers,
            tooltip: 'Actualizar conductores',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar conductores...',
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
                        // Implementar filtros adicionales
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      _buildFilterChip('Disponible'),
                      _buildFilterChip('En ruta'),
                      _buildFilterChip('Descanso'),
                      _buildFilterChip('Inactivo'),
                    ],
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
          
          // Estadísticas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Total', drivers.length.toString(), Colors.blue),
                _buildStatCard(
                  'Disponibles', 
                  drivers.where((d) => d['status'] == 'Disponible').length.toString(),
                  Colors.green
                ),
                _buildStatCard(
                  'En ruta', 
                  drivers.where((d) => d['status'] == 'En ruta').length.toString(),
                  Colors.orange
                ),
              ],
            ),
          ),
          
          // Lista de conductores
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDrivers.isEmpty
                    ? const Center(child: Text('No hay conductores disponibles'))
                    : ListView.builder(
                        itemCount: filteredDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = filteredDrivers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(driver['photo']),
                              ),
                              title: Text(
                                driver['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('ID: ${driver['id']} | Vehículo: ${driver['vehicle']}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(driver['status']).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          driver['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(driver['status']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          Text(' ${driver['rating']}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => _showDriverDetails(driver),
                              ),
                              onTap: () => _showDriverDetails(driver),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar creación de nuevo conductor
        },
        backgroundColor: Colors.blueGrey[700],
        tooltip: 'Nuevo conductor',
        child: const Icon(Icons.add),
      ),
    );
  }
}
