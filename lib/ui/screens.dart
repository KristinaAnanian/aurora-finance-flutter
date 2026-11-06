import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/ledger.dart';
import 'aurora_card.dart';

const bg = Color(0xFF0C0C0D);
const panel = Color(0xFF242425);
const dim = Color(0xFFA4A4A8);
const accent = Color(0xFFA9B2F6);

const expenseCategories = [
  'Shopping', 'Food & Drinks', 'Transport', 'Subscription',
  'Health', 'Entertainment', 'Housing', 'Bills', 'Other',
];
const incomeCategories = ['Salary', 'Freelance', 'Gift', 'Refund', 'Other'];

class FinanceShell extends StatefulWidget {
  const FinanceShell({required this.finance, super.key});
  final LedgerController finance;

  @override
  State<FinanceShell> createState() => _FinanceShellState();
}

class _FinanceShellState extends State<FinanceShell> {
  int tab = 0;

  void _edit({LedgerEntry? entry, String type = 'expense'}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => EntryEditor(finance: widget.finance, entry: entry, type: type),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: tab,
            children: [
              HomeScreen(finance: widget.finance, onEdit: (e) => _edit(entry: e), onAdd: (t) => _edit(type: t)),
              AnalyticsScreen(finance: widget.finance),
              HistoryScreen(finance: widget.finance, onEdit: (e) => _edit(entry: e), onAdd: () => _edit()),
              SettingsScreen(finance: widget.finance),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 12),
            child: Container(
              height: 58,
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(32)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nav(Icons.grid_view_rounded, 'Home', 0),
                  _nav(Icons.bar_chart_rounded, 'Analytics', 1),
                  _nav(Icons.swap_horiz_rounded, 'History', 2),
                  _nav(Icons.settings_outlined, 'Settings', 3),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _nav(IconData icon, String label, int index) => Semantics(
        label: label,
        button: true,
        selected: tab == index,
        child: IconButton(
          tooltip: label,
          icon: Icon(icon, size: 23),
          style: IconButton.styleFrom(
            foregroundColor: tab == index ? Colors.black : Colors.white,
            backgroundColor: tab == index ? Colors.white : Colors.transparent,
          ),
          onPressed: () => setState(() => tab = index),
        ),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.finance, required this.onEdit, required this.onAdd, super.key});
  final LedgerController finance;
  final ValueChanged<LedgerEntry> onEdit;
  final ValueChanged<String> onAdd;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool concealBalance = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.finance;
    return ListView(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 20),
      children: [
        Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFF545A67), child: Icon(Icons.person, size: 21, color: Colors.white)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome back,', style: TextStyle(fontSize: 12, color: dim)),
            Text('Your finances', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ])),
          IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No new notifications'))),
            icon: const Icon(Icons.notifications_none_rounded)),
        ]),
        const SizedBox(height: 20),
        AuroraCard(
          height: 177,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('My balance', style: TextStyle(fontSize: 12, color: Colors.black)),
                    const SizedBox(width: 7),
                    Text(f.currency, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  ]),
                ),
                const Icon(Icons.blur_on_rounded, color: Colors.white70, size: 24),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total balance', style: TextStyle(fontSize: 12, color: Colors.white)),
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(child: Text(concealBalance ? '••••••' : f.money(f.balance),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white))),
                  IconButton(
                    tooltip: concealBalance ? 'Show balance' : 'Hide balance',
                    onPressed: () => setState(() => concealBalance = !concealBalance),
                    icon: Icon(concealBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white, size: 21),
                  ),
                ]),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ActionTile(icon: Icons.arrow_outward, title: 'Expense', onTap: () => widget.onAdd('expense'))),
          const SizedBox(width: 8),
          Expanded(child: ActionTile(icon: Icons.south_east, title: 'Income', onTap: () => widget.onAdd('income'))),
          const SizedBox(width: 8),
          Expanded(child: ActionTile(icon: Icons.add, title: 'Add', emphasis: true, onTap: () => widget.onAdd('expense'))),
        ]),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          Text('${f.entries.length} total', style: const TextStyle(color: dim, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        if (f.entries.isEmpty)
          EmptyState(onAdd: () => widget.onAdd('expense'))
        else
          ...f.entries.take(8).map((e) => EntryRow(entry: e, finance: f, onTap: () => widget.onEdit(e))),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({required this.icon, required this.title, required this.onTap, this.emphasis = false, super.key});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Material(
        color: emphasis ? Colors.white : panel,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: SizedBox(height: 72, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: emphasis ? Colors.black : Colors.white, size: 24),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 12, color: emphasis ? Colors.black : Colors.white)),
          ])),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.onAdd, super.key});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          const Icon(Icons.receipt_long_outlined, size: 34, color: dim),
          const SizedBox(height: 12),
          const Text('No transactions yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          const Text('Add your first expense or income. Everything stays on this device.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: dim)),
          const SizedBox(height: 12),
          TextButton(onPressed: onAdd, child: const Text('Add transaction', style: TextStyle(color: accent))),
        ]),
      );
}

