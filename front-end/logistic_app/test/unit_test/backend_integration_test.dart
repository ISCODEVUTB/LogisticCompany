import 'package:flutter/material.dart'; // Required for MaterialApp
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:logistic_company_web/screens/orders_screen.dart'; // Direct import for OrdersScreen

// Generar el mock
@GenerateMocks([http.Client])
import 'backend_integration_test.mocks.dart';

void main() {
  late MockClient mockClient;
  
  setUp(() {
    mockClient = MockClient();
  });
  
  testWidgets('Carga datos de pedidos desde API', (WidgetTester tester) async {
    // Configurar respuesta mock CORRECTAMENTE
    when(mockClient.get(Uri.parse('http://localhost:8000/api/orders')))
        .thenAnswer((_) async => http.Response(
            '[{"id": "ORD-001", "customer": "Pedido Test 1", "destination": "Destino 1", "status": "Entregado", "date": "2025-06-01", "items": 1, "total": 100, "driver": "Driver 1", "estimatedDelivery": "2025-06-02"}, {"id": "ORD-002", "customer": "Pedido Test 2", "destination": "Destino 2", "status": "En camino", "date": "2025-06-01", "items": 1, "total": 100, "driver": "Driver 2", "estimatedDelivery": "2025-06-02"}]',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'}));
    
    // Pump the OrdersScreen directly, providing the mockClient
    await tester.pumpWidget(MaterialApp(home: OrdersScreen(client: mockClient)));
    
    // Wait for UI to settle after fetching data
    await tester.pumpAndSettle();
    
    // Verificar que los datos de la API se muestran correctamente
    // Note: The OrdersScreen uses 'customer' for the client's name from the JSON.
    // The ListTile title in OrdersScreen combines id and customer: '${order['id']} - ${order['customer']}'
    expect(find.text('ORD-001 - Pedido Test 1'), findsOneWidget);
    expect(find.text('ORD-002 - Pedido Test 2'), findsOneWidget);
    // We can also check for other details if they are displayed directly, e.g., status
    // The status is displayed in a Container within the ListTile
    expect(find.text('Entregado'), findsOneWidget); // Status of Pedido Test 1
    expect(find.text('En camino'), findsOneWidget); // Status of Pedido Test 2
  });
}
