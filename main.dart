import 'package:flutter/material.dart';
import 'data/ledger.dart';
import 'ui/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuroraFinanceApp());
}

class AuroraFinanceApp extends StatefulWidget {
  const AuroraFinanceApp({super.key});

  @override
  State<AuroraFinanceApp> createState() => _AuroraFinanceAppState();
}

class _AuroraFinanceAppState extends State<AuroraFinanceApp> {
  late final LedgerController finance = LedgerController(LedgerStore());

  @override
  void initState() {
    super.initState();
    finance.load();
  }

  @override
  void dispose() {
    finance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Aurora Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0C0C0D),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF222224),
            primary: Colors.white,
            onPrimary: Color(0xFF111111),
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF242426),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          ),
        ),
        home: AnimatedBuilder(
          animation: finance,
          builder: (_, __) {
            if (!finance.ready) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (finance.error != null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(finance.error!, textAlign: TextAlign.center),
                  ),
                ),
              );
            }
            return FinanceShell(finance: finance);
          },
        ),
      );
}