IconData categoryIcon(String category) => switch (category) {
      'Shopping' => Icons.shopping_bag_outlined,
      'Food & Drinks' => Icons.local_cafe_outlined,
      'Transport' => Icons.directions_car_outlined,
      'Subscription' => Icons.subscriptions_outlined,
      'Health' => Icons.favorite_outline,
      'Entertainment' => Icons.movie_outlined,
      'Housing' => Icons.home_outlined,
      'Bills' => Icons.receipt_long_outlined,
      'Salary' => Icons.account_balance_wallet_outlined,
      'Freelance' => Icons.work_outline,
      _ => Icons.swap_horiz_rounded,
    };

class EntryRow extends StatelessWidget {
  const EntryRow({required this.entry, required this.finance, required this.onTap, super.key});
  final LedgerEntry entry;
  final LedgerController finance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
            CircleAvatar(radius: 19, backgroundColor: panel,
              child: Icon(categoryIcon(entry.category), size: 21, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.description.isEmpty ? entry.category : entry.description,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text('${entry.category} • ${DateFormat('MMM d').format(entry.date)}',
                  style: const TextStyle(color: dim, fontSize: 11)),
            ])),
            const SizedBox(width: 7),
            Text('${entry.type == 'income' ? '+' : '−'}${finance.money(entry.amountMinor)}',
                style: const TextStyle(fontSize: 12)),
          ])),
        ),
      );
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({required this.finance, super.key});
  final LedgerController finance;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String type = 'expense';
  String range = 'Week';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = range == 'Week'
        ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1))
        : DateTime(now.year, now.month, 1);
    final end = range == 'Week'
        ? start.add(const Duration(days: 7))
        : DateTime(now.year, now.month + 1, 1);
    final entries = widget.finance.entries.where((e) =>
      e.type == type && !e.date.isBefore(start) && e.date.isBefore(end)).toList();
    final total = totalFor(entries, type);
    final count = range == 'Week' ? 7 : ((end.difference(start).inDays + 6) ~/ 7);
    final points = List<int>.filled(count, 0);
    for (final entry in entries) {
      final days = DateTime(entry.date.year, entry.date.month, entry.date.day).difference(start).inDays;
      final index = range == 'Week' ? days : days ~/ 7;
      if (index >= 0 && index < points.length) points[index] += entry.amountMinor;
    }
    final maxPoint = math.max(1, points.reduce(math.max));
    final byCategory = <String, int>{};
    for (final e in entries) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amountMinor;
    }
    final categories = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return ListView(padding: const EdgeInsets.fromLTRB(17, 22, 17, 28), children: [
      const Center(child: Text('Analytics', style: TextStyle(fontSize: 16))),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: SegmentButton(label: 'Expenses', selected: type == 'expense',
          onTap: () => setState(() => type = 'expense'))),
        const SizedBox(width: 5),
        Expanded(child: SegmentButton(label: 'Income', selected: type == 'income',
          onTap: () => setState(() => type = 'income'))),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(widget.finance.money(total), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w400))),
            PopupMenuButton<String>(
              initialValue: range,
              color: const Color(0xFF343437),
              onSelected: (value) => setState(() => range = value),
              itemBuilder: (_) => ['Week', 'Month'].map((x) => PopupMenuItem(value: x, child: Text(x))).toList(),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF414143), borderRadius: BorderRadius.circular(18)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Text(range), const Icon(Icons.keyboard_arrow_down, size: 16)])),
            ),
          ]),
          const SizedBox(height: 14),
          SizedBox(height: 165, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < points.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(child: Align(alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: points[i] == 0 ? .035 : math.max(.07, points[i] / maxPoint),
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: points[i] == maxPoint && total > 0
                          ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Color(0xFFC7CAFF), Color(0xFF7087EB)])
                          : null,
                      color: points[i] == maxPoint && total > 0 ? null : const Color(0xFF454547),
                    )),
                  ),
                )),
                const SizedBox(height: 8),
                Text(range == 'Week'
                  ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]
                  : 'W${i + 1}',
                  style: const TextStyle(fontSize: 10, color: dim)),
              ])),
            ]
          ])),
        ]),
      ),
      const SizedBox(height: 22),
      Text('${type == 'expense' ? 'Spending' : 'Income'} by category', style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 12),
      if (categories.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(
          child: Text('No transactions in this period', style: TextStyle(color: dim))))
      else
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.85),
          itemCount: categories.length,
          itemBuilder: (_, i) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(categories[i].key, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: dim)),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                child: Text(widget.finance.money(categories[i].value), style: const TextStyle(fontSize: 19))),
            ]),
          ),
        ),
    ]);
  }
}

