import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/health_provider.dart';

class HealthInputDialog extends StatefulWidget {
  const HealthInputDialog({super.key});

  @override
  State<HealthInputDialog> createState() => _HealthInputDialogState();
}

class _HealthInputDialogState extends State<HealthInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _vo2MaxController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _sleepMinutesController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    // Pre-fill existing data
    if (healthProvider.weight > 0) {
      _weightController.text = healthProvider.weight.toString();
    }
    if (healthProvider.bodyFat > 0) {
      _bodyFatController.text = healthProvider.bodyFat.toString();
    }
    if (healthProvider.restingHeartRate > 0) {
      _heartRateController.text = healthProvider.restingHeartRate.toString();
    }
    if (healthProvider.bloodPressure.isNotEmpty) {
      _bloodPressureController.text = healthProvider.bloodPressure;
    }
    if (healthProvider.vo2Max > 0) {
      _vo2MaxController.text = healthProvider.vo2Max.toString();
    }
    if (healthProvider.sleepHours > 0) {
      _sleepHoursController.text = healthProvider.sleepHours.toString();
    }
    if (healthProvider.sleepMinutes > 0) {
      _sleepMinutesController.text = healthProvider.sleepMinutes.toString();
    }
    if (healthProvider.dailyCalories > 0) {
      _caloriesController.text = healthProvider.dailyCalories.toString();
    }
    if (healthProvider.waterIntake > 0) {
      _waterController.text = healthProvider.waterIntake.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _vo2MaxController.dispose();
    _sleepHoursController.dispose();
    _sleepMinutesController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Health Data'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  hint: 'Enter your weight',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bodyFatController,
                  label: 'Body Fat (%)',
                  hint: 'Enter body fat percentage',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _heartRateController,
                  label: 'Resting Heart Rate (bpm)',
                  hint: 'Enter resting heart rate',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bloodPressureController,
                  label: 'Blood Pressure',
                  hint: 'e.g., 120/80',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vo2MaxController,
                  label: 'VO2 Max',
                  hint: 'Enter VO2 Max value',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _sleepHoursController,
                        label: 'Sleep Hours',
                        hint: 'Hours',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _sleepMinutesController,
                        label: 'Sleep Minutes',
                        hint: 'Minutes',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Daily Calories Consumed',
                  hint: 'Enter calories',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _waterController,
                  label: 'Water Intake (L)',
                  hint: 'Enter liters of water',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveHealthData, child: const Text('Save')),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _saveHealthData() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    // Update weight
    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight != null && weight > 0) {
        healthProvider.updateWeight(weight);
      }
    }

    // Update body fat
    if (_bodyFatController.text.isNotEmpty) {
      final bodyFat = double.tryParse(_bodyFatController.text);
      if (bodyFat != null && bodyFat >= 0) {
        healthProvider.updateBodyFat(bodyFat);
      }
    }

    // Update heart rate
    if (_heartRateController.text.isNotEmpty) {
      final heartRate = int.tryParse(_heartRateController.text);
      if (heartRate != null && heartRate > 0) {
        healthProvider.updateRestingHeartRate(heartRate);
      }
    }

    // Update blood pressure
    if (_bloodPressureController.text.isNotEmpty) {
      healthProvider.updateBloodPressure(_bloodPressureController.text);
    }

    // Update VO2 Max
    if (_vo2MaxController.text.isNotEmpty) {
      final vo2Max = double.tryParse(_vo2MaxController.text);
      if (vo2Max != null && vo2Max > 0) {
        healthProvider.updateVO2Max(vo2Max);
      }
    }

    // Update sleep
    final sleepHours = int.tryParse(_sleepHoursController.text) ?? 0;
    final sleepMinutes = int.tryParse(_sleepMinutesController.text) ?? 0;
    if (sleepHours > 0 || sleepMinutes > 0) {
      healthProvider.updateSleep(sleepHours, sleepMinutes);
    }

    // Update calories
    if (_caloriesController.text.isNotEmpty) {
      final calories = int.tryParse(_caloriesController.text);
      if (calories != null && calories > 0) {
        healthProvider.updateDailyCalories(calories);
      }
    }

    // Update water intake
    if (_waterController.text.isNotEmpty) {
      final water = double.tryParse(_waterController.text);
      if (water != null && water > 0) {
        healthProvider.updateWaterIntake(water);
      }
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Health data updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
