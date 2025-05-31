import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackingScreen extends StatefulWidget {
  final String? orderId;
  
  const TrackingScreen({Key? key, this.orderId} ) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
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
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/tracking/$orderId' ),
      ).timeout(Duration(seconds: 5));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento de Pedido'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese número de pedido...',
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
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      fetchTrackingData(searchController.text);
                    }
                  },
                  child: Text('Buscar'),
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
          
          // Contenido principal
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : trackingData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Ingrese un número de pedido para rastrear',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
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
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pedido ${trackingData!['orderId']}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                    Divider(height: 24),
                                    _buildInfoRow(Icons.person, 'Cliente', trackingData!['customer']),
                                    _buildInfoRow(Icons.location_on, 'Origen', trackingData!['origin']),
                                    _buildInfoRow(Icons.flag, 'Destino', trackingData!['destination']),
                                    _buildInfoRow(Icons.calendar_today, 'Entrega estimada', trackingData!['estimatedDelivery']),
                                    _buildInfoRow(Icons.my_location, 'Ubicación actual', trackingData!['currentLocation']),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Información del conductor
                            Text(
                              'Información del Conductor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
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
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trackingData!['driver']['name'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                trackingData!['driver']['vehicle'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.phone, size: 16, color: Colors.green),
                                                  SizedBox(width: 4),
                                                  Text(trackingData!['driver']['phone']),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.message),
                                          label: Text('Contactar'),
                                          onPressed: () {
                                            // Implementar contacto
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
                            
                            SizedBox(height: 24),
                            
                            // Mapa (simulado)
                            Text(
                              'Ubicación del Envío',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
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
                                    Icon(Icons.map, size: 48, color: Colors.grey[600]),
                                    SizedBox(height: 8),
                                    Text(
                                      'Mapa de ubicación',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Lat: ${trackingData!['map']['currentLatitude']}, Long: ${trackingData!['map']['currentLongitude']}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Historial de eventos
                            Text(
                              'Historial de Seguimiento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: trackingData!['events'].length,
                              itemBuilder: (context, index) {
                                final event = trackingData!['events'][index];
                                final isLast = index == 0;
                                final isFirst = index == trackingData!['events'].length - 1;
                                
                                return Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: isLast ? Colors.green : Colors.grey,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                          if (!isFirst)
                                            Container(
                                              width: 2,
                                              height: 70,
                                              color: Colors.grey[300],
                                            ),
                                        ],
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDateTime(event['timestamp']),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              event['status'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isLast ? Colors.green : Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(event['location']),
                                            SizedBox(height: 4),
                                            Text(
                                              event['description'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