class SegmentButton extends StatelessWidget {
  const SegmentButton({required this.label, required this.selected, required this.onTap, super.key});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Colors.white : panel,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.black : Colors.white))),
          ),
        ),
      );
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.finance, required this.onEdit, required this.onAdd, super.key});
  final LedgerController finance;
  final ValueChanged<LedgerEntry> onEdit;
  final VoidCallback onAdd;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final entries = widget.finance.entries.where((e) => filter == 'all' || e.type == filter).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(17, 21, 17, 15), child: Row(children: [
        const Expanded(child: Text('Transactions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))),
        IconButton.filledTonal(tooltip: 'Add transaction', onPressed: widget.onAdd, icon: const Icon(Icons.add)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 17), child: Row(children: [
        for (final item in [('All', 'all'), ('Expenses', 'expense'), ('Income', 'income')]) ...[
          if (item != ('All', 'all')) const SizedBox(width: 5),
          Expanded(child: SegmentButton(label: item.$1, selected: filter == item.$2,
            onTap: () => setState(() => filter = item.$2))),
        ]
      ])),
      const SizedBox(height: 14),
      Expanded(child: entries.isEmpty
        ? Center(child: Text(filter == 'all' ? 'Your transactions will appear here' : 'No $filter entries',
            style: const TextStyle(color: dim)))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            itemCount: entries.length,
            itemBuilder: (_, index) => EntryRow(entry: entries[index], finance: widget.finance,
              onTap: () => widget.onEdit(entries[index])),
          )),
    ]);
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.finance, super.key});
  final LedgerController finance;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(17, 22, 17, 32),
        children: [
          const Center(child: Text('Settings', style: TextStyle(fontSize: 17))),
          const SizedBox(height: 24),
          const Text('YOUR LEDGER', style: TextStyle(color: dim, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          SettingsTile(icon: Icons.payments_outlined, title: 'Opening balance',
              subtitle: finance.money(finance.openingMinor),
              onTap: () => _editOpening(context)),
          SettingsTile(icon: Icons.currency_exchange, title: 'Currency',
              subtitle: '${finance.currency} • changes only when ledger is empty',
              onTap: () => _changeCurrency(context)),
          const SizedBox(height: 26),
          const Text('DATA & PRIVACY', style: TextStyle(color: dim, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          const SettingsTile(icon: Icons.phone_android, title: 'Offline storage',
              subtitle: 'Transactions are saved locally on this device.'),
          const SettingsTile(icon: Icons.cloud_off_outlined, title: 'No sync',
              subtitle: 'No bank connection or cloud backup in this version.'),
          SettingsTile(icon: Icons.delete_outline, title: 'Erase all financial data',
              subtitle: 'Deletes transactions and resets opening balance', onTap: () => _erase(context)),
          const SizedBox(height: 26),
          const Text('Aurora Finance • MVP 0.1', style: TextStyle(color: dim, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('This is a personal finance tracker, not a bank. Expense and income actions record entries; they do not move money.',
              style: TextStyle(color: dim, fontSize: 12, height: 1.5)),
        ],
      );

  Future<void> _editOpening(BuildContext context) async {
    final controller = TextEditingController(
      text: (finance.openingMinor / Money.factor(finance.currency)).toStringAsFixed(finance.currency == 'AMD' ? 0 : 2));
    final result = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Opening balance'),
      content: TextField(controller: controller, autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: 'Amount in ${finance.currency}')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final parsed = Money.parse(controller.text, finance.currency, signed: true);
          if (parsed == null) return;
          Navigator.pop(ctx, parsed);
        }, child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (result != null) await finance.changeOpening(result);
  }

  Future<void> _changeCurrency(BuildContext context) async {
    if (finance.entries.isNotEmpty || finance.openingMinor != 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
        'To protect amounts, currency can only change in an empty, zero-balance ledger.')));
      return;
    }
    final next = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Choose ledger currency'),
      children: ['USD', 'EUR', 'AMD'].map((currency) => SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, currency),
        child: Padding(padding: const EdgeInsets.all(7), child: Text(currency)),
      )).toList(),
    ));
    if (next != null) await finance.changeCurrency(next);
  }

  Future<void> _erase(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Erase financial data?'),
      content: const Text('This permanently deletes all saved transactions and resets your opening balance. This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Erase', style: TextStyle(color: Colors.redAccent))),
      ],
    ));
    if (confirmed == true) {
      await finance.reset();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local financial data erased.')));
    }
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap, super.key});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Material(
          color: panel,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [
                Icon(icon, size: 23),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: dim)),
                ])),
                if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 20, color: dim),
              ]),
            ),
          ),
        ),
      );
}

