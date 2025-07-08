import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitorStatsTab extends StatefulWidget {
  const MonitorStatsTab({super.key});

  @override
  State<MonitorStatsTab> createState() => _MonitorStatsPageState();
}

class _MonitorStatsPageState extends State<MonitorStatsTab> {
  late Future<List<Map<String, dynamic>>> readerStats;

  @override
  void initState() {
    super.initState();
    readerStats = fetchStats();
  }

  Future<List<Map<String, dynamic>>> fetchStats() async {
    final readerSnapshot = await FirebaseFirestore.instance
        .collection('readers')
        .get();
    final assignmentSnapshot = await FirebaseFirestore.instance
        .collection('assignments')
        .get();

    final readers = readerSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unnamed',
        'email': data['email'] ?? '',
      };
    }).toList();

    // Initialize stats for each reader
    final stats = <String, Map<String, dynamic>>{};
    for (var reader in readers) {
      stats[reader['id']] = {
        'name': reader['name'],
        'email': reader['email'],
        'accepted': 0,
        'rejected': 0,
        'pending': 0,
        'total': 0,
      };
    }

    // Tally assignments
    for (var doc in assignmentSnapshot.docs) {
      final data = doc.data();
      final assignments = data['assignments'] as Map<String, dynamic>;

      assignments.forEach((role, details) {
        final userId = details['user'];
        final status = (details['status'] ?? 'pending') as String;

        if (stats.containsKey(userId)) {
          stats[userId]?['total'] += 1;
          stats[userId]?[status] += 1;
        }
      });
    }

    return stats.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitor Stats')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: readerStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No data available'));

          final readers = snapshot.data!;

          return ListView.builder(
            itemCount: readers.length,
            itemBuilder: (context, index) {
              final reader = readers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(reader['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📧 ${reader['email']}'),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _statBadge('Total', reader['total'], Colors.grey),
                          _statBadge(
                            '✅ Accepted',
                            reader['accepted'],
                            Colors.green,
                          ),
                          _statBadge(
                            '❌ Rejected',
                            reader['rejected'],
                            Colors.red,
                          ),
                          _statBadge(
                            '⏳ Pending',
                            reader['pending'],
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statBadge(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
