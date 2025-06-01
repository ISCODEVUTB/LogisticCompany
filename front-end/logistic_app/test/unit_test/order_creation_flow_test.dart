import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';
import 'package:mockito/mockito.dart';
// Importar los mocks necesarios

void main() {
  testWidgets('Flujo completo de creación de pedido', (WidgetTester tester) async {
    // Configurar mocks para servicios
    // final mockOrderService = MockOrderService();
    // when(mockOrderService.createOrder(any)).thenAnswer((_) async => {'id': '12345', 'status': 'created'});
    
    // Construir la aplicación con dependencias inyectadas
    await tester.pumpWidget(const LogisticDashboardApp());
    await tester.pumpAndSettle();
    
    // Navegar a la pantalla de Pedidos
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    
    // Tap en botón "Nuevo Pedido"
    await tester.tap(find.text('Nuevo Pedido'));
    await tester.pumpAndSettle();
    
    // Rellenar formulario de pedido
    await tester.enterText(find.byKey(const Key('input_cliente')), 'Cliente Ejemplo');
    await tester.enterText(find.byKey(const Key('input_origen')), 'Cartagena');
    await tester.enterText(find.byKey(const Key('input_destino')), 'Barranquilla');
    await tester.enterText(find.byKey(const Key('input_peso')), '25');
    
    // Enviar formulario
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    
    // Verificar que se muestra mensaje de éxito
    expect(find.text('Pedido creado correctamente'), findsOneWidget);
    
    // Verificar que volvemos a la lista de pedidos y el nuevo pedido aparece
    expect(find.text('Cliente Ejemplo'), findsOneWidget);
    expect(find.text('Cartagena → Barranquilla'), findsOneWidget);
  });
}
