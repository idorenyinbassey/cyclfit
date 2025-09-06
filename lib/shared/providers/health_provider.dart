import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/app_database.dart';

class HealthProvider extends ChangeNotifier {
  final AppDatabase _database;

  // Health metrics
  double _weight = 0.0;
  double _bodyFat = 0.0;
  int _restingHeartRate = 0;
  String _bloodPressure = '';
  double _vo2Max = 0.0;
  int _sleepHours = 0;
  int _sleepMinutes = 0;
  int _dailyCalories = 0;
  double _waterIntake = 0.0;
  // Additional tracked metrics
  double _bloodGlucose = 0.0; // mg/dL
  double _cholesterolTotal = 0.0; // mg/dL
  double _hba1c = 0.0; // %
  double _sleepEfficiency = 0.0; // %
  double _deepSleepHours = 0.0; // hours
  double _remSleepHours = 0.0; // hours
  int _proteinGrams = 0;
  int _carbGrams = 0;
  int _fatGrams = 0;

  // Health score calculation
  int _healthScore = 0;

  HealthProvider({required AppDatabase database}) : _database = database;

  // Getters
  double get weight => _weight;
  double get bodyFat => _bodyFat;
  int get restingHeartRate => _restingHeartRate;
  String get bloodPressure => _bloodPressure;
  double get vo2Max => _vo2Max;
  int get sleepHours => _sleepHours;
  int get sleepMinutes => _sleepMinutes;
  int get dailyCalories => _dailyCalories;
  double get waterIntake => _waterIntake;
  int get healthScore => _healthScore;
  double get bloodGlucose => _bloodGlucose;
  double get cholesterolTotal => _cholesterolTotal;
  double get hba1c => _hba1c;
  double get sleepEfficiency => _sleepEfficiency;
  double get deepSleepHours => _deepSleepHours;
  double get remSleepHours => _remSleepHours;
  int get proteinGrams => _proteinGrams;
  int get carbGrams => _carbGrams;
  int get fatGrams => _fatGrams;

  // Check if user has entered any health data
  bool get hasHealthData =>
      _weight > 0 ||
      _restingHeartRate > 0 ||
      _bloodPressure.isNotEmpty ||
      _vo2Max > 0 ||
      _sleepHours > 0 ||
      _dailyCalories > 0 ||
      _waterIntake > 0;

  // Update weight
  Future<void> updateWeight(double weight) async {
    _weight = weight;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('weight', weight, unit: 'kg');
  }

  // Update body fat
  Future<void> updateBodyFat(double bodyFat) async {
    _bodyFat = bodyFat;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('body_fat', bodyFat, unit: '%');
  }

  // Update resting heart rate
  Future<void> updateRestingHeartRate(int heartRate) async {
    _restingHeartRate = heartRate;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('resting_hr', heartRate.toDouble(), unit: 'bpm');
  }

  // Update blood pressure
  Future<void> updateBloodPressure(String bloodPressure) async {
    _bloodPressure = bloodPressure;
    _calculateHealthScore();
    notifyListeners();
    // Try to split into systolic/diastolic
    final parts = bloodPressure.split('/');
    double? sys = parts.isNotEmpty ? double.tryParse(parts[0].trim()) : null;
    double? dia = parts.length > 1 ? double.tryParse(parts[1].trim()) : null;
    await _saveMetric('blood_pressure', sys ?? 0, unit: 'mmHg', secondary: dia);
  }

  // Update VO2 Max
  Future<void> updateVO2Max(double vo2Max) async {
    _vo2Max = vo2Max;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('vo2max', vo2Max, unit: 'ml/kg/min');
  }

  // Update sleep data
  Future<void> updateSleep(int hours, int minutes) async {
    _sleepHours = hours;
    _sleepMinutes = minutes;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('sleep_duration', hours + minutes / 60.0, unit: 'h');
  }

  // Update daily calories
  Future<void> updateDailyCalories(int calories) async {
    _dailyCalories = calories;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('daily_calories', calories.toDouble(), unit: 'cal');
  }

