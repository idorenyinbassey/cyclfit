import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/health_provider.dart';
import '../widgets/health_input_dialog.dart';

class HealthDashboardPage extends StatelessWidget {
  const HealthDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showHealthInput(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHealthHistory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHealthScore(context),
            const SizedBox(height: 24),
            _buildCardiovascularHealth(context),
            const SizedBox(height: 16),
            _buildBodyComposition(context),
            const SizedBox(height: 16),
            _buildMetabolicHealth(context),
            const SizedBox(height: 16),
            _buildSleepRecovery(context),
            const SizedBox(height: 16),
            _buildNutritionHydration(context),
            const SizedBox(height: 24),
            _buildHealthInsights(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        if (!healthProvider.hasHealthData) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Health Data',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your health metrics and get your personalized health score',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showHealthInput(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Health Data'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.blue.shade100],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getHealthScoreColor(healthProvider.healthScore),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      '${healthProvider.healthScore}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Score',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        healthProvider.healthScoreStatus,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _getHealthScoreColor(
                                healthProvider.healthScore,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your health metrics. Keep tracking to improve your score!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardiovascularHealth(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        if (!healthProvider.hasHealthData) {
          return _buildEmptyHealthCard(
            context,
            title: 'Cardiovascular Health',
            icon: Icons.favorite,
            color: Colors.red,
            description:
                'Add your heart rate, blood pressure, and VO2 Max data',
          );
        }

        List<HealthMetric> metrics = [];

        if (healthProvider.restingHeartRate > 0) {
          String status =
              healthProvider.restingHeartRate >= 60 &&
                  healthProvider.restingHeartRate <= 80
              ? 'Excellent'
              : 'Good';
          Color statusColor =
              healthProvider.restingHeartRate >= 60 &&
                  healthProvider.restingHeartRate <= 80
              ? Colors.green
              : Colors.orange;
          metrics.add(
            HealthMetric(
              'Resting Heart Rate',
              '${healthProvider.restingHeartRate} BPM',
              status,
              statusColor,
            ),
          );
        }

        if (healthProvider.bloodPressure.isNotEmpty) {
          metrics.add(
            HealthMetric(
              'Blood Pressure',
              healthProvider.bloodPressure,
              'Normal',
              Colors.green,
            ),
          );
        }

        if (healthProvider.vo2Max > 0) {
          String status = healthProvider.vo2Max >= 50
              ? 'Superior'
              : (healthProvider.vo2Max >= 40 ? 'Excellent' : 'Good');
          Color statusColor = healthProvider.vo2Max >= 40
              ? Colors.green
              : Colors.orange;
          metrics.add(
            HealthMetric(
              'VO₂ Max',
              '${healthProvider.vo2Max.toStringAsFixed(1)} ml/kg/min',
              status,
              statusColor,
            ),
          );
        }

        if (metrics.isEmpty) {
          return _buildEmptyHealthCard(
            context,
            title: 'Cardiovascular Health',
            icon: Icons.favorite,
            color: Colors.red,
            description:
                'Add your heart rate, blood pressure, and VO2 Max data',
          );
        }

        return _buildHealthCategoryCard(
          context,
          title: 'Cardiovascular Health',
          icon: Icons.favorite,
          color: Colors.red,
          metrics: metrics,
          insight:
              'Keep tracking your cardiovascular metrics to monitor your heart health.',
        );
      },
    );
  }

  Widget _buildBodyComposition(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        if (!healthProvider.hasHealthData) {
          return _buildEmptyHealthCard(
            context,
            title: 'Body Composition',
            icon: Icons.accessibility,
            color: Colors.blue,
            description: 'Add your weight and body fat percentage',
          );
        }

        List<HealthMetric> metrics = [];

        if (healthProvider.weight > 0) {
          metrics.add(
            HealthMetric(
              'Weight',
              '${healthProvider.weight.toStringAsFixed(1)} kg',
              'Stable',
              Colors.green,
            ),
          );

          // Add BMI if weight is available
          metrics.add(
            HealthMetric('BMI', healthProvider.bmi, 'Normal', Colors.green),
          );
        }

        if (healthProvider.bodyFat > 0) {
          String status = healthProvider.bodyFat <= 15
              ? 'Athletic'
              : (healthProvider.bodyFat <= 20 ? 'Good' : 'Normal');
          Color statusColor = healthProvider.bodyFat <= 20
              ? Colors.green
              : Colors.orange;
          metrics.add(
            HealthMetric(
              'Body Fat',
              '${healthProvider.bodyFat.toStringAsFixed(1)}%',
              status,
              statusColor,
            ),
          );
        }

        if (metrics.isEmpty) {
          return _buildEmptyHealthCard(
            context,
            title: 'Body Composition',
            icon: Icons.accessibility,
            color: Colors.blue,
            description: 'Add your weight and body fat percentage',
          );
        }

        return _buildHealthCategoryCard(
          context,
          title: 'Body Composition',
          icon: Icons.accessibility,
          color: Colors.blue,
          metrics: metrics,
          insight:
              'Maintaining a healthy body composition supports your cycling performance.',
        );
      },
    );
  }

  Widget _buildMetabolicHealth(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, hp, _) {
        final metrics = <HealthMetric>[];
        if (hp.bloodGlucose > 0) {
          metrics.add(HealthMetric('Blood Glucose', '${hp.bloodGlucose.toStringAsFixed(0)} mg/dL', '—', Colors.blue));
        }
        if (hp.hba1c > 0) {
          metrics.add(HealthMetric('HbA1c', '${hp.hba1c.toStringAsFixed(1)}%', '—', Colors.blue));
        }
        if (hp.cholesterolTotal > 0) {
          metrics.add(HealthMetric('Cholesterol (Total)', '${hp.cholesterolTotal.toStringAsFixed(0)} mg/dL', '—', Colors.blue));
        }
        return _buildHealthCategoryCard(
          context,
          title: 'Metabolic Health',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          metrics: metrics.isNotEmpty
              ? metrics
              : [
                  HealthMetric('No Data', '—', 'Tap to add', Colors.grey),
                ],
          insight:
              'Outstanding metabolic health. Your cycling routine has boosted your metabolism and improved insulin sensitivity.',
          onAdd: () => _showMetabolicInput(context),
        );
      },
    );
  }

  Widget _buildSleepRecovery(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, hp, _) {
        final metrics = <HealthMetric>[];
        final sleep = hp.formattedSleepTime;
        if (sleep != '--') {
          metrics.add(HealthMetric('Sleep Duration', sleep, '—', Colors.blue));
        }
        if (hp.deepSleepHours > 0) {
          metrics.add(HealthMetric('Deep Sleep', '${hp.deepSleepHours.toStringAsFixed(1)} h', '—', Colors.blue));
        }
        if (hp.remSleepHours > 0) {
          metrics.add(HealthMetric('REM Sleep', '${hp.remSleepHours.toStringAsFixed(1)} h', '—', Colors.blue));
        }
        if (hp.sleepEfficiency > 0) {
          metrics.add(HealthMetric('Sleep Efficiency', '${hp.sleepEfficiency.toStringAsFixed(0)}%', '—', Colors.blue));
        }
        return _buildHealthCategoryCard(
          context,
          title: 'Sleep & Recovery',
          icon: Icons.bed,
          color: Colors.purple,
          metrics: metrics.isNotEmpty
              ? metrics
              : [HealthMetric('No Data', '—', 'Tap to add', Colors.grey)],
          insight:
              'Great sleep quality! Your body is recovering well from training. Consider 15 more minutes for peak performance.',
          onAdd: () => _showSleepInput(context),
        );
      },
    );
  }

  Widget _buildNutritionHydration(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, hp, _) {
        final metrics = <HealthMetric>[];
        if (hp.dailyCalories > 0) {
          metrics.add(HealthMetric('Daily Calories', '${hp.dailyCalories} cal', '—', Colors.blue));
        }
        if (hp.proteinGrams > 0) {
          metrics.add(HealthMetric('Protein', '${hp.proteinGrams} g', '—', Colors.blue));
        }
        if (hp.carbGrams > 0) {
          metrics.add(HealthMetric('Carbs', '${hp.carbGrams} g', '—', Colors.blue));
        }
        if (hp.fatGrams > 0) {
          metrics.add(HealthMetric('Fat', '${hp.fatGrams} g', '—', Colors.blue));
        }
        if (hp.waterIntake > 0) {
          metrics.add(HealthMetric('Water', '${hp.waterIntake.toStringAsFixed(1)} L', '—', Colors.blue));
        }
        return _buildHealthCategoryCard(
          context,
          title: 'Nutrition & Hydration',
          icon: Icons.restaurant,
          color: Colors.teal,
          metrics: metrics.isNotEmpty
              ? metrics
              : [HealthMetric('No Data', '—', 'Tap to add', Colors.grey)],
          insight:
              'Excellent nutrition for an athlete. Your macro balance supports both performance and recovery.',
          onAdd: () => _showNutritionInput(context),
        );
      },
    );
  }

  Widget _buildHealthCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<HealthMetric> metrics,
    required String insight,
    VoidCallback? onAdd,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onAdd != null)
                      IconButton(
                        tooltip: 'Add',
                        icon: const Icon(Icons.add),
                        onPressed: onAdd,
                      ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        // TODO: Navigate to detailed view
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...metrics
                .map(
                  (metric) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            metric.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            metric.value,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: metric.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              metric.status,
                              style: TextStyle(
                                color: metric.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                ,
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInsights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights & Recommendations',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInsightItem(
                  context,
                  '🎯 Performance Trend',
                  'Your fitness has improved 18% over the last 3 months. Keep up the consistent training!',
                  Colors.green,
                ),
                const Divider(),
                _buildInsightItem(
                  context,
                  '⚡ Energy Optimization',
                  'Your afternoon rides show 15% better performance. Consider shifting morning rides to afternoon.',
                  Colors.blue,
                ),
                const Divider(),
                _buildInsightItem(
                  context,
                  '🏥 Health Checkup',
                  'Due for annual physical. Your cycling fitness suggests excellent overall health.',
                  Colors.orange,
                ),
                const Divider(),
                _buildInsightItem(
                  context,
                  '🎖️ Achievement Unlocked',
                  'Cardiovascular Elite: VO₂ Max in top 5% for your age group!',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health History',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildHistoryItem(
                      'This Week',
                      'Health Score: 87 (+2)',
                      'All metrics trending positive',
                    ),
                    _buildHistoryItem(
                      'Last Week',
                      'Health Score: 85 (+1)',
                      'Improved cardiovascular metrics',
                    ),
                    _buildHistoryItem(
                      '2 Weeks Ago',
                      'Health Score: 84 (-1)',
                      'Minor dip in sleep quality',
                    ),
                    _buildHistoryItem(
                      '3 Weeks Ago',
                      'Health Score: 85 (+3)',
                      'Major improvement in VO₂ Max',
                    ),
                    _buildHistoryItem(
                      '1 Month Ago',
                      'Health Score: 82',
                      'Baseline measurement',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String period, String score, String notes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(period),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(score, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(notes),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Show detailed history
        },
      ),
    );
  }

  void _showHealthInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HealthInputDialog(),
    );
  }

  void _showMetabolicInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _MetabolicInputSheet(),
    );
  }
  void _showSleepInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SleepInputSheet(),
    );
  }
  void _showNutritionInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NutritionInputSheet(),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 55) return Colors.orange;
    if (score >= 40) return Colors.red;
    return Colors.grey;
  }

  Widget _buildEmptyHealthCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No Data Available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showHealthInput(context),
              child: const Text('Add Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthMetric {
  final String name;
  final String value;
  final String status;
  final Color statusColor;

  HealthMetric(this.name, this.value, this.status, this.statusColor);
}

