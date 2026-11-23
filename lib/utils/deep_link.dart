import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const siteUrl = 'https://arewecookin.web.app';

/// Recipe id from a route such as '/recipe/th_padthai' (also '#/recipe/...'), else null.
String? recipeIdFromRoute(String route) {
  final m = RegExp(r'^#?/?recipe/([^/?#]+)').firstMatch(route.startsWith('/') ? route.substring(1) : route);
  if (m == null) return null;
  final id = Uri.decodeComponent(m.group(1)!);
  return id.isEmpty ? null : id;
}

/// The address that opens a recipe on the web site.
String recipeShareUrl(String id) => '$siteUrl/#/recipe/${Uri.encodeComponent(id)}';

/// Keeps the browser address bar in step with the open recipe (web only).
void syncBrowserUrl(String? recipeId) {
  if (!kIsWeb) return;
  try {
    SystemNavigator.routeInformationUpdated(
      uri: Uri.parse(recipeId == null ? '/' : '/recipe/${Uri.encodeComponent(recipeId)}'),
      replace: true,
    );
  } catch (_) {}
}
