import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageReadersTab extends StatefulWidget {
  const ManageReadersTab({super.key});

  @override
  State<ManageReadersTab> createState() => _ManageReadersTabState();
}

class _ManageReadersTabState extends State<ManageReadersTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('readers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final readers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: readers.length,
            itemBuilder: (context, index) {
              final reader = readers[index].data() as Map<String, dynamic>;
              final docId = readers[index].id;
              final isMonitor = reader['isMonitor'] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(reader['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${reader['email'] ?? 'N/A'}'),
                      Text('Monitor: ${isMonitor ? "Yes" : "No"}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditDialog(docId, reader);
                      } else if (value == 'delete') {
                        await FirebaseFirestore.instance
                            .collection('readers')
                            .doc(docId)
                            .delete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null, {}),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(String? docId, Map<String, dynamic> readerData) {
    final nameController = TextEditingController(
      text: readerData['name'] ?? '',
    );
    final emailController = TextEditingController(
      text: readerData['email'] ?? '',
    );
    bool isMonitor = readerData['isMonitor'] ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add Reader' : 'Edit Reader'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            CheckboxListTile(
              title: Text('Monitor'),
              value: isMonitor,
              onChanged: (value) => setState(() => isMonitor = value ?? false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isEmpty || email.isEmpty) return;

              final data = {
                'name': name,
                'email': email,
                'isMonitor': isMonitor,
              };

              final collection = FirebaseFirestore.instance.collection(
                'readers',
              );

              if (docId == null) {
                await collection.add(data);
              } else {
                await collection.doc(docId).update(data);
              }

              Navigator.pop(context);
            },
            child: Text(docId == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
