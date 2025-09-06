import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HealthDataProvider extends ChangeNotifier {
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

  // Health score calculation
  int _healthScore = 0;

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
  void updateWeight(double weight) {
    _weight = weight;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update body fat
  void updateBodyFat(double bodyFat) {
    _bodyFat = bodyFat;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update resting heart rate
  void updateRestingHeartRate(int heartRate) {
    _restingHeartRate = heartRate;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update blood pressure
  void updateBloodPressure(String bloodPressure) {
    _bloodPressure = bloodPressure;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update VO2 Max
  void updateVO2Max(double vo2Max) {
    _vo2Max = vo2Max;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update sleep data
  void updateSleep(int hours, int minutes) {
    _sleepHours = hours;
    _sleepMinutes = minutes;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update daily calories
  void updateDailyCalories(int calories) {
    _dailyCalories = calories;
    _calculateHealthScore();
    notifyListeners();
  }

  // Update water intake
  void updateWaterIntake(double liters) {
    _waterIntake = liters;
    _calculateHealthScore();
    notifyListeners();
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
    if (_healthScore >= 85) return 'Excellent';
    if (_healthScore >= 70) return 'Good';
    if (_healthScore >= 55) return 'Fair';
    if (_healthScore >= 40) return 'Poor';
    return 'Very Poor';
  }
}

class HealthMetric {
  final String name;
  final String value;
  final String status;
  final Color statusColor;

  HealthMetric(this.name, this.value, this.status, this.statusColor);
}
