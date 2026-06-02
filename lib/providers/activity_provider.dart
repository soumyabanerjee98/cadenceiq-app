import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/activity.dart';
import 'package:cadenceiq_app/services/mock/mock_activity_repository.dart';

enum LoadState { initial, loading, loaded, error, empty }

class ActivityProvider extends ChangeNotifier {
  ActivityProvider({MockActivityRepository? repository})
      : _repository = repository ?? MockActivityRepository();

  final MockActivityRepository _repository;

  LoadState _state = LoadState.initial;
  List<Activity> _activities = [];
  String _searchQuery = '';
  TrainingZone? _zoneFilter;
  String? _errorMessage;

  LoadState get state => _state;
  List<Activity> get activities => _filtered;
  String get searchQuery => _searchQuery;
  TrainingZone? get zoneFilter => _zoneFilter;
  String? get errorMessage => _errorMessage;

  List<Activity> get _filtered {
    var list = _searchQuery.isEmpty
        ? _activities
        : _repository.search(_searchQuery);
    if (_zoneFilter != null) {
      list = list.where((a) => a.zone == _zoneFilter).toList();
    }
    return list;
  }

  Activity? getById(String id) => _repository.getById(id);

  Future<void> load() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      _activities = await _repository.fetchAll();
      _state = _activities.isEmpty ? LoadState.empty : LoadState.loaded;
    } catch (e) {
      _state = LoadState.error;
      _errorMessage = 'Failed to load activities.';
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setZoneFilter(TrainingZone? zone) {
    _zoneFilter = zone;
    notifyListeners();
  }

  void simulateError() {
    _state = LoadState.error;
    _errorMessage = 'Something went wrong. Pull to refresh.';
    notifyListeners();
  }
}
