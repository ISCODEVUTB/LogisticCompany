import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriversScreen extends StatefulWidget {
  @override
  _DriversScreenState createState( ) => _DriversScreenState();
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
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/drivers' ),
      ).timeout(Duration(seconds: 5));

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
        title: Text('Detalles del Conductor'),
        content: Container(
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
                      SizedBox(height: 10),
                      Text(
                        driver['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
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
                SizedBox(height: 20),
                Divider(),
                _buildDetailRow('ID', driver['id']),
                _buildDetailRow('Vehículo', driver['vehicle']),
                _buildDetailRow('Teléfono', driver['phone']),
                _buildDetailRow('Email', driver['email']),
                _buildDetailRow('Ubicación actual', driver['currentLocation']),
                _buildDetailRow('Licencia válida hasta', driver['licenseExpiry']),
                _buildDetailRow('Fecha de ingreso', driver['joinDate']),
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
                      icon: Icon(Icons.phone),
                      label: Text('Llamar'),
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

  List<dynamic> _getFilteredDrivers() {
    if (filterStatus == 'Todos') {
      return drivers;
    } else {
      return drivers.where((driver) => driver['status'] == filterStatus).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrivers = _getFilteredDrivers();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Conductores'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchDrivers,
            tooltip: 'Actualizar conductores',
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
                          hintText: 'Buscar conductores...',
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
                ? Center(child: CircularProgressIndicator())
                : filteredDrivers.isEmpty
                    ? Center(child: Text('No hay conductores disponibles'))
                    : ListView.builder(
                        itemCount: filteredDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = filteredDrivers[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(driver['photo']),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      driver['name'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(driver['vehicle']),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(driver['currentLocation']),
                                      Spacer(),
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text('${driver['rating']}'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
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
        child: Icon(Icons.add),
        tooltip: 'Nuevo conductor',
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
