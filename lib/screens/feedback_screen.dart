import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

/// Tester feedback: open a Google Form or email the author with questions.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _message = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _open(Uri uri, {LaunchMode mode = LaunchMode.externalApplication}) async {
    if (!await launchUrl(uri, mode: mode)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: ${uri.toString()}')),
      );
    }
  }

  Future<void> _openFeedbackForm() async {
    if (!AppConfig.hasFeedbackForm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a Google Form URL in app_config.dart or FEEDBACK_FORM_URL dart-define.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _open(Uri.parse(AppConfig.feedbackFormUrl.trim()));
  }

  Future<void> _emailQuestion() async {
    final body = StringBuffer();
    if (_name.text.trim().isNotEmpty) {
      body.writeln('Name: ${_name.text.trim()}');
    }
    body.writeln();
    body.writeln(_message.text.trim().isEmpty
        ? '(Add your question above before sending.)'
        : _message.text.trim());
    if (kIsWeb) {
      body.writeln();
      body.writeln('Sent from Nutri Work web tester.');
    }

    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {
        'subject': 'Nutri Work — tester question',
        'body': body.toString(),
      },
    );
    await _open(uri);
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: AppConfig.shareableWebUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App link copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & questions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help us improve Nutri Work',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are testing a thesis prototype. Data stays in your browser on this device. '
                    'Use the form for structured feedback, or email a specific question.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (kIsWeb) ...[
            Card(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              child: ListTile(
                leading: Icon(Icons.public, color: cs.primary),
                title: const Text('Share this test link'),
                subtitle: Text(
                  AppConfig.shareableWebUrl,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: _copyLink,
                  tooltip: 'Copy link',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: cs.tertiary),
                title: const Text('USDA search on web'),
                subtitle: Text(
                  'Live USDA lookup may be blocked by browser security (CORS). '
                  'The built-in food catalog and manual meals still work.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: _openFeedbackForm,
            icon: const Icon(Icons.poll_outlined),
            label: Text(
              AppConfig.hasFeedbackForm
                  ? 'Open feedback form'
                  : 'Set up feedback form (app_config.dart)',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick question by email',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Your name (optional)',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            decoration: const InputDecoration(
              labelText: 'Your question or comment',
              hintText: 'e.g. The adaptive workout suggestion was confusing…',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _emailQuestion,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Email question'),
          ),
        ],
      ),
    );
  }
}
