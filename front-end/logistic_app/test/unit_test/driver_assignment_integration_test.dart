import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistic_company_web/main.dart';

void main() {
  testWidgets('Asignación de conductor a ruta', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const LogisticDashboardApp());
    await tester.pumpAndSettle();
    
    // Navegar a la pantalla de Rutas
    await tester.tap(find.text('Rutas'));
    await tester.pumpAndSettle();
    
    // Seleccionar una ruta
    await tester.tap(find.text('Ruta #R001').first);
    await tester.pumpAndSettle();
    
    // Tap en "Asignar Conductor"
    await tester.tap(find.text('Asignar Conductor'));
    await tester.pumpAndSettle();
    
    // Verificar que se muestra el diálogo de selección
    expect(find.text('Seleccionar Conductor'), findsOneWidget);
    
    // Seleccionar un conductor
    await tester.tap(find.text('Juan Pérez').first);
    await tester.pumpAndSettle();
    
    // Confirmar selección
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    
    // Verificar que se muestra mensaje de éxito
    expect(find.text('Conductor asignado correctamente'), findsOneWidget);
    
    // Verificar que el conductor aparece en los detalles de la ruta
    expect(find.text('Conductor: Juan Pérez'), findsOneWidget);
  });
}
