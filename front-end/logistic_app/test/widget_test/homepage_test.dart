import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/homepage.dart';

void main() {
  testWidgets('Dashboard screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

    // Verify that the title is displayed
    expect(find.text('Panel de Gestión Logística'), findsOneWidget);
    
    // Verify that the navigation panel is displayed
    expect(find.text('Menú'), findsOneWidget);
    
    // Verify that menu items are displayed
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Conductores'), findsOneWidget);
    expect(find.text('Rutas'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    
    // Verify that info cards are displayed
    expect(find.text('Pedidos Activos'), findsOneWidget);
    expect(find.text('Conductores Disponibles'), findsOneWidget);
    expect(find.text('Rutas en Curso'), findsOneWidget);
    expect(find.text('Eventos de Tracking'), findsOneWidget);
  });
}
