import 'dart:collection';

import '../config/app_config.dart';

/// Represents an individual trail event leading up to an error or crash.
class Breadcrumb {
  final DateTime timestamp;
  final String category;
  final String message;
  final String level;
  final Map<String, dynamic>? data;

  Breadcrumb({
    DateTime? timestamp,
    required this.category,
    required this.message,
    this.level = 'info',
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'message': message,
      'level': level,
      if (data != null && data!.isNotEmpty) 'data': data,
    };
  }

  @override
  String toString() =>
      '[$level] [$category] $message (${timestamp.toIso8601String()})';
}

/// Circular in-memory buffer tracking the last N user actions and diagnostic events.
class BreadcrumbTracker {
  static final BreadcrumbTracker instance = BreadcrumbTracker._();

  static const int defaultCapacity = AppConfig.breadcrumbDefaultCapacity;
  final int capacity;
  final ListQueue<Breadcrumb> _buffer;

  BreadcrumbTracker._({this.capacity = defaultCapacity})
      : _buffer = ListQueue<Breadcrumb>(capacity);

  /// Factory for isolated testing with custom capacity.
  factory BreadcrumbTracker.test({int capacity = defaultCapacity}) {
    return BreadcrumbTracker._(capacity: capacity);
  }

  /// Adds a generic breadcrumb, evicting the oldest entry when at capacity.
  void add(Breadcrumb breadcrumb) {
    if (_buffer.length >= capacity) {
      _buffer.removeFirst();
    }
    _buffer.addLast(breadcrumb);
  }

  /// Records screen navigation or route change.
  void addNavigation(String from, String to) {
    add(Breadcrumb(
      category: 'navigation',
      message: 'Navigated from $from to $to',
      data: {'from': from, 'to': to},
    ));
  }

  /// Records user interaction (e.g. button tap, card swipe, dialog dismissal).
  void addAction(String action, {Map<String, dynamic>? details}) {
    add(Breadcrumb(
      category: 'action',
      message: action,
      data: details,
    ));
  }

  /// Records an HTTP/API network request and response status.
  void addNetwork(String method, String url, {int? statusCode, String? error}) {
    final data = <String, dynamic>{
      'method': method,
      'url': url,
    };
    if (statusCode != null) data['status_code'] = statusCode;
    if (error != null) data['error'] = error;

    add(Breadcrumb(
      category: 'network',
      message: '$method $url ${statusCode != null ? '-> $statusCode' : ''}'.trim(),
      level: (statusCode != null && statusCode >= 400) || error != null
          ? 'warning'
          : 'info',
      data: data,
    ));
  }

  /// Records synchronization engine events.
  void addSync(String message, {bool isSuccess = true, Map<String, dynamic>? data}) {
    add(Breadcrumb(
      category: 'sync',
      message: message,
      level: isSuccess ? 'info' : 'warning',
      data: data,
    ));
  }

  /// Returns unmodifiable list of breadcrumbs from oldest to newest.
  List<Breadcrumb> get breadcrumbs => List.unmodifiable(_buffer);

  /// Exports current breadcrumbs as JSON list for database persistence.
  List<Map<String, dynamic>> toJsonList() {
    return _buffer.map((b) => b.toJson()).toList();
  }

  /// Clears buffer.
  void clear() {
    _buffer.clear();
  }
}

