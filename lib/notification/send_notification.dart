import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'notification_api.dart';

/// Broadcasts a push notification to every subscribed device (Android app
/// via FCM through OneSignal; web customers with notifications enabled see
/// it via their browser). See CLIENT_NOTIFICATIONS.md for what the
/// customer-facing app still needs to build for the in-app bell/popup half
/// of this - this screen only triggers the OneSignal push.
class NotifyAll extends StatefulWidget {
  const NotifyAll({Key? key}) : super(key: key);

  @override
  State<NotifyAll> createState() => _NotifyAllState();
}

class _NotifyAllState extends State<NotifyAll> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) {
      setState(() => _error = 'Enter a title and a message.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final result = await NotificationApi.send(title: title, message: message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Sent to ${result['recipients'] ?? 'all'} device(s).')),
      );
      _titleController.clear();
      _messageController.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Send to Everyone'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notify all customers',
                        style: AppText.heading(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Delivered as a push notification to every device with notifications enabled.',
                      style: AppText.caption(context),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PillButton(
                        label: _sending ? 'Sending…' : 'Send to Everyone',
                        icon: Icons.campaign_outlined,
                        onPressed: _sending ? null : _send,
                      ),
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
}
