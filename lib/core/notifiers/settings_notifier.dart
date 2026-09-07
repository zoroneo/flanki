import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudySettings {
  final bool fsrsEnabled;
  final double desiredRetention;
  final int newCardsPerDay;
  final int maxReviewsPerDay;

  const StudySettings({
    this.fsrsEnabled = true,
    this.desiredRetention = 0.90,
    this.newCardsPerDay = 20,
    this.maxReviewsPerDay = 100,
  });

  StudySettings copyWith({
    bool? fsrsEnabled,
    double? desiredRetention,
    int? newCardsPerDay,
    int? maxReviewsPerDay,
  }) {
    return StudySettings(
      fsrsEnabled: fsrsEnabled ?? this.fsrsEnabled,
      desiredRetention: desiredRetention ?? this.desiredRetention,
      newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fsrsEnabled': fsrsEnabled,
      'desiredRetention': desiredRetention,
      'newCardsPerDay': newCardsPerDay,
      'maxReviewsPerDay': maxReviewsPerDay,
    };
  }

  factory StudySettings.fromMap(Map<String, dynamic> map) {
    return StudySettings(
      fsrsEnabled: map['fsrsEnabled'] as bool? ?? true,
      desiredRetention: (map['desiredRetention'] as num?)?.toDouble() ?? 0.90,
      newCardsPerDay: (map['newCardsPerDay'] as num?)?.toInt() ?? 20,
      maxReviewsPerDay: (map['maxReviewsPerDay'] as num?)?.toInt() ?? 100,
    );
  }
}

const String _kFsrsEnabledKey = 'settings_fsrs_enabled';
const String _kDesiredRetentionKey = 'settings_desired_retention';
const String _kNewCardsPerDayKey = 'settings_new_cards_per_day';
const String _kMaxReviewsPerDayKey = 'settings_max_reviews_per_day';

final studySettingsProvider =
    NotifierProvider<StudySettingsNotifier, StudySettings>(
  StudySettingsNotifier.new,
);

class StudySettingsNotifier extends Notifier<StudySettings> {
  final _storage = const FlutterSecureStorage();

  @override
  StudySettings build() {
    _loadPreferences();
    return const StudySettings();
  }

  Future<void> _loadPreferences() async {
    try {
      final fsrsVal = await _storage.read(key: _kFsrsEnabledKey);
      final retVal = await _storage.read(key: _kDesiredRetentionKey);
      final newCardsVal = await _storage.read(key: _kNewCardsPerDayKey);
      final maxReviewsVal = await _storage.read(key: _kMaxReviewsPerDayKey);

      state = StudySettings(
        fsrsEnabled: fsrsVal != null ? fsrsVal == 'true' : true,
        desiredRetention: retVal != null ? (double.tryParse(retVal) ?? 0.90) : 0.90,
        newCardsPerDay: newCardsVal != null ? (int.tryParse(newCardsVal) ?? 20) : 20,
        maxReviewsPerDay: maxReviewsVal != null ? (int.tryParse(maxReviewsVal) ?? 100) : 100,
      );
    } catch (_) {}
  }

  Future<void> toggleFsrs(bool enabled) async {
    state = state.copyWith(fsrsEnabled: enabled);
    try {
      await _storage.write(key: _kFsrsEnabledKey, value: enabled ? 'true' : 'false');
    } catch (_) {}
  }

  Future<void> setDesiredRetention(double retention) async {
    final clamped = retention.clamp(0.70, 0.97);
    state = state.copyWith(desiredRetention: clamped);
    try {
      await _storage.write(key: _kDesiredRetentionKey, value: clamped.toStringAsFixed(2));
    } catch (_) {}
  }

  Future<void> setNewCardsPerDay(int count) async {
    final clamped = count.clamp(1, 200);
    state = state.copyWith(newCardsPerDay: clamped);
    try {
      await _storage.write(key: _kNewCardsPerDayKey, value: clamped.toString());
    } catch (_) {}
  }

  Future<void> setMaxReviewsPerDay(int count) async {
    final clamped = count.clamp(5, 1000);
    state = state.copyWith(maxReviewsPerDay: clamped);
    try {
      await _storage.write(key: _kMaxReviewsPerDayKey, value: clamped.toString());
    } catch (_) {}
  }

  Future<void> updateSettings(StudySettings settings) async {
    state = settings;
    try {
      await _storage.write(key: _kFsrsEnabledKey, value: settings.fsrsEnabled ? 'true' : 'false');
      await _storage.write(key: _kDesiredRetentionKey, value: settings.desiredRetention.toStringAsFixed(2));
      await _storage.write(key: _kNewCardsPerDayKey, value: settings.newCardsPerDay.toString());
      await _storage.write(key: _kMaxReviewsPerDayKey, value: settings.maxReviewsPerDay.toString());
    } catch (_) {}
  }
}

final fsrsEnabledProvider = NotifierProvider<FsrsEnabledNotifier, bool>(
  FsrsEnabledNotifier.new,
);

class FsrsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(studySettingsProvider).fsrsEnabled;
  }

  Future<void> toggle(bool enabled) async {
    await ref.read(studySettingsProvider.notifier).toggleFsrs(enabled);
  }
}
