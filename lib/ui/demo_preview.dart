import '../data/ledger.dart';

/// Visual-only sample content shown only when the user explicitly chooses
/// "Preview design". These records are NEVER written into SQLite.
List<LedgerEntry> demoPreviewEntries([DateTime? now]) {
  final today = now ?? DateTime.now();
  final monday = DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: today.weekday - 1));
  return [
    LedgerEntry(type: 'expense', amountMinor: 1099, category: 'Subscription',
        description: 'Netflix', date: monday.add(const Duration(days: 0))),
    LedgerEntry(type: 'expense', amountMinor: 329, category: 'Food & Drinks',
        description: 'Starbucks', date: monday.add(const Duration(days: 1))),
    LedgerEntry(type: 'expense', amountMinor: 1699, category: 'Transport',
        description: 'Uber', date: monday.add(const Duration(days: 2))),
    LedgerEntry(type: 'expense', amountMinor: 9299, category: 'Shopping',
        description: 'Amazon', date: monday.add(const Duration(days: 3))),
    LedgerEntry(type: 'expense', amountMinor: 13701, category: 'Shopping',
        description: 'Shopping', date: monday.add(const Duration(days: 5))),
    LedgerEntry(type: 'expense', amountMinor: 11000, category: 'Health',
        description: 'Health', date: monday.add(const Duration(days: 6))),
    LedgerEntry(type: 'expense', amountMinor: 5600, category: 'Entertainment',
        description: 'Entertainment', date: monday.add(const Duration(days: 4))),
    LedgerEntry(type: 'expense', amountMinor: 101, category: 'Other',
        description: 'Other', date: monday.add(const Duration(days: 3))),
    LedgerEntry(type: 'expense', amountMinor: 1700, category: 'Subscription',
        description: 'Subscriptions', date: monday.add(const Duration(days: 5))),
    LedgerEntry(type: 'expense', amountMinor: 39584, category: 'Other',
        description: 'Other expenses', date: monday.add(const Duration(days: 5))),
    LedgerEntry(type: 'income', amountMinor: 120000, category: 'Salary',
        description: 'Salary', date: monday.add(const Duration(days: 0))),
    LedgerEntry(type: 'income', amountMinor: 25000, category: 'Freelance',
        description: 'Project work', date: monday.add(const Duration(days: 4))),
  ];
}
