abstract final class AppDestinationPolicy {
  static bool requiresAuthentication(Uri uri) =>
      uri.pathSegments.length == 2 && uri.pathSegments.first == 'protected';

  static String? safeInternalDestination(String? source) {
    if (source == null || source.isEmpty || source.startsWith('//')) {
      return null;
    }
    final uri = Uri.tryParse(source);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.fragment.isNotEmpty ||
        !requiresAuthentication(uri) ||
        uri.pathSegments[1].isEmpty ||
        uri.queryParameters.keys.any((key) => key != 'tab')) {
      return null;
    }
    return uri.toString();
  }
}