  // Update water intake
  Future<void> updateWaterIntake(double liters) async {
    _waterIntake = liters;
    _calculateHealthScore();
    notifyListeners();
    await _saveMetric('water_intake', liters, unit: 'L');
  }

  // Metabolic
  Future<void> updateBloodGlucose(double mgdl) async {
    _bloodGlucose = mgdl;
    notifyListeners();
    await _saveMetric('blood_glucose', mgdl, unit: 'mg/dL');
  }

  Future<void> updateHba1c(double percent) async {
    _hba1c = percent;
    notifyListeners();
    await _saveMetric('hba1c', percent, unit: '%');
  }

  Future<void> updateCholesterolTotal(double mgdl) async {
    _cholesterolTotal = mgdl;
    notifyListeners();
    await _saveMetric('cholesterol_total', mgdl, unit: 'mg/dL');
  }

  // Sleep & Recovery
  Future<void> updateSleepBreakdown({
    double? deepH,
    double? remH,
    double? efficiency,
  }) async {
    if (deepH != null) _deepSleepHours = deepH;
    if (remH != null) _remSleepHours = remH;
    if (efficiency != null) _sleepEfficiency = efficiency;
    notifyListeners();
    if (deepH != null) await _saveMetric('sleep_deep', deepH, unit: 'h');
    if (remH != null) await _saveMetric('sleep_rem', remH, unit: 'h');
    if (efficiency != null)
      await _saveMetric('sleep_efficiency', efficiency, unit: '%');
  }

  // Nutrition
  Future<void> updateMacros({int? protein, int? carbs, int? fat}) async {
    if (protein != null) _proteinGrams = protein;
    if (carbs != null) _carbGrams = carbs;
    if (fat != null) _fatGrams = fat;
    notifyListeners();
    if (protein != null)
      await _saveMetric('protein', protein.toDouble(), unit: 'g');
    if (carbs != null) await _saveMetric('carbs', carbs.toDouble(), unit: 'g');
    if (fat != null) await _saveMetric('fat', fat.toDouble(), unit: 'g');
  }

