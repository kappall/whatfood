import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _privacyUrl = 'https://www.what-food.com/privacy-policy-it';

  Future<void> _launchUrl() async {
    final uri = Uri.parse(_privacyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_privacyUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
            onPressed: () => Routemaster.of(context).push('/settings'),
            icon: Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: TextButton(
          onPressed: _launchUrl,
          child: const Text(
            'View Privacy Policy',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
