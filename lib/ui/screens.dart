import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/ledger.dart';
import 'aurora_card.dart';
import 'demo_preview.dart';

const bg = Color(0xFF0C0C0D);
const panel = Color(0xFF232324);
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
  bool designPreview = false;

  void _edit({LedgerEntry? entry, String type = 'expense'}) {
    // Leaving visual preview never alters or persists the sample amounts.
    if (designPreview) setState(() => designPreview = false);
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
              TickerMode(
                enabled: tab == 0,
                child: HomeScreen(
                  finance: widget.finance,
                  preview: designPreview && widget.finance.entries.isEmpty,
                  onPreviewChanged: (value) => setState(() => designPreview = value),
                  onEdit: (e) => _edit(entry: e),
                  onAdd: (t) => _edit(type: t),
                ),
              ),
              AnalyticsScreen(
                finance: widget.finance,
                preview: designPreview && widget.finance.entries.isEmpty,
                onBack: () => setState(() => tab = 0),
              ),
              HistoryScreen(finance: widget.finance, onEdit: (e) => _edit(entry: e), onAdd: () => _edit()),
              SettingsScreen(finance: widget.finance),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 3, 21, 10),
            child: Container(
              height: 52,
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(32)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nav(Icons.grid_view_rounded, 'Home', 0),
                  _nav(Icons.analytics_outlined, 'Analytics', 1),
                  _nav(Icons.receipt_long_outlined, 'History', 2),
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
          icon: Icon(icon, size: 21),
          style: IconButton.styleFrom(
            foregroundColor: tab == index ? Colors.black : Colors.white,
            backgroundColor: tab == index ? Colors.white : Colors.transparent,
          ),
          onPressed: () => setState(() => tab = index),
        ),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.finance,
    required this.onEdit,
    required this.onAdd,
    required this.preview,
    required this.onPreviewChanged,
    super.key,
  });

  final LedgerController finance;
  final ValueChanged<LedgerEntry> onEdit;
  final ValueChanged<String> onAdd;
  final bool preview;
  final ValueChanged<bool> onPreviewChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool concealBalance = false;

  @override
  Widget build(BuildContext context) {
    final finance = widget.finance;
    final sample = widget.preview ? demoPreviewEntries() : const <LedgerEntry>[];
    final visibleEntries = widget.preview ? sample.take(4).toList() : finance.entries.take(6).toList();
    final visibleBalance = widget.preview ? finance.money(791203) : finance.money(finance.balance);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            const Positioned.fill(child: AuroraHeaderGlow()),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 0),
              child: Column(children: [
                SizedBox(
                  height: 49,
                  child: Row(children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFF393D43),
                      child: Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFFE8E8E8)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Welcome back,', style: TextStyle(fontSize: 11, color: dim)),
                        SizedBox(height: 2),
                        Text('Aurora Finance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    )),
                    Material(
                      color: const Color(0xFF222223),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Notifications',
                        icon: const Icon(Icons.notifications_none_rounded, size: 19),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No new notifications')),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                AuroraCard(
                  height: 174,
                  radius: 14,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 13, 9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .96),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(widget.preview ? 'Demo wallet' : 'Main wallet',
                                style: const TextStyle(color: Color(0xFF111114), fontSize: 11, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 6),
                              Text(finance.currency, style: const TextStyle(color: Color(0xFF414146), fontSize: 10)),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 16),
                            ]),
                          ),
                          const _CardCircles(),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.preview ? 'Sample balance · preview' : 'Total balance',
                            style: const TextStyle(fontSize: 11, color: Colors.white)),
                          const SizedBox(height: 3),
                          Row(children: [
                            Expanded(child: Text(concealBalance ? '••••••' : visibleBalance,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 31,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                            )),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: concealBalance ? 'Show balance' : 'Hide balance',
                              onPressed: () => setState(() => concealBalance = !concealBalance),
                              icon: Icon(concealBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white, size: 19),
                            ),
                          ]),
                        ]),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 11, 17, 0),
          child: Row(children: [
            Expanded(child: ActionTile(icon: Icons.north_east_rounded,
              title: 'Send', onTap: () => widget.onAdd('expense'))),
            const SizedBox(width: 7),
            Expanded(child: ActionTile(icon: Icons.south_east_rounded,
              title: 'Receive', onTap: () => widget.onAdd('income'))),
            const SizedBox(width: 7),
            Expanded(child: ActionTile(icon: Icons.add_rounded,
              title: 'Top Up', emphasis: true, onTap: () => widget.onAdd('income'))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 20, 17, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -.35)),
            if (widget.preview)
              TextButton(
                onPressed: () => widget.onPreviewChanged(false),
                child: const Text('Exit preview', style: TextStyle(fontSize: 11, color: Colors.white70)),
              )
            else
              Text('${finance.entries.length} total', style: const TextStyle(color: dim, fontSize: 11)),
          ]),
        ),
        if (finance.entries.isEmpty && !widget.preview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: EmptyState(
              onAdd: () => widget.onAdd('expense'),
              onPreview: () => widget.onPreviewChanged(true),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(children: [
              if (widget.preview)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('DEMO PREVIEW · not real transactions',
                      style: TextStyle(fontSize: 9, letterSpacing: .65, color: dim)),
                  ),
                ),
              ...visibleEntries.map((entry) => EntryRow(
                entry: entry,
                finance: finance,
                onTap: widget.preview
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sample only. Add a transaction to track real money.')),
                      )
                    : () => widget.onEdit(entry),
              )),
            ]),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CardCircles extends StatelessWidget {
  const _CardCircles();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 35,
    height: 19,
    child: Stack(children: [
      Positioned(left: 2, top: 1, child: Container(
        width: 18, height: 18,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .43)),
      )),
      Positioned(left: 13, top: 1, child: Container(
        width: 18, height: 18,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .65)),
      )),
    ]),
  );
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
          child: SizedBox(height: 67, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: emphasis ? Colors.black : Colors.white, size: 23),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 11, color: emphasis ? Colors.black : Colors.white)),
          ])),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.onAdd, required this.onPreview, super.key});
  final VoidCallback onAdd;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 19),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          const Icon(Icons.receipt_long_outlined, size: 29, color: dim),
          const SizedBox(height: 10),
          const Text('No transactions yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Add your first expense or explore the design with sample data.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: dim, height: 1.5)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(onPressed: onPreview,
              child: const Text('Preview design', style: TextStyle(color: Color(0xFFCDD0FF), fontSize: 12))),
            const SizedBox(width: 4),
            TextButton(onPressed: onAdd,
              child: const Text('Add transaction', style: TextStyle(color: Colors.white, fontSize: 12))),
          ]),
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
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: panel,
              child: entry.description.toLowerCase() == 'netflix'
                ? const Text('N', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800))
                : entry.description.toLowerCase() == 'amazon'
                    ? const Text('a', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600))
                    : Icon(categoryIcon(entry.category), size: 19, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.description.isEmpty ? entry.category : entry.description,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text('${entry.category} • ${DateFormat('MMM d').format(entry.date)}',
                  style: const TextStyle(color: dim, fontSize: 10)),
            ])),
            const SizedBox(width: 7),
            Text('${entry.type == 'income' ? '+' : '−'}${finance.money(entry.amountMinor)}',
                style: const TextStyle(fontSize: 11)),
          ])),
        ),
      );
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    required this.finance,
    required this.preview,
    required this.onBack,
    super.key,
  });
  final LedgerController finance;
  final bool preview;
  final VoidCallback onBack;

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
        ? DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1))
        : DateTime(now.year, now.month, 1);
    final end = range == 'Week'
        ? start.add(const Duration(days: 7))
        : DateTime(now.year, now.month + 1, 1);
    // Demo entries live only in memory; all real analytics use SQLite records.
    final source = widget.preview ? demoPreviewEntries(now) : widget.finance.entries;
    final entries = source.where((e) =>
      e.type == type && !e.date.isBefore(start) && e.date.isBefore(end)).toList();
    final total = totalFor(entries, type);
    final count = range == 'Week'
        ? 7
        : ((end.difference(start).inDays + 6) ~/ 7);
    final points = List<int>.filled(count, 0);
    for (final entry in entries) {
      final days = DateTime(entry.date.year, entry.date.month, entry.date.day)
          .difference(start).inDays;
      final index = range == 'Week' ? days : days ~/ 7;
      if (index >= 0 && index < points.length) points[index] += entry.amountMinor;
    }
    final maxPoint = math.max(1, points.reduce(math.max));
    final byCategory = <String, int>{};
    for (final e in entries) {
      final cat = widget.preview && e.category == 'Food & Drinks' ? 'Other' : e.category;
      byCategory[cat] = (byCategory[cat] ?? 0) + e.amountMinor;
    }
    const previewOrder = [
      'Shopping', 'Health', 'Entertainment', 'Transport', 'Subscription', 'Other',
    ];
    final categories = byCategory.entries.toList()
      ..sort((a, b) => widget.preview
        ? previewOrder.indexOf(a.key).compareTo(previewOrder.indexOf(b.key))
        : b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 25),
      children: [
        SizedBox(height: 47, child: Row(children: [
          SizedBox(width: 42, child: IconButton(
            tooltip: 'Back to home',
            icon: const Icon(Icons.arrow_back_rounded, size: 19),
            style: IconButton.styleFrom(backgroundColor: panel),
            onPressed: widget.onBack,
          )),
          Expanded(child: Center(child: Text('Analytics',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400)))),
          SizedBox(width: 42, child: PopupMenuButton<String>(
            tooltip: 'Period',
            icon: const Icon(Icons.more_horiz, size: 20),
            color: panel,
            onSelected: (value) => setState(() => range = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Week', child: Text('This week')),
              PopupMenuItem(value: 'Month', child: Text('This month')),
            ],
          )),
        ])),
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: panel,
            borderRadius: BorderRadius.circular(25)),
          child: Row(children: [
            Expanded(child: SegmentButton(
              label: 'Expenses', selected: type == 'expense', embedded: true,
              onTap: () => setState(() => type = 'expense'))),
            const SizedBox(width: 3),
            Expanded(child: SegmentButton(
              label: 'Income', selected: type == 'income', embedded: true,
              onTap: () => setState(() => type = 'income'))),
          ]),
        ),
        if (widget.preview)
          const Padding(
            padding: EdgeInsets.only(top: 9, left: 3),
            child: Text('DEMO PREVIEW · illustrative figures only',
              style: TextStyle(color: dim, fontSize: 9, letterSpacing: .5)),
          ),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 13, 12, 11),
          decoration: BoxDecoration(color: panel,
            borderRadius: BorderRadius.circular(13)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(widget.finance.money(total),
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w300,
                  letterSpacing: -.7))),
              PopupMenuButton<String>(
                initialValue: range,
                color: const Color(0xFF343436),
                onSelected: (value) => setState(() => range = value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Week', child: Text('Week')),
                  PopupMenuItem(value: 'Month', child: Text('Month')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFF414143),
                    borderRadius: BorderRadius.circular(19)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(range, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 5),
                    const Icon(Icons.keyboard_arrow_down, size: 15),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 11),
            SizedBox(height: 148, child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < points.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: points[i] == 0
                            ? .035 : math.max(.07, points[i] / maxPoint),
                          widthFactor: 1,
                          alignment: Alignment.bottomCenter,
                          child: Container(decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            gradient: points[i] == maxPoint && total > 0
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFC7C8FF), Color(0xFF7387ED)],
                                )
                              : null,
                            color: points[i] == maxPoint && total > 0
                              ? null : const Color(0xFF434345),
                          )),
                        ),
                      )),
                      const SizedBox(height: 7),
                      Text(range == 'Week'
                        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]
                        : 'W${i + 1}',
                        style: const TextStyle(fontSize: 10, color: dim)),
                    ],
                  )),
                ],
              ],
            )),
          ]),
        ),
        const SizedBox(height: 9),
        if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 29),
            child: Center(child: Text('No transactions in this period',
              style: TextStyle(color: dim, fontSize: 12))),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
              childAspectRatio: 1.85,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              decoration: BoxDecoration(color: panel,
                borderRadius: BorderRadius.circular(11)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categories[i].key, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: dim)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(widget.finance.money(categories[i].value),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w300)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SegmentButton extends StatelessWidget {
  const SegmentButton({required this.label, required this.selected, required this.onTap, this.embedded = false, super.key});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Colors.white : (embedded ? Colors.transparent : panel),
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: embedded ? 9 : 11),
            child: Center(child: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.black : Colors.white))),
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
          const Text('Aurora Finance • MVP 0.2', style: TextStyle(color: dim, fontSize: 12)),
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
  late final FocusNode amountFocus;
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
    amountFocus = FocusNode();
    amount = TextEditingController(text: entry == null ? '' :
      (entry.amountMinor / Money.factor(widget.finance.currency)).toStringAsFixed(widget.finance.currency == 'AMD' ? 0 : 2));
    description = TextEditingController(text: entry?.description ?? '');
  }

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    amountFocus.dispose();
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
  Widget build(BuildContext context) {
    final currency = widget.finance.currency;
    final today = DateTime.now();
    final isToday = date.year == today.year &&
      date.month == today.month && date.day == today.day;
    final available = type == 'expense' ? expenseCategories : incomeCategories;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(17, 14, 17, 22),
          children: [
            AuroraCard(
              height: 179,
              radius: 13,
              child: Stack(children: [
                Positioned(
                  top: 11,
                  left: 12,
                  child: PopupMenuButton<String>(
                    initialValue: type,
                    color: const Color(0xFF303033),
                    onSelected: _changeType,
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'expense', child: Text('Expense')),
                      PopupMenuItem(value: 'income', child: Text('Income')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(type == 'expense' ? 'Expense' : 'Income',
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                        const SizedBox(width: 3),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 15, color: Colors.white),
                      ]),
                    ),
                  ),
                ),
                Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(Money.symbol(currency),
                          style: const TextStyle(
                            fontSize: 42, fontWeight: FontWeight.w300,
                            letterSpacing: -1.3, color: Colors.white)),
                        const SizedBox(width: 4),
                        Flexible(child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: TextField(
                            focusNode: amountFocus,
                            controller: amount,
                            autofocus: false,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(
                              currency == 'AMD' ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'))],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 42,
                              letterSpacing: -1.3, fontWeight: FontWeight.w300),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Material(
                      color: Colors.white.withValues(alpha: .20),
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => amountFocus.requestFocus(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.edit_outlined, color: Colors.white, size: 13),
                            SizedBox(width: 5),
                            Text('Change amount', style: TextStyle(
                              color: Colors.white, fontSize: 11)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 15),
            const Text('Category', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 7),
            DropdownButtonFormField<String>(
              key: ValueKey(type),
              initialValue: category,
              dropdownColor: panel,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: const InputDecoration(
                constraints: BoxConstraints(minHeight: 46),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
              items: available
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
            ),
            const SizedBox(height: 15),
            const Text('Date', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 7),
            Material(
              color: panel,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: _chooseDate,
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(children: [
                      Expanded(child: Text(
                        isToday ? 'Today' : DateFormat('MMM d, yyyy').format(date),
                        style: const TextStyle(fontSize: 12))),
                      const Icon(Icons.calendar_month_outlined,
                        color: Colors.white, size: 19),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Description', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 7),
            TextField(
              controller: description,
              maxLines: 4,
              maxLength: 150,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'What was this for?',
                hintStyle: TextStyle(color: dim, fontSize: 12),
                counterText: '',
                contentPadding: EdgeInsets.fromLTRB(12, 13, 12, 13),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(error!, style: const TextStyle(color: Colors.redAccent,
                  fontSize: 11)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 8, 17, 13),
          child: Row(children: [
            Expanded(child: _EditorAction(
              icon: Icons.close_rounded,
              tooltip: 'Cancel',
              onTap: saving ? null : () => Navigator.pop(context),
            )),
            const SizedBox(width: 6),
            Expanded(child: _EditorAction(
              icon: widget.entry == null ? Icons.restart_alt_rounded : Icons.delete_outline_rounded,
              tooltip: widget.entry == null ? 'Clear form' : 'Delete transaction',
              onTap: saving ? null : widget.entry == null
                ? () {
                    amount.clear();
                    description.clear();
                    setState(() {
                      category = available.first;
                      date = DateTime.now();
                      error = null;
                    });
                  }
                : _remove,
            )),
            const SizedBox(width: 6),
            Expanded(child: _EditorAction(
              icon: Icons.check_rounded,
              tooltip: widget.entry == null ? 'Save transaction' : 'Save changes',
              emphasis: true,
              loading: saving,
              onTap: saving ? null : _save,
            )),
          ]),
        ),
      ),
    );
  }
}

class _EditorAction extends StatelessWidget {
  const _EditorAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.emphasis = false,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool emphasis;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    color: emphasis ? Colors.white : panel,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          height: 54,
          child: Center(child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Icon(icon, size: 23,
                color: emphasis ? Colors.black : Colors.white)),
        ),
      ),
    ),
  );
}
