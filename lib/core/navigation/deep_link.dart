import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  DeepLinkService(this.router);

  final GoRouter router;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  Future<void> initialize() async {
    // Handle app opened from a terminated state
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // Handle app already running
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    router.go('${uri.path}?${uri.query}');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
