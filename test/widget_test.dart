// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ap2_evento/main.dart';

void main() {
  testWidgets('Carregamento inicial do app', (WidgetTester tester) async {
    // Constrói nosso app e dispara um frame.
    await tester.pumpWidget(const MeuApp());

    // Verifica se o título do app está presente.
    expect(find.text('Semana da Computação 2026'), findsWidgets);
  });
}
