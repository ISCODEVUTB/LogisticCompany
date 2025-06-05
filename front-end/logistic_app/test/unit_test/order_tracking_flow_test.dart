import 'dart:io'; // For HttpOverrides
// Removed: import 'dart:async';
// Removed: import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert'; // For json.encode

// Import the generated mocks and mock http client classes from screen_navigation_test
import 'backend_integration_test.mocks.dart';
import 'screen_navigation_test.dart'; // This now contains MockHttpClient etc.
import 'mock_utils.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  testWidgets('Flujo completo de tracking de pedido', (WidgetTester tester) async {
    setupCommonMocks(mockClient);
    const String testOrderId = 'ORD-MOCK-TRACK';
    final mockOrder = {
      'id': testOrderId,
      'customer': 'Cliente de Tracking',
      'destination': 'Destino Tracking',
      'status': 'En tránsito',
      'date': '2025-07-03',
      'items': 1,
      'total': 150,
      'driver': 'Conductor Tracking',
      'estimatedDelivery': '2025-07-05'
    };

    // Mock for Dashboard
    when(mockClient.get(Uri.parse('http://localhost:8000/api/dashboard')))
        .thenAnswer((_) async => http.Response(
            '{"pedidos": {"total": 1, "enTransito": 1}, "conductores": {"disponibles": 1, "asignados": 1}, "rutas": {"activas": 1}, "tracking": {"eventos": 1}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'}));

    // Mock for OrdersScreen to display the order we want to track
    when(mockClient.get(Uri.parse('http://localhost:8000/api/orders')))
        .thenAnswer((_) async {
          debugPrint('Test: Orders mock called for tracking flow (returning one order).');
          return http.Response(json.encode([mockOrder]), 200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        });

    // Mock for TrackingScreen API call
    when(mockClient.get(Uri.parse('http://localhost:8000/api/tracking/$testOrderId')))
        .thenAnswer((_) async {
          debugPrint('Test: Tracking mock called for $testOrderId');
          return http.Response(
              json.encode({
                'orderId': testOrderId,
                'customer': 'Cliente de Tracking', // from mockOrder for consistency
                'status': 'En Bodega Central', // Specific status for tracking
                'origin': 'Origen Tracking',
                'destination': 'Destino Tracking',
                'estimatedDelivery': '2025-07-05',
                'currentLocation': 'Bodega Central City',
                'driver': {
                  'name': 'Conductor Tracking',
                  'phone': '+57 300 000 0000',
                  'vehicle': 'TrackMobile - TRK123'
                },
                'events': [
                  {'timestamp': '2025-07-03T10:00:00Z', 'status': 'Pedido Recibido', 'location': 'Origen', 'description': 'Pedido registrado.'},
                  {'timestamp': '2025-07-03T12:00:00Z', 'status': 'En Bodega Central', 'location': 'Bodega Central City', 'description': 'Procesando en bodega.'}
                ],
                'map': {'currentLatitude': 10.0, 'currentLongitude': -75.0, 'destinationLatitude': 10.1, 'destinationLongitude': -75.1}
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        });
    
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(LogisticDashboardApp(client: mockClient));
      await tester.pumpAndSettle();

      // Navegar a la pantalla de Pedidos
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      // Tap the order to open details dialog
      // The ListTile title is '${order['id']} - ${order['customer']}'
      expect(find.text('$testOrderId - Cliente de Tracking'), findsOneWidget);
      await tester.tap(find.text('$testOrderId - Cliente de Tracking'));
      await tester.pumpAndSettle(); // Dialog opens
      await tester.pump(); // Process pending frames
      await tester.pumpAndSettle(); // Settle again to ensure dialog is fully rendered

      // Tap the "Rastrear" button in the dialog
      // First, let's ensure the text "Rastrear" is even found
      expect(find.text('Rastrear'), findsOneWidget, reason: "The text 'Rastrear' should be present in the dialog.");

      // Using bySubtype<ButtonStyleButton> as it was able to identify the _ElevatedButtonWithIcon
      final rastrearButtonFinder = find.ancestor(
        of: find.text('Rastrear'),
        matching: find.bySubtype<ButtonStyleButton>(),
      );

      expect(rastrearButtonFinder, findsOneWidget, reason: "The 'Rastrear' ButtonStyleButton (ElevatedButton) should be found.");

      // Ensure the button is visible and pump after to settle any UI changes from scrolling.
      await tester.ensureVisible(rastrearButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(rastrearButtonFinder);
      await tester.pumpAndSettle(); // Navigates to TrackingScreen, TrackingScreen.initState calls fetchTrackingData

      // Verify we are on the TrackingScreen and data is displayed
      // TrackingScreen AppBar title is static: 'Seguimiento de Pedido'
      // The content shows 'Pedido ${trackingData!['orderId']}'
      expect(find.text('Seguimiento de Pedido'), findsOneWidget);
      expect(find.text('Pedido $testOrderId'), findsOneWidget);
      // There are two instances of "En Bodega Central" (main status and an event status)
      expect(find.text('En Bodega Central'), findsWidgets); // Status from tracking mock
      expect(find.textContaining('Cliente de Tracking', findRichText: true), findsOneWidget);
      expect(find.text('Procesando en bodega.'), findsOneWidget); // From history event

    }, createHttpClient: (_) => MockHttpClient()); // Use the same image mocking HttpOverrides
  });
}
