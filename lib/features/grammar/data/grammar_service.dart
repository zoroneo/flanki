import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../models/grammar_models.dart';

part 'grammar_service.g.dart';

@Riverpod(keepAlive: true)
GrammarService grammarService(Ref ref) {
  return GrammarService();
}

@Riverpod(keepAlive: true)
Future<List<GrammarUnit>> grammarUnits(Ref ref) async {
  final service = ref.watch(grammarServiceProvider);
  return service.loadAllUnits();
}

/// Targeted single-unit provider for instant loading without waiting for all 36 units.
@Riverpod(keepAlive: true)
Future<GrammarUnit?> grammarUnit(Ref ref, String unitId) async {
  final service = ref.watch(grammarServiceProvider);
  return service.getUnit(unitId);
}

class GrammarService {
  List<GrammarUnit>? _cachedUnits;
  final Map<String, GrammarUnit> _unitByIdCache = {};
  Future<List<GrammarUnit>>? _loadAllFuture;
  static final RegExp _unitNumRegex = RegExp(r'unit[-_](\d+)');

  /// Loads all 36 grammar units concurrently in parallel, or returns in-memory cache
  Future<List<GrammarUnit>> loadAllUnits({AssetBundle? bundle}) async {
    if (_cachedUnits != null && _cachedUnits!.isNotEmpty) {
      return _cachedUnits!;
    }
    if (_loadAllFuture != null) {
      return _loadAllFuture!;
    }

    _loadAllFuture = _doLoadAllUnits(bundle: bundle);
    try {
      return await _loadAllFuture!;
    } finally {
      _loadAllFuture = null;
    }
  }

  Future<List<GrammarUnit>> _doLoadAllUnits({AssetBundle? bundle}) async {
    final targetBundle = bundle ?? rootBundle;
    final paths = List.generate(
      GrammarConstants.totalUnits,
      (i) => GrammarConstants.unitAssetPath(i + 1),
    );

    final units = await Future.wait(
      paths.map((path) async {
        try {
          final jsonString = await targetBundle.loadString(path);
          final dynamic decoded = jsonDecode(jsonString);
          if (decoded is Map<String, dynamic>) {
            return GrammarUnit.fromJson(decoded);
          } else if (decoded is Map) {
            return GrammarUnit.fromJson(Map<String, dynamic>.from(decoded));
          }
          throw FormatException('Invalid JSON map in $path');
        } catch (e) {
          throw Exception('${AppConfig.errFailedLoadGrammarUnitPrefix}$path: $e');
        }
      }),
    );

    // Sort by level then unitId
    units.sort((a, b) {
      if (a.level != b.level) {
        return a.level.value.compareTo(b.level.value);
      }
      return a.unitId.compareTo(b.unitId);
    });

    _cachedUnits = units;
    for (final u in units) {
      _unitByIdCache[u.unitId] = u;
    }
    return units;
  }

  /// Get a single unit by unitId with fast direct single-asset load & caching
  Future<GrammarUnit?> getUnit(String unitId, {AssetBundle? bundle}) async {
    if (_unitByIdCache.containsKey(unitId)) {
      return _unitByIdCache[unitId];
    }
    if (_cachedUnits != null) {
      final found = _cachedUnits!.cast<GrammarUnit?>().firstWhere(
        (u) => u?.unitId == unitId,
        orElse: () => null,
      );
      if (found != null) {
        _unitByIdCache[unitId] = found;
        return found;
      }
      return null;
    }

    // Direct single-asset load by extracting unit number (e.g. unit-01-... -> 1)
    final match = _unitNumRegex.firstMatch(unitId);
    if (match != null) {
      final unitNum = int.tryParse(match.group(1)!);
      if (unitNum != null &&
          unitNum >= 1 &&
          unitNum <= GrammarConstants.totalUnits) {
        final path = GrammarConstants.unitAssetPath(unitNum);
        try {
          final targetBundle = bundle ?? rootBundle;
          final jsonString = await targetBundle.loadString(path);
          final dynamic decoded = jsonDecode(jsonString);
          final GrammarUnit unit;
          if (decoded is Map<String, dynamic>) {
            unit = GrammarUnit.fromJson(decoded);
          } else if (decoded is Map) {
            unit = GrammarUnit.fromJson(Map<String, dynamic>.from(decoded));
          } else {
            throw FormatException('Invalid JSON in $path');
          }
          if (unit.unitId == unitId) {
            _unitByIdCache[unitId] = unit;
            return unit;
          }
        } catch (_) {
          // Fall through to full load
        }
      }
    }

    // Fallback: load all units if unitId format is non-standard
    final allUnits = await loadAllUnits(bundle: bundle);
    final found = allUnits.cast<GrammarUnit?>().firstWhere(
      (u) => u?.unitId == unitId,
      orElse: () => null,
    );
    if (found != null) {
      _unitByIdCache[unitId] = found;
    }
    return found;
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
    _unitByIdCache.clear();
    _loadAllFuture = null;
  }
}
