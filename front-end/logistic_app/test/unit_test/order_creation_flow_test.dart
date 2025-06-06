import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert'; // For json.encode

// Import the generated mocks
import 'backend_integration_test.mocks.dart'; // Assuming MockClient is here

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  testWidgets('Flujo completo de creación de pedido', (WidgetTester tester) async {
    // Data for the new order that will be "created"
    final newOrderData = {
      'id': 'ORD-MOCK-NEW',
      'customer': 'Cliente Ejemplo',
      'origin': 'Cartagena', // Not directly displayed in list, but good for consistency
      'destination': 'Barranquilla', // Displayed in list via Text('Destino: ${order['destination']}')
      'package': {'weight': 25.0}, // From form
      'status': 'Pendiente', // Default from dialog
      'date': DateTime.now().toIso8601String().substring(0,10), // Default from dialog
      'items': 1, // Default from dialog
      'driver': 'Pendiente asignación', // Default from dialog
      'estimatedDelivery': DateTime.now().add(const Duration(days:3)).toIso8601String().substring(0,10) // Default
    };

    // Mock GET for order list to return the list *including* the new order from the start.
    // This simplifies the test; the list will appear "pre-populated" with the order that's about to be "created".
    // Or, more accurately, after creation and refresh, this is what should be fetched.
    when(mockClient.get(Uri.parse('http://localhost:8000/api/orders')))
        .thenAnswer((_) async {
          debugPrint('Mock GET /api/orders called, returning list with new order.');
          return http.Response(json.encode([newOrderData]), 200, headers: {'content-type': 'application/json; charset=utf-8'});
        });
    
    // Mock successful GET for dashboard (called by DashboardScreen)
    when(mockClient.get(Uri.parse('http://localhost:8000/api/dashboard')))
        .thenAnswer((_) async => http.Response('{"pedidos": {"total": 1, "enTransito": 0}, "conductores": {"disponibles": 0, "asignados": 0}, "rutas": {"activas": 0}, "tracking": {"eventos": 0}}', 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Mock successful POST for order creation
    when(mockClient.post(
      Uri.parse('http://localhost:8000/api/orders'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
      encoding: anyNamed('encoding'),
    )).thenAnswer((invocation) async {
      debugPrint('Mock POST /api/orders called with body: ${invocation.namedArguments[const Symbol('body')]}');
      // The POST mock now returns the exact newOrderData, simulating backend confirmation
      return http.Response(
        json.encode(newOrderData),
        201, // HTTP 201 Created
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    });

    await tester.pumpWidget(LogisticDashboardApp(client: mockClient));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byTooltip('Nuevo Pedido'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byKey(const Key('input_cliente')), 'Cliente Ejemplo');
    await tester.enterText(find.byKey(const Key('input_origen')), 'Cartagena');
    await tester.enterText(find.byKey(const Key('input_destino')), 'Barranquilla');
    await tester.enterText(find.byKey(const Key('input_peso')), '25');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('guardar_button')));
    // Important: pumpAndSettle may not be enough if SnackBar animations are long.
    // Let's try a couple of pumps after the SnackBar is expected.
    await tester.pump(); // Start SnackBar display
    await tester.pump(const Duration(seconds: 1)); // SnackBar visible
    await tester.pumpAndSettle(); // SnackBar gone, list refreshed

    expect(find.text('Pedido creado correctamente'), findsOneWidget);
    
    // OrderScreen's ListTile shows: '${order['id']} - ${order['customer']}'
    // and 'Destino: ${order['destination']}'
    expect(find.text('ORD-MOCK-NEW - Cliente Ejemplo'), findsOneWidget);
    expect(find.textContaining('Destino: Barranquilla'), findsOneWidget);
  });
}

