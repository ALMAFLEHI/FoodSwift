import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Order Issue';
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _types = [
    'Order Issue',
    'Missing Items',
    'App Performance',
    'Other',
  ];

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    final feedbackData = {
      'type': _selectedType,
      'message': _messageController.text.trim(),
      'userId': user?.uid ?? 'anonymous',
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('feedbacks').add(feedbackData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted. Thank you!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            const Text(
              '📝 Submit Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _types
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                    decoration: const InputDecoration(
                      labelText: 'Feedback Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 3,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter feedback'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Your Feedback',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(48),
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
}
