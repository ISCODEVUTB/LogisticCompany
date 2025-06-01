// En backend_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generar el mock
@GenerateMocks([http.Client] )
import 'backend_integration_test.mocks.dart';

void main() {
  late MockClient mockClient;
  
  setUp(() {
    mockClient = MockClient();
  });
  
  testWidgets('Carga datos de pedidos desde API', (WidgetTester tester) async {
    // Configurar respuesta mock CORRECTAMENTE
    when(mockClient.get(any))
        .thenAnswer((_) async => http.Response('''
          [
            {"id": "1", "client": "Cliente A", "origin": "Cartagena", "destination": "Barranquilla", "status": "En tránsito"},
            {"id": "2", "client": "Cliente B", "origin": "Bogotá", "destination": "Medellín", "status": "Entregado"}
          ]
        ''', 200 ));
    
    // Construir app con cliente HTTP mockeado
    // Aquí necesitarías una forma de inyectar el mockClient en tu app
    
    // Navegar a la pantalla de Pedidos
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    
    // Verificar que los datos de la API se muestran correctamente
    expect(find.text('Cliente A'), findsOneWidget);
    expect(find.text('Cliente B'), findsOneWidget);
    expect(find.text('En tránsito'), findsOneWidget);
    expect(find.text('Entregado'), findsOneWidget);
  });
}
