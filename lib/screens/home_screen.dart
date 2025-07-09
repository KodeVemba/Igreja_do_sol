// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//Flutter
import 'package:flutter/material.dart';
import 'package:church/services/assingment_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //get user
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 325,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0),
                      bottomRight: Radius.circular(100.0),
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Positioned(
                  top: 70,
                  left: 15,
                  right: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/3891/3891873.png',
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, $userName',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_none),
                            onPressed: () {
                              //print('Notification');
                            },
                            color: Colors.white,
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.menu, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 15,
                  right: 15,
                  child: Container(
                    width: double.infinity,
                    height: 175,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Assignment card with logic
                        // When somoene it's assign this message should come up
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('assignments')
                              .where(
                                'date',
                                isGreaterThanOrEqualTo: Timestamp.fromDate(
                                  DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  ),
                                ),
                              )
                              .where(
                                'date',
                                isLessThan: Timestamp.fromDate(
                                  DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  ),
                                ),
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Text('No assignment for this day');
                            }
                            final currentUserId = user?.uid ?? '';
                            final docs = snapshot.data!.docs;

                            // Loop through celebration on this date
                            for (final doc in docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              final celebrationTime = data['celebrationTime'];
                              final assignments =
                                  data['assignments'] as Map<String, dynamic>;

                              // Look through eaach role in celebration
                              for (final entry in assignments.entries) {
                                final role = entry.key;
                                final assignment = entry.value;

                                if (assignment['user'] == currentUserId) {
                                  final status =
                                      assignment['status'] ?? 'peding';
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You are assigned to :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '📆 ${weekdayString(selectedDate.weekday)}, ${selectedDate.toLocal().toString().split('')[0]}',
                                        ),
                                        Text('⏰ $celebrationTime'),
                                        Text('📖 Role: ${formatRole(role)}'),
                                        SizedBox(height: 12),

                                        if (status == 'pending')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    updateAssignmentStatus(
                                                      doc.id,
                                                      role,
                                                      'accepted',
                                                    ),
                                                icon: Icon(Icons.check),
                                                label: Text('Accept'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    updateAssignmentStatus(
                                                      doc.id,
                                                      role,
                                                      'rejected',
                                                    ),
                                                icon: Icon(Icons.check),
                                                label: Text('Rejected'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),

                                        //else Text(status == 'accepted' ? '✅ You accepted this assignment.' : '❌ You rejected this assignment.',style: TextStyle(fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  );
                                }
                              }
                            }
                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),

            // 📅 Date Picker
            Container(
              height: 70,
              padding: EdgeInsets.only(left: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nextSevenDays.length,
                itemBuilder: (context, index) {
                  final date = nextSevenDays[index];
                  final isSelected = selectedDate.day == date.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedDate = date);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            weekdayString(date.weekday),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // 📋 Today's Events
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: getEventsForSelectedDate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("No celebrations for this day."),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: events.map((event) {
                      final time = event['celebrationTime'];
                      final raw = event['assignments'];
                      if (raw == null || raw is! Map<String, dynamic>) {
                        return SizedBox();
                      }
                      final assignments = raw;
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🕒 Celebration at $time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...assignments.entries.map((entry) {
                              final role = entry.key;
                              final readerId = entry.value['user'];
                              final status = entry.value['status'];

                              return Text(
                                '📖 $role: $readerId (${status ?? "pending"})',
                                style: TextStyle(fontSize: 14),
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      //  Modern Bottom Navigation
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => selectedIndex = index);
          // You can navigate or set different screens based on index
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            selectedIcon: Icon(Icons.article_outlined),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
