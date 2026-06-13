import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/journal_entry.dart';
import '../../domain/usecases/stress_trigger_analyzer.dart';
import '../providers/providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _journalController = TextEditingController();
  JournalEntry? _latestAnalysis;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _analyzeJournal() async {
    final text = _journalController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI computing latency (makes local simulation feel immersive)
    await Future.delayed(const Duration(milliseconds: 700));

    final entry = await ref.read(journalHistoryProvider.notifier).addJournal(text);

    setState(() {
      _latestAnalysis = entry;
      _journalController.clear();
      _isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry analyzed successfully by local AI!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final journals = ref.watch(journalHistoryProvider);

    // Compute recurring triggers across history
    final triggerInsights = StressTriggerAnalyzer.analyzeTriggers(journals);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final mainContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safe disclaimers
              Semantics(
                header: true,
                child: Text(
                  'AI Journal Analysis',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vent your stress, exam anxiety, or thoughts about preparation. The local AI analyses emotional tone, sleep fatigue, and syllabus pressure to offer safety alerts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Journal Text Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: 'Journal reflection text field',
                        hint: 'Type how your studies are going, your fears, or mock scores here...',
                        child: TextField(
                          controller: _journalController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'e.g., "I studied for 8 hours but still feel unprepared for NEET. I keep comparing myself to others and feel anxious."',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                            fillColor: colorScheme.surface,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeJournal,
                        icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.analytics_outlined),
                        label: Text(_isAnalyzing ? 'Analyzing Text...' : 'Analyze thoughts'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Triggers Warning Panel (Key Feature)
              if (triggerInsights.isNotEmpty) ...[
                Text(
                  'Detected Recurring Stress Triggers',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...triggerInsights.map((insight) => _buildTriggerInsightCard(insight)),
                const SizedBox(height: 20),
              ],

              // Latest Analysis Result
              if (_latestAnalysis != null) ...[
                Text(
                  'Latest Analysis Results',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildAnalysisResultCard(_latestAnalysis!),
                const SizedBox(height: 24),
              ],

              // Timeline/History
              Text(
                'Previous Logs History',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (journals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'No journals logged yet. Write above to begin.',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    final item = journals[journals.length - 1 - index]; // Show newest first
                    return _buildHistoryLogItem(item);
                  },
                ),
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: mainContent,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: StickySummarySidePanel(
                          latestEntry: _latestAnalysis,
                          insights: triggerInsights,
                        ),
                      ),
                    ],
                  )
                : mainContent,
          );
        },
      ),
    );
  }

  Widget _buildTriggerInsightCard(StressTriggerInsight insight) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.isHighPriority 
            ? Colors.red.withOpacity(0.08) 
            : Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.isHighPriority ? Colors.redAccent : Colors.orangeAccent,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            insight.isHighPriority ? Icons.warning_amber : Icons.lightbulb_outline,
            color: insight.isHighPriority ? Colors.red : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trigger Focus: ${insight.trigger}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: insight.isHighPriority ? Colors.red[700] : Colors.orange[850],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard(JournalEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surface.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Journal Summary',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('hh:mm a, d MMM').format(entry.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${entry.content}"',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnalysisMetric(
                  label: 'Stress Score',
                  val: '${entry.stressScore}/100',
                  color: entry.stressScore > 70 ? Colors.red : (entry.stressScore > 45 ? Colors.orange : Colors.green),
                ),
                _buildAnalysisMetric(
                  label: 'Confidence',
                  val: '${entry.confidenceScore}/100',
                  color: entry.confidenceScore > 70 ? Colors.green : (entry.confidenceScore > 40 ? Colors.orange : Colors.red),
                ),
                _buildAnalysisMetric(
                  label: 'Burnout Risk',
                  val: entry.burnoutRisk,
                  color: entry.burnoutRisk == 'High' ? Colors.red : (entry.burnoutRisk == 'Moderate' ? Colors.orange : Colors.green),
                ),
              ],
            ),
            const Divider(height: 32),
            // Detected concerns tags
            const Text('Detected Concerns:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            if (entry.detectedConcerns.isEmpty)
              const Text('None detected (Balanced tone).', style: TextStyle(fontSize: 12, color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.detectedConcerns.map((c) {
                  return Chip(
                    label: Text(c, style: const TextStyle(fontSize: 11)),
                    backgroundColor: colorScheme.secondary.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: const EdgeInsets.all(4),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            // Emotional explanation
            Text(
              entry.emotionalSummary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric({required String label, required String val, required Color color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildHistoryLogItem(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          entry.content.length > 50 ? '${entry.content.substring(0, 50)}...' : entry.content,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('EEEE, MMM d, yyyy').format(entry.timestamp),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        leading: Icon(
          Icons.book_outlined,
          color: entry.stressScore > 60 ? Colors.orange : Colors.green,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAnalysisResultCard(entry),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Side panel widget that acts as sticky sidebar summary on wide screens
class StickySummarySidePanel extends StatelessWidget {
  final JournalEntry? latestEntry;
  final List<StressTriggerInsight> insights;

  const StickySummarySidePanel({
    super.key,
    required this.latestEntry,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick Health Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (latestEntry == null) ...[
              const Icon(Icons.psychology, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Submit a journal log on the left. Our clinical NLP analyzer will extract emotional indicators instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ] else ...[
              _buildMetricBar('Stress Level', latestEntry!.stressScore / 100, Colors.red),
              const SizedBox(height: 12),
              _buildMetricBar('Confidence Level', latestEntry!.confidenceScore / 100, Colors.green),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Overall Safety Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    latestEntry!.stressScore > 70 ? Icons.error_outline : Icons.check_circle_outline,
                    color: latestEntry!.stressScore > 70 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    latestEntry!.stressScore > 70 ? 'High academic load' : 'Stable academic rhythm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Clinical Insight Rules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('1. Stress > 70 triggers immediate relaxation guidelines.\n2. Trigger patterns check recurring keyword frequencies across the last 7 entries.', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(String label, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('${(ratio * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          color: color,
          backgroundColor: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
