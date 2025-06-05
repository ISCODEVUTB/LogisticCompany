import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart'; // For debugPrint
import 'backend_integration_test.mocks.dart';

void setupCommonMocks(MockClient mockClient) {
  // Primary mock for the main dashboard endpoint
  when(mockClient.get(Uri.parse('http://localhost:8000/api/dashboard')))
      .thenAnswer((_) async {
    debugPrint('Test Util: /api/dashboard mock was called!');
    return http.Response(
        '{"pedidos": {"total": 10, "enTransito": 5}, "conductores": {"disponibles": 3, "asignados": 2}, "rutas": {"activas": 2}, "tracking": {"eventos": 8}}', // Generic positive data
        200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  });

  // Mock for dashboard_disabled endpoint - now a fallback or error state
  when(mockClient.get(Uri.parse('http://localhost:8000/api/dashboard_disabled')))
      .thenAnswer((_) async {
    debugPrint('Test Util: /api/dashboard_disabled mock was called!');
    return http.Response(
        '{"message": "Dashboard is currently in a disabled or fallback state.", "pedidos": {"total": 0, "enTransito": 0}, "conductores": {"disponibles": 0, "asignados": 0}, "rutas": {"activas": 0}, "tracking": {"eventos": 0}}',
        200, // Or a relevant error code like 503 Service Unavailable, if the app handles it
        headers: {'content-type': 'application/json; charset=utf-8'});
  });
}
