import 'package:flutter/foundation.dart';

import 'package:cadenceiq_app/models/goal_summary.dart';
import 'package:cadenceiq_app/services/mock/mock_summary_repository.dart';

class SummaryProvider extends ChangeNotifier {
  SummaryProvider({MockSummaryRepository? repository})
      : _repository = repository ?? MockSummaryRepository();

  final MockSummaryRepository _repository;

  List<GoalSummary> get summaries => _repository.getAll();

  GoalSummary? getById(String id) => _repository.getById(id);
}
