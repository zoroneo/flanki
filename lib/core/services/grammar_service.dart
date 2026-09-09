import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammar/grammar_models.dart';

final grammarServiceProvider = Provider<GrammarService>((ref) {
  return GrammarService();
});

final grammarUnitsProvider = FutureProvider<List<GrammarUnit>>((ref) async {
  final service = ref.watch(grammarServiceProvider);
  return service.loadAllUnits();
});

class GrammarService {
  List<GrammarUnit>? _cachedUnits;

  /// Loads all 36 grammar units from assets or returns in-memory cache
  Future<List<GrammarUnit>> loadAllUnits({AssetBundle? bundle}) async {
    if (_cachedUnits != null && _cachedUnits!.isNotEmpty) {
      return _cachedUnits!;
    }

    final targetBundle = bundle ?? rootBundle;
    final units = <GrammarUnit>[];

    for (int i = 1; i <= GrammarConstants.totalUnits; i++) {
      final unitNum = i.toString().padLeft(2, '0');
      final path = '${GrammarConstants.assetDir}/unit_$unitNum.json';

      try {
        final jsonString = await targetBundle.loadString(path);
        final dynamic decoded = jsonDecode(jsonString);
        if (decoded is Map<String, dynamic>) {
          units.add(GrammarUnit.fromJson(decoded));
        } else if (decoded is Map) {
          units.add(GrammarUnit.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (e) {
        // Fallback or rethrow depending on mode
        throw Exception('Failed to load grammar unit from $path: $e');
      }
    }

    // Sort by level then unitId
    units.sort((a, b) {
      if (a.level != b.level) {
        return a.level.value.compareTo(b.level.value);
      }
      return a.unitId.compareTo(b.unitId);
    });

    _cachedUnits = units;
    return units;
  }

  /// Get a single unit by unitId
  Future<GrammarUnit?> getUnit(String unitId, {AssetBundle? bundle}) async {
    final allUnits = await loadAllUnits(bundle: bundle);
    try {
      return allUnits.firstWhere((u) => u.unitId == unitId);
    } catch (_) {
      return null;
    }
  }

  /// Filter units by level
  List<GrammarUnit> filterByLevel(GrammarLevel level) {
    if (_cachedUnits == null) return [];
    return _cachedUnits!.where((u) => u.level == level).toList();
  }

  /// Filter units by category
  List<GrammarUnit> filterByCategory(GrammarCategory category) {
    if (_cachedUnits == null) return [];
    return _cachedUnits!.where((u) => u.category == category).toList();
  }

  /// Get unique categories in display order
  List<GrammarCategory> getCategories() {
    if (_cachedUnits == null) return [];
    final set = <GrammarCategory>{};
    for (final u in _cachedUnits!) {
      set.add(u.category);
    }
    return set.toList();
  }

  /// Total number of exercises across all cached units
  int get totalExercises {
    if (_cachedUnits == null) return GrammarConstants.totalExercises;
    return _cachedUnits!.fold<int>(0, (sum, u) => sum + u.totalExercises);
  }

  /// Clear cache if needed (e.g. for testing)
  void clearCache() {
    _cachedUnits = null;
  }
}