class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetScaffold({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetabolicInputSheet extends StatefulWidget {
  const _MetabolicInputSheet();
  @override
  State<_MetabolicInputSheet> createState() => _MetabolicInputSheetState();
}

class _MetabolicInputSheetState extends State<_MetabolicInputSheet> {
  final _glucose = TextEditingController();
  final _hba1c = TextEditingController();
  final _chol = TextEditingController();
  @override
  void dispose() {
    _glucose.dispose();
    _hba1c.dispose();
    _chol.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context, listen: false);
    if (hp.bloodGlucose > 0) _glucose.text = hp.bloodGlucose.toStringAsFixed(0);
    if (hp.hba1c > 0) _hba1c.text = hp.hba1c.toStringAsFixed(1);
    if (hp.cholesterolTotal > 0) _chol.text = hp.cholesterolTotal.toStringAsFixed(0);
    return _SheetScaffold(
      title: 'Metabolic Health',
      child: Column(
        children: [
          _numberField(context, _glucose, 'Blood Glucose (mg/dL)'),
          const SizedBox(height: 12),
          _numberField(context, _hba1c, 'HbA1c (%)'),
          const SizedBox(height: 12),
          _numberField(context, _chol, 'Cholesterol Total (mg/dL)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final g = double.tryParse(_glucose.text);
                final a1c = double.tryParse(_hba1c.text);
                final c = double.tryParse(_chol.text);
                if (g != null) await hp.updateBloodGlucose(g);
                if (a1c != null) await hp.updateHba1c(a1c);
                if (c != null) await hp.updateCholesterolTotal(c);
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepInputSheet extends StatefulWidget {
  const _SleepInputSheet();
  @override
  State<_SleepInputSheet> createState() => _SleepInputSheetState();
}

class _SleepInputSheetState extends State<_SleepInputSheet> {
  final _hours = TextEditingController();
  final _minutes = TextEditingController();
  final _deep = TextEditingController();
  final _rem = TextEditingController();
  final _eff = TextEditingController();
  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    _deep.dispose();
    _rem.dispose();
    _eff.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context, listen: false);
    if (hp.sleepHours > 0) _hours.text = hp.sleepHours.toString();
    if (hp.sleepMinutes > 0) _minutes.text = hp.sleepMinutes.toString();
    if (hp.deepSleepHours > 0) _deep.text = hp.deepSleepHours.toStringAsFixed(1);
    if (hp.remSleepHours > 0) _rem.text = hp.remSleepHours.toStringAsFixed(1);
    if (hp.sleepEfficiency > 0) _eff.text = hp.sleepEfficiency.toStringAsFixed(0);
    return _SheetScaffold(
      title: 'Sleep & Recovery',
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _numberField(context, _hours, 'Hours')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, _minutes, 'Minutes')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numberField(context, _deep, 'Deep Sleep (h)')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, _rem, 'REM Sleep (h)')),
          ]),
          const SizedBox(height: 12),
          _numberField(context, _eff, 'Sleep Efficiency (%)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final h = int.tryParse(_hours.text) ?? 0;
                final m = int.tryParse(_minutes.text) ?? 0;
                await hp.updateSleep(h, m);
                final deep = double.tryParse(_deep.text);
                final rem = double.tryParse(_rem.text);
                final eff = double.tryParse(_eff.text);
                await hp.updateSleepBreakdown(deepH: deep, remH: rem, efficiency: eff);
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionInputSheet extends StatefulWidget {
  const _NutritionInputSheet();
  @override
  State<_NutritionInputSheet> createState() => _NutritionInputSheetState();
}

class _NutritionInputSheetState extends State<_NutritionInputSheet> {
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _water = TextEditingController();
  @override
  void dispose() {
    _cal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _water.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HealthProvider>(context, listen: false);
    if (hp.dailyCalories > 0) _cal.text = hp.dailyCalories.toString();
    if (hp.proteinGrams > 0) _protein.text = hp.proteinGrams.toString();
    if (hp.carbGrams > 0) _carbs.text = hp.carbGrams.toString();
    if (hp.fatGrams > 0) _fat.text = hp.fatGrams.toString();
    if (hp.waterIntake > 0) _water.text = hp.waterIntake.toStringAsFixed(1);
    return _SheetScaffold(
      title: 'Nutrition & Hydration',
      child: Column(
        children: [
          _numberField(context, _cal, 'Daily Calories (cal)'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numberField(context, _protein, 'Protein (g)')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, _carbs, 'Carbs (g)')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numberField(context, _fat, 'Fat (g)')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, _water, 'Water (L)')),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final cal = int.tryParse(_cal.text);
                final p = int.tryParse(_protein.text);
                final c = int.tryParse(_carbs.text);
                final f = int.tryParse(_fat.text);
                final w = double.tryParse(_water.text);
                if (cal != null) await hp.updateDailyCalories(cal);
                await hp.updateMacros(protein: p, carbs: c, fat: f);
                if (w != null) await hp.updateWaterIntake(w);
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _numberField(BuildContext context, TextEditingController c, String label) {
  return TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
