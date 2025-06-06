// Removed: import 'dart:async';
import 'dart:io'; // For HttpOverrides
// Removed: import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert'; // For json.encode

// Import the generated mocks and mock http client classes
import 'backend_integration_test.mocks.dart'; // MockClient
// Assuming MockHttpClient classes are defined in screen_navigation_test.dart or a shared test utility file.
// For this example, I'll copy them here if they are not automatically available via an import.
// If they ARE in screen_navigation_test.dart, this import is fine.
import 'screen_navigation_test.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  testWidgets('Asignación de conductor a ruta', (WidgetTester tester) async {
    const routeIdToAssign = "RUT-001";
    const routeNameToFind = "Ruta #$routeIdToAssign"; // Used in find.text()
    const driverToSelectId = "DRV-JP";
    const driverToSelectName = "Juan Test Driver"; // Changed for clarity

    // 1. Initial Dashboard load
    when(mockClient.get(Uri.parse('http://localhost:8000/api/dashboard')))
        .thenAnswer((_) async => http.Response('{"pedidos": {"total": 0}, "conductores": {"disponibles": 1}, "rutas": {"activas": 1}, "tracking": {"eventos": 0}}', 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // 2. Mock GET /api/routes calls using a counter
    int getRoutesCallCount = 0;
    when(mockClient.get(Uri.parse('http://localhost:8000/api/routes')))
        .thenAnswer((_) async {
          getRoutesCallCount++;
          if (getRoutesCallCount == 1) { // First call (initial load)
            debugPrint('Test: GET /api/routes (initial load) mock called');
            return http.Response(json.encode([{
                "id": routeIdToAssign, "name": routeNameToFind,
                "driver": null, "vehicle": null, // Initially no driver/vehicle
                "status": "Programada", "departureTime": "2025-08-01T10:00:00Z", "progress": 0,
                "startLocation": "Bodega Central", "endLocation": "Cliente Final",
                "distance": 150, "estimatedTime": "3 horas", // distance as number
                "arrivalTime": "2025-08-01T13:00:00Z", "stops": 2, // stops as number
                "orders": ["ORD-101", "ORD-102"], "currentLocation": null
            }]), 200, headers: {'content-type': 'application/json; charset=utf-8'});
          } else { // Second call (after assignment)
            debugPrint('Test: GET /api/routes (after assignment) mock called');
            return http.Response(json.encode([{
                "id": routeIdToAssign, "name": routeNameToFind,
                "driver": driverToSelectName, "vehicle": "Vehiculo Asignado Test",
                "status": "Asignada", "departureTime": "2025-08-01T10:00:00Z", "progress": 0,
                "startLocation": "Bodega Central", "endLocation": "Cliente Final",
                "distance": 150, "estimatedTime": "3 horas",
                "arrivalTime": "2025-08-01T13:00:00Z", "stops": 2,
                "orders": ["ORD-101", "ORD-102"], "currentLocation": null
            }]), 200, headers: {'content-type': 'application/json; charset=utf-8'});
          }
        });

    // 3. Load available drivers for selection dialog
    when(mockClient.get(Uri.parse('http://localhost:8000/api/drivers?status=Disponible')))
        .thenAnswer((_) async {
          debugPrint('Test: GET /api/drivers?status=Disponible called');
          return http.Response(
            json.encode([
              {"id": driverToSelectId, "name": driverToSelectName, "status": "Disponible", "photo": "https://randomuser.me/api/portraits/men/1.jpg"},
              {"id": "DRV-002", "name": "Maria Garcia", "status": "Disponible", "photo": "https://randomuser.me/api/portraits/women/1.jpg"}
            ]),
            200, headers: {'content-type': 'application/json; charset=utf-8'});
        });
    
    // 4. Mock PATCH request for assigning driver
    when(mockClient.patch(
      Uri.parse('http://localhost:8000/api/routes/$routeIdToAssign/assign-driver'),
      headers: {'Content-Type': 'application/json; charset=utf-8'}, // More specific header match
      body: json.encode({'driver_id': driverToSelectId}),
    )).thenAnswer((_) async {
      debugPrint('Test: PATCH /api/routes/$routeIdToAssign/assign-driver called with correct body');
      return http.Response(json.encode({"message": "Driver assigned"}), 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });


    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(LogisticDashboardApp(client: mockClient));
      await tester.pumpAndSettle();

      debugPrint('Test: Navigating to Routes screen...');
      await tester.tap(find.text('Rutas'));
      await tester.pumpAndSettle(); // RoutesScreen loads initial routes

      debugPrint('Test: Tapping route: $routeNameToFind');
      expect(find.text(routeNameToFind), findsOneWidget);
      await tester.tap(find.text(routeNameToFind));
      await tester.pumpAndSettle(); // Details dialog opens

      debugPrint('Test: Tapping "Asignar Conductor" button...');
      expect(find.widgetWithText(ElevatedButton, 'Asignar Conductor'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Asignar Conductor'));
      await tester.pumpAndSettle(); // Driver selection dialog opens, drivers are fetched

      debugPrint('Test: Verifying driver selection dialog and selecting driver: $driverToSelectName');
      expect(find.text('Seleccionar Conductor'), findsOneWidget);
      expect(find.text(driverToSelectName), findsOneWidget);
      await tester.tap(find.text(driverToSelectName));
      await tester.pumpAndSettle(); // Driver selected, dialog closes, PATCH is made, SnackBar appears

      debugPrint('Test: Verifying SnackBar and route list refresh...');
      // SnackBar and list refresh
      await tester.pump(); // Start SnackBar animation
      await tester.pump(const Duration(seconds: 1)); // SnackBar visible
      await tester.pumpAndSettle(); // SnackBar gone, list refreshed

      expect(find.text('Conductor asignado correctamente'), findsOneWidget);

      // Verify the driver appears in the refreshed route list
      // The ListTile subtitle in RoutesScreen is: Text('Conductor: ${route['driver']} | Vehículo: ${route['vehicle']}')
      debugPrint('Test: Verifying updated route list contains driver: $driverToSelectName');
      expect(find.textContaining('Conductor: $driverToSelectName', findRichText: true), findsOneWidget);
      expect(find.textContaining('Vehículo: Vehiculo Asignado Test', findRichText: true), findsOneWidget);

    }, createHttpClient: (_) => MockHttpClient());
  });
}
