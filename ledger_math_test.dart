import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_finance/data/ledger.dart';

void main() {
  final now = DateTime(2026, 11, 5);
  test('integer minor units maintain an exact ledger balance', () {
    final entries = [
      LedgerEntry(type: 'income', amountMinor: 100099, category: 'Salary', description: 'Income', date: now),
      LedgerEntry(type: 'expense', amountMinor: 1099, category: 'Subscription', description: 'Netflix', date: now),
      LedgerEntry(type: 'expense', amountMinor: 329, category: 'Food & Drinks', description: 'Coffee', date: now),
    ];
    expect(balanceMinor(10000, entries), 108671);
    expect(totalFor(entries, 'expense'), 1428);
    expect(totalFor(entries, 'income'), 100099);
  });

  test('AMD uses whole units and USD uses cents', () {
    expect(Money.parse('1000', 'AMD'), 1000);
    expect(Money.parse('10.99', 'USD'), 1099);
    expect(Money.parse('-1', 'USD'), isNull);
    expect(Money.parse('not a number', 'USD'), isNull);
    expect(Money.parse('1.005', 'USD'), isNull);
    expect(Money.parse('10.5', 'AMD'), isNull);
    expect(Money.parse('-10.99', 'USD', signed: true), -1099);
  });
}
