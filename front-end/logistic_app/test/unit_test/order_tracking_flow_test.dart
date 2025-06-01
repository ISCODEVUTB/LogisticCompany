import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';

void main() {
  testWidgets('Flujo completo de tracking de pedido', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const LogisticDashboardApp());
    await tester.pumpAndSettle();
    
    // Navegar a la pantalla de Pedidos
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    
    // Buscar un pedido específico
    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    
    // Tap en el botón de tracking del pedido
    await tester.tap(find.byIcon(Icons.track_changes).first);
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla de tracking
    expect(find.text('Seguimiento de Pedido #12345'), findsOneWidget);
    
    // Verificar que se muestran los detalles del tracking
    expect(find.text('Estado actual:'), findsOneWidget);
    expect(find.text('Información del conductor'), findsOneWidget);
    expect(find.text('Ubicación del Pedido'), findsOneWidget);
    expect(find.text('Historial de Eventos'), findsOneWidget);
  });
}

