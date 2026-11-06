import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// All monetary values are stored as integer minor units. One ledger has one
/// currency; changing currency never converts or silently relabels money.
class Money {
  static int factor(String currency) => currency == 'AMD' ? 1 : 100;

  static String symbol(String currency) => switch (currency) {
        'AMD' => '֏',
        'EUR' => '€',
        _ => r'$',
      };

  static String format(int minor, String currency) {
    final digits = currency == 'AMD' ? 0 : 2;
    final number = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol(currency),
      decimalDigits: digits,
    );
    return number.format(minor / factor(currency));
  }

  static int? parse(String raw, String currency, {bool signed = false}) {
    // Reject excess decimals instead of silently rounding financial inputs.
    final normalized = raw.trim().replaceAll(',', '');
    final precision = currency == 'AMD' ? 0 : 2;
    final pattern = precision == 0
        ? RegExp(signed ? r'^-?\d+$' : r'^\d+$')
        : RegExp(signed ? r'^-?\d+(\.\d{1,2})?$' : r'^\d+(\.\d{1,2})?$');
    if (!pattern.hasMatch(normalized)) return null;
    final value = double.tryParse(normalized);
    if (value == null || !value.isFinite || value.abs() > 1000000000000) {
      return null;
    }
    return (value * factor(currency)).round();
  }
}

class LedgerEntry {
  const LedgerEntry({
    this.id,
    required this.type,
    required this.amountMinor,
    required this.category,
    required this.description,
    required this.date,
  });

  final int? id;
  final String type; // 'expense' or 'income'
  final int amountMinor;
  final String category;
  final String description;
  final DateTime date;

  Map<String, Object?> toMap() => {
        'type': type,
        'amount_minor': amountMinor,
        'category': category,
        'description': description,
        'date': DateFormat('yyyy-MM-dd').format(date),
      };

  factory LedgerEntry.fromMap(Map<String, Object?> row) => LedgerEntry(
        id: row['id'] as int,
        type: row['type'] as String,
        amountMinor: row['amount_minor'] as int,
        category: row['category'] as String,
        description: row['description'] as String,
        date: DateTime.parse(row['date'] as String),
      );

  LedgerEntry copyWith({
    int? id,
    String? type,
    int? amountMinor,
    String? category,
    String? description,
    DateTime? date,
  }) =>
      LedgerEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        amountMinor: amountMinor ?? this.amountMinor,
        category: category ?? this.category,
        description: description ?? this.description,
        date: date ?? this.date,
      );
}

int balanceMinor(int openingMinor, Iterable<LedgerEntry> entries) {
  return entries.fold(openingMinor, (sum, entry) =>
    sum + (entry.type == 'income' ? entry.amountMinor : -entry.amountMinor));
}

int totalFor(Iterable<LedgerEntry> entries, String type) => entries
    .where((entry) => entry.type == type)
    .fold(0, (sum, entry) => sum + entry.amountMinor);

class LedgerStore {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      p.join(root, 'aurora_finance.sqlite'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL CHECK(type IN ('expense','income')),
            amount_minor INTEGER NOT NULL CHECK(amount_minor > 0),
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX transactions_date_idx ON transactions(date DESC)');
        await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      },
    );
    return _db!;
  }

  Future<List<LedgerEntry>> entries() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(LedgerEntry.fromMap).toList();
  }

  Future<String?> setting(String key) async {
    final db = await database;
    final rows = await db.query('settings', columns: ['value'], where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> putSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> save(LedgerEntry entry) async {
    final db = await database;
    if (entry.id == null) {
      await db.insert('transactions', entry.toMap());
    } else {
      await db.update('transactions', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
    }
  }

  Future<void> remove(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reset() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.insert('settings', {'key': 'openingMinor', 'value': '0'},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

class LedgerController extends ChangeNotifier {
  LedgerController(this.store);
  final LedgerStore store;
  List<LedgerEntry> entries = [];
  int openingMinor = 0;
  String currency = 'USD';
  bool ready = false;
  String? error;

  int get balance => balanceMinor(openingMinor, entries);
  String money(int minor) => Money.format(minor, currency);

  Future<void> load() async {
    try {
      currency = await store.setting('currency') ?? 'USD';
      openingMinor = int.tryParse(await store.setting('openingMinor') ?? '0') ?? 0;
      entries = await store.entries();
      error = null;
    } catch (e) {
      error = 'Could not open the local database: $e';
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    entries = await store.entries();
    notifyListeners();
  }

  Future<void> save(LedgerEntry entry) async {
    await store.save(entry);
    await refresh();
  }

  Future<void> remove(int id) async {
    await store.remove(id);
    await refresh();
  }

  Future<void> changeOpening(int minor) async {
    openingMinor = minor;
    await store.putSetting('openingMinor', '$minor');
    notifyListeners();
  }

  Future<bool> changeCurrency(String next) async {
    // No conversions: prevent changing a ledger that already has money in it.
    if (entries.isNotEmpty || openingMinor != 0) return false;
    if (!['USD', 'EUR', 'AMD'].contains(next)) return false;
    await store.putSetting('currency', next);
    currency = next;
    notifyListeners();
    return true;
  }

  Future<void> reset() async {
    await store.reset();
    openingMinor = 0;
    await refresh();
  }

  @override
  void dispose() {
    store.close();
    super.dispose();
  }
}
