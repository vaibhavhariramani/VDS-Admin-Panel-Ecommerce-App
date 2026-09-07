import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

/// Replaces flutter_dashboard's bare "404 Page Not Found." text, shown
/// whenever a route inside the dashboard shell doesn't match anything
/// (a stale/mistyped link, or an order-details URL for an order that's
/// gone).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 96,
                color: Theme.of(context).primaryColor.withOpacity(0.35),
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "We couldn't find that page.",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                "It may have been moved, or the link might be out of date.",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                // Get.rootDelegate rather than
                // FlutterDashboardController.to.delegate (the dashboard
                // shell's own nested outlet) - navigation through that
                // inner delegate doesn't reliably land from this specific
                // broken/404 state in this app's flutter_dashboard
                // version, confirmed live. Get.rootDelegate is the same
                // top-level delegate that already reliably lands on
                // /dashboard right after login.
                onPressed: () =>
                    Get.rootDelegate.toNamed(DashboardRoutes.DASHBOARD),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
