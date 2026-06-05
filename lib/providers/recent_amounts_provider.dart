import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<SharedPreferences> sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

class RecentAmountsNotifier extends Notifier<List<double>> {
  static const String _key = 'recent_amounts';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  List<double> build() {
    final List<String>? stored = _prefs.getStringList(_key);
    if (stored == null) {
      return <double>[];
    }
    // Parse values, handle any invalid formats gracefully
    final List<double> list = <double>[];
    for (final String s in stored) {
      final double? val = double.tryParse(s);
      if (val != null) {
        list.add(val);
      }
    }
    return list;
  }

  void addAmount(double amount) {
    final List<double> current = List<double>.from(state);

    // Remove if already exists (to move it to the front as most recent)
    current.remove(amount);

    // Add to the front (most recent first)
    current.insert(0, amount);

    // Evict oldest if size > 20
    if (current.length > 20) {
      current.removeLast();
    }

    state = current;
    _prefs.setStringList(_key, current.map((double e) => e.toString()).toList());
  }
}

final NotifierProvider<RecentAmountsNotifier, List<double>> recentAmountsProvider =
    NotifierProvider<RecentAmountsNotifier, List<double>>(() {
  return RecentAmountsNotifier();
});
