import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_finance/data/ledger.dart';
import 'package:aurora_finance/ui/demo_preview.dart';

void main() {
  test('visual sample matches the reference total and is not persisted', () {
    final sample = demoPreviewEntries(DateTime(2026, 11, 6));
    expect(totalFor(sample, 'expense'), 84112);
    expect(sample.every((entry) => entry.id == null), isTrue);
    expect(sample.where((e) => e.type == 'expense').length, greaterThan(4));
  });
}
