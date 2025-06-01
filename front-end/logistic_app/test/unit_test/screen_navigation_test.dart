import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';

void main() {
  testWidgets('Navegación entre pantallas funciona correctamente', (WidgetTester tester) async {
    // Construir la aplicación completa
    await tester.pumpWidget(const LogisticDashboardApp());
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla Dashboard inicialmente
    expect(find.text('Panel de Gestión Logística'), findsOneWidget);
    
    // Navegar a la pantalla de Pedidos
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla de Pedidos
    expect(find.text('Gestión de Pedidos'), findsOneWidget);
    
    // Navegar a la pantalla de Conductores
    await tester.tap(find.text('Conductores'));
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla de Conductores
    expect(find.text('Gestión de Conductores'), findsOneWidget);
    
    // Navegar a la pantalla de Rutas
    await tester.tap(find.text('Rutas'));
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla de Rutas
    expect(find.text('Gestión de Rutas'), findsOneWidget);
    
    // Navegar a la pantalla de Tracking
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();
    
    // Verificar que estamos en la pantalla de Tracking
    expect(find.text('Seguimiento de Pedidos'), findsOneWidget);
  });
}
