import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackingScreen extends StatefulWidget {
  final String? orderId;
  
  const TrackingScreen({super.key, this.orderId} );

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool isLoading = true;
  Map<String, dynamic>? trackingData;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      searchController.text = widget.orderId!;
      fetchTrackingData(widget.orderId!);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTrackingData(String orderId) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Intenta obtener datos del backend
      final response = await http.get(Uri.parse('http://localhost:8000/api/tracking/$orderId'));

      if (response.statusCode == 200) {
        setState(() {
          trackingData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Si hay error, usar datos de muestra
        setState(() {
          trackingData = getSampleTrackingData(orderId);
          isLoading = false;
          errorMessage = 'No se pudieron cargar los datos del servidor. Mostrando datos de muestra.';
        });
      }
    } catch (e) {
      // En caso de error de conexión, usar datos de muestra
      setState(() {
        trackingData = getSampleTrackingData(orderId);
        isLoading = false;
        errorMessage = 'Error de conexión: $e. Mostrando datos de muestra.';
      });
    }
  }

  Map<String, dynamic> getSampleTrackingData(String orderId) {
    // Datos de muestra para desarrollo
    return {
      'orderId': orderId,
      'customer': 'Cliente de Ejemplo',
      'status': 'En tránsito',
      'origin': 'Centro de Distribución Cartagena',
      'destination': 'Calle Principal 123, Barranquilla',
      'estimatedDelivery': '2025-06-02',
      'currentLocation': 'Barranquilla, en ruta de entrega',
      'driver': {
        'name': 'Carlos Rodríguez',
        'phone': '+57 300 123 4567',
        'vehicle': 'Camión - XYZ123'
      },
      'events': [
        {
          'timestamp': '2025-05-31T10:00:00',
          'status': 'Pedido recibido',
          'location': 'Sistema en línea',
          'description': 'Pedido registrado en el sistema'
        },
        {
          'timestamp': '2025-05-31T14:30:00',
          'status': 'En preparación',
          'location': 'Centro de Distribución Cartagena',
          'description': 'Pedido en proceso de preparación'
        },
        {
          'timestamp': '2025-05-31T16:45:00',
          'status': 'Enviado',
          'location': 'Centro de Distribución Cartagena',
          'description': 'Pedido enviado con el conductor'
        },
        {
          'timestamp': '2025-05-31T18:20:00',
          'status': 'En tránsito',
          'location': 'Barranquilla',
          'description': 'Pedido en ruta de entrega'
        }
      ],
      'map': {
        'currentLatitude': 10.9878,
        'currentLongitude': -74.7889,
        'destinationLatitude': 10.9632,
        'destinationLongitude': -74.7964
      }
    };
  }

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return Colors.green;
      case 'en tránsito':
        return Colors.blue;
      case 'en preparación':
        return Colors.purple;
      case 'enviado':
        return Colors.orange;
      case 'pedido recibido':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['status'],
                    style: TextStyle(
                      color: _getStatusColor(event['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(event['timestamp']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['location'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(event['description']),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Pedido'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese número de pedido...',
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
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      fetchTrackingData(searchController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Buscar'),
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
          
          // Contenido principal
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : trackingData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Ingrese un número de pedido para rastrear',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de información general
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pedido ${trackingData!['orderId']}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(trackingData!['status']).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            trackingData!['status'],
                                            style: TextStyle(
                                              color: _getStatusColor(trackingData!['status']),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _buildInfoRow(Icons.person, 'Cliente', trackingData!['customer']),
                                    _buildInfoRow(Icons.location_on, 'Origen', trackingData!['origin']),
                                    _buildInfoRow(Icons.flag, 'Destino', trackingData!['destination']),
                                    _buildInfoRow(Icons.calendar_today, 'Entrega estimada', trackingData!['estimatedDelivery']),
                                    _buildInfoRow(Icons.my_location, 'Ubicación actual', trackingData!['currentLocation']),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Información del conductor
                            const Text(
                              'Información del Conductor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.blueGrey[100],
                                          child: Icon(
                                            Icons.person,
                                            size: 36,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trackingData!['driver']['name'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                trackingData!['driver']['vehicle'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone, size: 16, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text(trackingData!['driver']['phone']),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Implementar llamada al conductor
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: const Icon(Icons.phone, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Mapa de seguimiento
                            const Text(
                              'Ubicación del Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.map, size: 48, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Mapa de seguimiento',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Lat: ${trackingData!['map']['currentLatitude']}, Long: ${trackingData!['map']['currentLongitude']}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Historial de eventos
                            const Text(
                              'Historial de Eventos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              trackingData!['events'].length,
                              (index) => _buildEventCard(trackingData!['events'][index]),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