  // Persist a metric
  Future<void> _saveMetric(
    String type,
    double value, {
    String unit = '',
    double? secondary,
  }) async {
    try {
      await _database
          .into(_database.healthMetrics)
          .insert(
            HealthMetricsCompanion.insert(
              userId: const Value('local_user'),
              metricType: type,
              value: value,
              unit: unit,
              secondaryValue: secondary != null
                  ? Value(secondary)
                  : const Value.absent(),
              recordedAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // swallow for now; could log
    }
  }

  // Load the latest values from DB (call on app start)
  Future<void> loadLatestMetrics() async {
    try {
      final rows = await (_database.select(
        _database.healthMetrics,
      )..where((t) => t.userId.equals('local_user'))).get();
      // Map of latest by type comparing recordedAt
      final Map<String, HealthMetric> latest = {};
      for (final r in rows) {
        final existing = latest[r.metricType];
        if (existing == null || r.recordedAt.isAfter(existing.recordedAt)) {
          latest[r.metricType] = r;
        }
      }
      double? _getVal(String k) => latest[k]?.value;
      String? _getBP() {
        final r = latest['blood_pressure'];
        if (r == null) return null;
        final s = r.value.toStringAsFixed(0);
        final d = (r.secondaryValue ?? 0).toStringAsFixed(0);
        return '$s/$d';
      }

      _weight = _getVal('weight') ?? _weight;
      _bodyFat = _getVal('body_fat') ?? _bodyFat;
      _restingHeartRate = (_getVal('resting_hr') ?? 0).round();
      _bloodPressure = _getBP() ?? _bloodPressure;
      _vo2Max = _getVal('vo2max') ?? _vo2Max;
      final sd = _getVal('sleep_duration');
      if (sd != null) {
        _sleepHours = sd.floor();
        _sleepMinutes = (((sd - _sleepHours) * 60).round());
      }
      _dailyCalories = (_getVal('daily_calories') ?? 0).round();
      _waterIntake = _getVal('water_intake') ?? _waterIntake;
      _bloodGlucose = _getVal('blood_glucose') ?? _bloodGlucose;
      _hba1c = _getVal('hba1c') ?? _hba1c;
      _cholesterolTotal = _getVal('cholesterol_total') ?? _cholesterolTotal;
      _deepSleepHours = _getVal('sleep_deep') ?? _deepSleepHours;
      _remSleepHours = _getVal('sleep_rem') ?? _remSleepHours;
      _sleepEfficiency = _getVal('sleep_efficiency') ?? _sleepEfficiency;
      _proteinGrams = (_getVal('protein') ?? _proteinGrams.toDouble()).round();
      _carbGrams = (_getVal('carbs') ?? _carbGrams.toDouble()).round();
      _fatGrams = (_getVal('fat') ?? _fatGrams.toDouble()).round();
      _calculateHealthScore();
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  // Calculate health score based on available data
  void _calculateHealthScore() {
    int score = 0;
    int dataPoints = 0;

    // Weight scoring (BMI estimation - assuming height of 175cm)
    if (_weight > 0) {
      double bmi = _weight / (1.75 * 1.75);
      if (bmi >= 18.5 && bmi <= 24.9) {
        score += 15;
      } else if (bmi >= 25 && bmi <= 29.9) {
        score += 10;
      } else {
        score += 5;
      }
      dataPoints++;
    }

    // Resting heart rate scoring
    if (_restingHeartRate > 0) {
      if (_restingHeartRate >= 60 && _restingHeartRate <= 80) {
        score += 20;
      } else if (_restingHeartRate >= 50 && _restingHeartRate <= 90) {
        score += 15;
      } else {
        score += 10;
      }
      dataPoints++;
    }

    // VO2 Max scoring
    if (_vo2Max > 0) {
      if (_vo2Max >= 50) {
        score += 25;
      } else if (_vo2Max >= 40) {
        score += 20;
      } else if (_vo2Max >= 30) {
        score += 15;
      } else {
        score += 10;
      }
      dataPoints++;
    }

    // Sleep scoring
    if (_sleepHours > 0) {
      double totalSleepHours = _sleepHours + (_sleepMinutes / 60);
      if (totalSleepHours >= 7 && totalSleepHours <= 9) {
        score += 15;
      } else if (totalSleepHours >= 6 && totalSleepHours <= 10) {
        score += 10;
      } else {
        score += 5;
      }
      dataPoints++;
    }

    // Water intake scoring
    if (_waterIntake > 0) {
      if (_waterIntake >= 2.5) {
        score += 10;
      } else if (_waterIntake >= 2.0) {
        score += 8;
      } else if (_waterIntake >= 1.5) {
        score += 5;
      } else {
        score += 3;
      }
      dataPoints++;
    }

    // Calculate average if data points exist
    if (dataPoints > 0) {
      _healthScore = (score / dataPoints * 100 / 85).round().clamp(0, 100);
    } else {
      _healthScore = 0;
    }
  }

  // Get formatted sleep time
  String get formattedSleepTime {
    if (_sleepHours == 0 && _sleepMinutes == 0) return '--';
    return '${_sleepHours}h ${_sleepMinutes}m';
  }

  // Get BMI if weight is available
  String get bmi {
    if (_weight == 0) return '--';
    double bmiValue = _weight / (1.75 * 1.75); // Assuming 175cm height
    return bmiValue.toStringAsFixed(1);
  }

  // Get health score status
  String get healthScoreStatus {
    if (_healthScore == 0) return 'No Data';
    if (_healthScore >= 85) return 'Excellent';
    if (_healthScore >= 70) return 'Good';
    if (_healthScore >= 55) return 'Fair';
    if (_healthScore >= 40) return 'Poor';
    return 'Very Poor';
  }
}
