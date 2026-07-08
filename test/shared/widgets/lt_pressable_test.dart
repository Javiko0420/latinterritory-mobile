import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

void main() {
  testWidgets('expone semántica de botón cuando es tappable', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LtPressable(onTap: () {}, child: const Text('tap')),
      ),
    ));

    final node = tester.getSemantics(find.text('tap'));
    expect(node.flagsCollection.isButton, isTrue);

    handle.dispose();
  });

  testWidgets('sin callbacks no anuncia botón', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LtPressable(child: Text('estático')),
      ),
    ));

    final node = tester.getSemantics(find.text('estático'));
    expect(node.flagsCollection.isButton, isFalse);

    handle.dispose();
  });
}
