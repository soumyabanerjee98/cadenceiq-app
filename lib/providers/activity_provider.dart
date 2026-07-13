import 'package:cadenceiq_app/core/utils/debouncer.dart';
import 'package:cadenceiq_app/services/repo/activity_repo.dart';
import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/activity.dart';

enum LoadState { initial, loading, loaded, error, empty, loadingMore }

class ActivityProvider extends ChangeNotifier {
  ActivityProvider({ActivityRepository? repository})
    : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  LoadState _state = LoadState.initial;
  int currentPage = 1;
  bool hasNext = false;
  List<Activity> activities = [];
  String _searchQuery = '';
  TrainingZone? _zoneFilter;
  String? _errorMessage;

  LoadState get state => _state;
  String get searchQuery => _searchQuery;
  TrainingZone? get zoneFilter => _zoneFilter;
  String? get errorMessage => _errorMessage;

  Future<List<Activity>> filter() async {
    List<Activity> filterActivities = activities;
    final res = await _repository.fetch(
      currentPage: currentPage,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      zone: _zoneFilter,
    );
    if (res.response != null) {
      filterActivities = (res.response["activities"] as List)
          .map((e) => Activity.fromJson(e))
          .toList();
      _state = activities.isEmpty ? LoadState.empty : LoadState.loaded;
    }
    return filterActivities;
  }

  Activity getById(String id) => activities.firstWhere((e) => e.id == id);

  Future<void> load() async {
    _state = LoadState.loading;
    notifyListeners();
    final res = await _repository.fetch(currentPage: currentPage);
    if (res.response != null) {
      activities = (res.response["activities"] as List)
          .map((e) => Activity.fromJson(e))
          .toList();
      hasNext = res.response["hasNext"];
      _state = activities.isEmpty ? LoadState.empty : LoadState.loaded;
    } else {
      _state = LoadState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (hasNext == false || _state == LoadState.loadingMore) return;
    _state = LoadState.loadingMore;
    notifyListeners();
    currentPage++;
    final res = await _repository.fetch(currentPage: currentPage);
    if (res.response != null) {
      activities = [
        ...activities,
        ...(res.response["activities"] as List).map(
          (e) => Activity.fromJson(e),
        ),
      ];
      hasNext = res.response["hasNext"];
      _state = activities.isEmpty ? LoadState.empty : LoadState.loaded;
    } else {
      _state = LoadState.error;
      _errorMessage = res.error?.errorMessage;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    currentPage = 1;
    hasNext = false;
    load();
  }

  Future<void> setSearch(String query) async {
    _searchQuery = query;
    debouncer(() async {
      _state = LoadState.loading;
      notifyListeners();
      final filteredActivities = await filter();
      activities = filteredActivities;
      _state = activities.isEmpty ? LoadState.empty : LoadState.loaded;
      notifyListeners();
    });
  }

  Future<void> setZoneFilter(TrainingZone? zone) async {
    _zoneFilter = zone;
    _state = LoadState.loading;
    notifyListeners();
    final filteredActivities = await filter();
    activities = filteredActivities;
    _state = activities.isEmpty ? LoadState.empty : LoadState.loaded;
    notifyListeners();
  }

  void simulateError() {
    _state = LoadState.error;
    _errorMessage = 'Something went wrong. Pull to refresh.';
    notifyListeners();
  }
}
