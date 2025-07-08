import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAssignmentsTab extends StatefulWidget {
  const ManageAssignmentsTab({super.key});

  @override
  State<ManageAssignmentsTab> createState() => ManageAssignmentsTabState();
}

class ManageAssignmentsTabState extends State<ManageAssignmentsTab> {
  Stream<QuerySnapshot> getAssignmentsStream() {
    return FirebaseFirestore.instance
        .collection('assignments')
        .orderBy('date')
        .snapshots();
  }

  Future<void> updateStatus(String docId, String role, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('assignments')
        .doc(docId)
        .update({'assignments.$role.status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: getAssignmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments available."));
          }

          final assignmentsDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignmentsDocs.length,
            itemBuilder: (context, index) {
              final doc = assignmentsDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final celebrationTime = data['celebrationTime'] ?? 'Unknown';
              final assignments = data['assignments'] as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 ${date.toLocal().toString().split(' ')[0]} at $celebrationTime",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...assignments.entries.map((entry) {
                        final role = entry.key;
                        final assignment = entry.value as Map<String, dynamic>;
                        final userId = assignment['user'] ?? 'Unknown';
                        final status = assignment['status'] ?? 'pending';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("📖 $role - $userId (${status})"),
                              ),
                              if (status == 'pending')
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => updateStatus(
                                        doc.id,
                                        role,
                                        'accepted',
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => updateStatus(
                                        doc.id,
                                        role,
                                        'rejected',
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(status == 'accepted' ? '✅' : '❌'),
                            ],
                          ),
                        );
                      }).toList(),
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
}
