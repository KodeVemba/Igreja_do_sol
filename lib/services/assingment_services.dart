import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

String weekdayString(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}

String formatRole(String rolekey) {
  switch (rolekey) {
    case 'firstReading':
      return 'First Reader';
    case 'secondReading':
      return 'Second Reading';
    case 'psalm':
      return 'Psalm';
    case 'prayer_of_the_faithful':
      return 'Prayer of the Faithful';
    case 'monitor':
      return 'Monitor';
    case 'substitute':
      return 'Substitute';
    default:
      return rolekey;
  }
}

// Update assignment logic by clicking into the accepting or rejecting
Future<void> updateAssignmentStatus(
  String docId,
  String role,
  String newStatus,
) async {
  final assignmentPath = 'assignments.$role.status';
  await FirebaseFirestore.instance.collection('assignments').doc(docId).update({
    assignmentPath: newStatus,
  });
}

// Assign reader to weekly assignment from Saturday 23 to  Saturday
Future<void> generateWeeklyAssignment() async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.add(
    Duration(days: DateTime.saturday - today.weekday),
  );
  final random = Random();
  final readerSnapshot = await FirebaseFirestore.instance
      .collection('readers')
      .get();

  final allReader = readerSnapshot.docs.map((doc) => doc.data()).toList();

  List<Map<String, dynamic>> baseMonitor = allReader
      .where((r) => r['isMonitor'] == true)
      .toList();
  List<Map<String, dynamic>> baseNormalReaders = allReader
      .where((r) => r['isMonitor'] != true)
      .toList();

  for (int i = 0; i < 7; i++) {
    final currentDate = startOfWeek.add(Duration(days: i));
    final weekday = currentDate.weekday;
    final celebrations = <DateTime>[];

    if (weekday >= 1 && weekday <= 5) {
      // Weekdays: one celebrations at 18:00
      celebrations.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day, 18),
      );
    } else if (weekday == 6) {
      // Saturday  7:00 and 18:00
      celebrations.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day, 7),
      );
      celebrations.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day, 18),
      );
    } else if (weekday == 7) {
      //Sunday 7:00 and 9:300
      celebrations.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day, 7),
      );
      celebrations.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day, 9, 20),
      );
    }

    for (final celebration in celebrations) {
      final isSpecial =
          (weekday == 6 && celebration.hour == 18 || weekday == 7);
      final roles = isSpecial
          ? [
              'firstReading',
              'secondReading',
              'prayer_of_the_faithful',
              'substitute',
              'monitor',
            ]
          : ['firstReading', 'psalm', 'substitute'];
      //clone base pool
      var availableMonitors = List<Map<String, dynamic>>.from(baseMonitor);
      var availableReaders = List<Map<String, dynamic>>.from(baseNormalReaders);

      final assignments = <String, Map<String, dynamic>>{};
      for (final role in roles) {
        List<Map<String, dynamic>> pool = (role == 'monitor')
            ? availableMonitors
            : availableReaders;

        if (pool.isEmpty) {
          // Refill if empty
          pool = (role == 'monitor')
              ? List<Map<String, dynamic>>.from(baseMonitor)
              : List<Map<String, dynamic>>.from(baseNormalReaders);
        }
        final selected = pool[random.nextInt(pool.length)];
        assignments[role] = {'user': selected['userId'], 'status': 'pending'};
        if (role == 'monitor') {
          availableMonitors.removeWhere(
            (r) => r['userId'] == selected['userId'],
          );
          availableReaders.removeWhere(
            (r) => r['userId'] == selected['userId'],
          );
        } else {
          availableReaders.removeWhere(
            (r) => r['userId'] == selected['userId'],
          );
        }
      }
      await FirebaseFirestore.instance.collection('assignments').add({
        'date': Timestamp.fromDate(celebration),
        'celebration':
            '${celebration.hour.toString().padLeft(2, '0')}: ${celebration.minute.toString().padLeft(2, '0')}',
        'assignments': assignments,
      });
    }
  }
}

// Logic for the date picker and today events
DateTime selectedDate = DateTime.now();
Stream<List<Map<String, dynamic>>> getEventsForSelectedDate() {
  final start = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final end = start.add(Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('assignments')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('date', isLessThan: Timestamp.fromDate(end))
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'celebrationTime': data['celebrationTime'],
            'assignments': data['assignments'],
          };
        }).toList();
      });
}

List<DateTime> get nextSevenDays {
  final now = DateTime.now();
  return List.generate(7, (index) {
    return DateTime(now.year, now.month, now.day).add(Duration(days: index));
  });
}
