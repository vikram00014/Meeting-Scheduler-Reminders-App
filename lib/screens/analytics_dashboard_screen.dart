import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../services/analytics_service.dart';
import '../models/meeting.dart';

/// Analytics Dashboard screen showing meeting statistics and insights
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'All Time';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(
                  value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, meetingProvider, child) {
          final allMeetings = meetingProvider.meetings;

          // Filter meetings based on selected period
          final meetings = _getFilteredMeetings(allMeetings);

          if (allMeetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No meetings yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start scheduling meetings to see analytics',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final totalMeetings = meetings.length;
          final totalHours = AnalyticsService.getTotalTimeSpent(meetings);
          final avgDuration = AnalyticsService.getAverageDuration(meetings);
          final categoryBreakdown =
              AnalyticsService.getCategoryBreakdown(meetings);
          final topParticipants =
              AnalyticsService.getTopParticipants(meetings, limit: 5);
          final upcomingCount =
              AnalyticsService.getUpcomingMeetingsCount(allMeetings);
          final pastCount = AnalyticsService.getPastMeetingsCount(allMeetings);
          final busiestDay = AnalyticsService.getBusiestDayOfWeek(meetings);

          return RefreshIndicator(
            onRefresh: () async {
              await meetingProvider.loadMeetings();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Meetings',
                        totalMeetings.toString(),
                        Icons.event,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Hours',
                        totalHours.toStringAsFixed(1),
                        Icons.access_time,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Upcoming',
                        upcomingCount.toString(),
                        Icons.upcoming,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        pastCount.toString(),
                        Icons.check_circle,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Average Duration
                _buildSectionCard(
                  'Average Duration',
                  '${avgDuration.toStringAsFixed(0)} minutes',
                  Icons.timer,
                  Colors.teal,
                ),
                const SizedBox(height: 16),

                // Busiest Day
                _buildSectionCard(
                  'Busiest Day',
                  AnalyticsService.getDayName(busiestDay),
                  Icons.calendar_today,
                  Colors.indigo,
                ),
                const SizedBox(height: 16),

                // Category Breakdown
                _buildCategoryBreakdown(categoryBreakdown),
                const SizedBox(height: 16),

                // Top Participants
                if (topParticipants.isNotEmpty) ...[
                  _buildTopParticipants(topParticipants),
                  const SizedBox(height: 16),
                ],

                // Peak Hours Chart
                _buildPeakHoursChart(meetings),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Meeting> _getFilteredMeetings(List<Meeting> allMeetings) {
    if (_selectedPeriod == 'This Week') {
      return AnalyticsService.getMeetingsThisWeek(allMeetings);
    } else if (_selectedPeriod == 'This Month') {
      return AnalyticsService.getMeetingsThisMonth(allMeetings);
    }
    return allMeetings;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, int> breakdown) {
    final total = breakdown.values.fold<int>(0, (sum, count) => sum + count);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryItem(
              'Work',
              breakdown['work'] ?? 0,
              total,
              Colors.blue,
              Icons.work,
            ),
            const SizedBox(height: 8),
            _buildCategoryItem(
              'Personal',
              breakdown['personal'] ?? 0,
              total,
              Colors.green,
              Icons.person,
            ),
            const SizedBox(height: 8),
            _buildCategoryItem(
              'Other',
              breakdown['other'] ?? 0,
              total,
              Colors.orange,
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total > 0 ? count / total : 0,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildTopParticipants(List<MapEntry<String, int>> participants) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Colors.pink),
                SizedBox(width: 8),
                Text(
                  'Top Participants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...participants.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.pink[100],
                        child: Text(
                          entry.key[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value} meetings',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakHoursChart(List<Meeting> meetings) {
    final peakHours = AnalyticsService.getPeakMeetingHours(meetings);
    if (peakHours.isEmpty) return const SizedBox.shrink();

    final maxCount = peakHours.values.isEmpty
        ? 1
        : peakHours.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.cyan),
                SizedBox(width: 8),
                Text(
                  'Peak Meeting Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (hour) {
                  final count = peakHours[hour] ?? 0;
                  final height = count > 0 ? (count / maxCount * 100) : 5;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            height: height.toDouble(),
                            decoration: BoxDecoration(
                              color: count > 0 ? Colors.cyan : Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hour % 3 == 0)
                            Text(
                              '${hour}h',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
