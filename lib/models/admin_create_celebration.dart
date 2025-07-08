import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCelebrationTab extends StatefulWidget {
  const CreateCelebrationTab({super.key});

  @override
  State<CreateCelebrationTab> createState() => _CreateCelebrationTabState();
}

class _CreateCelebrationTabState extends State<CreateCelebrationTab> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _noteController = TextEditingController();

  // Default role list
  final List<String> _allRoles = [
    'firstReading',
    'secondReading',
    'psalm',
    'prayer_of_the_faithful',
    'monitor',
    'substitute',
  ];
  final Set<String> _selectedRoles = {};

  // UI pickers
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitCelebration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date, time, and at least one role."),
        ),
      );
      return;
    }

    final celebrationDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection('celebrations').add({
      'date': Timestamp.fromDate(celebrationDateTime),
      'time':
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      'roles': _selectedRoles.toList(),
      'note': _noteController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Celebration created successfully.")),
    );

    // Reset form
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedRoles.clear();
      _noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "📅 Create a New Celebration",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              title: Text(
                _selectedDate == null
                    ? "Select Date"
                    : "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            // Time Picker
            ListTile(
              title: Text(
                _selectedTime == null
                    ? "Select Time"
                    : "Time: ${_selectedTime!.format(context)}",
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),

            // Roles Checklist
            const SizedBox(height: 16),
            Text(
              "🧾 Roles Needed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._allRoles.map((role) {
              return CheckboxListTile(
                value: _selectedRoles.contains(role),
                title: Text(role),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedRoles.add(role);
                    } else {
                      _selectedRoles.remove(role);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submitCelebration,
              icon: const Icon(Icons.add),
              label: const Text(
                "Create Celebration",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
