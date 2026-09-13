// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:acitivit5_gestion_redacteurs/main.dart';

void main() {
  testWidgets('Test de l\'application', (WidgetTester tester) async {
    await tester.pumpWidget(const MonApplication());

    // Vérifie que le titre de l'AppBar est présent
    expect(find.text('Gestion des Rédacteurs'), findsOneWidget);
  });
}