class EntryEditor extends StatefulWidget {
  const EntryEditor({required this.finance, this.entry, this.type = 'expense', super.key});
  final LedgerController finance;
  final LedgerEntry? entry;
  final String type;

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> {
  late final TextEditingController amount;
  late final TextEditingController description;
  late String type;
  late String category;
  late DateTime date;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    type = entry?.type ?? widget.type;
    category = entry?.category ?? (type == 'expense' ? expenseCategories.first : incomeCategories.first);
    date = entry?.date ?? DateTime.now();
    amount = TextEditingController(text: entry == null ? '' :
      (entry.amountMinor / Money.factor(widget.finance.currency)).toStringAsFixed(widget.finance.currency == 'AMD' ? 0 : 2));
    description = TextEditingController(text: entry?.description ?? '');
  }

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    super.dispose();
  }

  void _changeType(String next) {
    setState(() {
      type = next;
      category = (type == 'expense' ? expenseCategories : incomeCategories).first;
    });
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _save() async {
    final minor = Money.parse(amount.text, widget.finance.currency);
    if (minor == null || minor <= 0) {
      setState(() => error = 'Please enter an amount greater than zero.');
      return;
    }
    setState(() { saving = true; error = null; });
    try {
      await widget.finance.save(LedgerEntry(
        id: widget.entry?.id,
        type: type,
        amountMinor: minor,
        category: category,
        description: description.text.trim().isEmpty ? category : description.text.trim(),
        date: date,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { saving = false; error = 'Could not save transaction: $e'; });
    }
  }

  Future<void> _remove() async {
    final id = widget.entry?.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete transaction?'),
      content: const Text('This will permanently remove the entry from your ledger.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
      ],
    ));
    if (confirmed != true) return;
    await widget.finance.remove(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(17, 16, 17, 34), children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
            Expanded(child: Center(child: Text(widget.entry == null ? 'New transaction' : 'Edit transaction',
                style: const TextStyle(fontSize: 15)))),
            if (widget.entry != null)
              IconButton(tooltip: 'Delete entry', onPressed: saving ? null : _remove,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent))
            else
              const SizedBox(width: 48),
          ]),
          const SizedBox(height: 21),
          Row(children: [
            Expanded(child: SegmentButton(label: 'Expense', selected: type == 'expense',
              onTap: () => _changeType('expense'))),
            const SizedBox(width: 7),
            Expanded(child: SegmentButton(label: 'Income', selected: type == 'income',
              onTap: () => _changeType('income'))),
          ]),
          const SizedBox(height: 18),
          AuroraCard(height: 174, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Amount', style: TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(Money.symbol(widget.finance.currency),
                style: const TextStyle(fontSize: 37, fontWeight: FontWeight.w300)),
              const SizedBox(width: 5),
              Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200),
                child: TextField(
                  controller: amount,
                  autofocus: widget.entry == null,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(
                    widget.finance.currency == 'AMD' ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'))],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w300, color: Colors.white),
                  decoration: const InputDecoration(hintText: '0.00', hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                ),
              )),
            ]),
          ])),
          const SizedBox(height: 19),
          const Text('Category', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            key: ValueKey(type),
            initialValue: category,
            dropdownColor: panel,
            decoration: const InputDecoration(),
            items: (type == 'expense' ? expenseCategories : incomeCategories)
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: (value) { if (value != null) setState(() => category = value); },
          ),
          const SizedBox(height: 16),
          const Text('Date', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 7),
          Material(color: panel, borderRadius: BorderRadius.circular(12),
            child: InkWell(borderRadius: BorderRadius.circular(12), onTap: _chooseDate,
              child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: Text(DateFormat('MMMM d, yyyy').format(date), style: const TextStyle(fontSize: 13))),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ])))),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 7),
          TextField(controller: description, maxLines: 3, maxLength: 150,
            decoration: const InputDecoration(hintText: 'What was this for?')),
          if (error != null)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.entry == null ? 'Save transaction' : 'Save changes'),
          ),
        ])),
      );
}
