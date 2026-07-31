import 'package:cadenceiq/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OAuthResultScreen extends StatefulWidget {
  const OAuthResultScreen({super.key, required this.success});

  final bool success;

  @override
  State<OAuthResultScreen> createState() => _OAuthResultScreenState();
}

class _OAuthResultScreenState extends State<OAuthResultScreen> {
  bool _loading = true;
  late DashboardProvider dashboard;

  @override
  void initState() {
    dashboard = context.read<DashboardProvider>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadProfile();
    });
  }

  Future<void> _reloadProfile() async {
    if (widget.success) {
      await dashboard.refresh();
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final success = widget.success;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.cancel,
                size: 96,
                color: success ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 24),

              Text(
                success ? "Strava Connected" : "Strava Connection Failed",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 12),

              Text(
                success
                    ? "Your activities will now sync automatically."
                    : "Something went wrong while connecting your account.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(success ? "Continue" : "Go Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
