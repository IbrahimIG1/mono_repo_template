abstract final class AppDestinationPolicy {
  static const maxDestinationLength = 2048;

  static bool requiresAuthentication(Uri uri) =>
      uri.pathSegments.length == 2 && uri.pathSegments.first == 'protected';

  static String? safeInternalDestination(String? source) {
    if (source == null ||
        source.isEmpty ||
        source.length > maxDestinationLength ||
        RegExp(r'%(?![0-9A-Fa-f]{2})').hasMatch(source) ||
        source.startsWith('//')) {
      return null;
    }
    try {
      final uri = Uri.tryParse(source);
      if (uri == null ||
          uri.hasScheme ||
          uri.hasAuthority ||
          uri.fragment.isNotEmpty ||
          !requiresAuthentication(uri) ||
          uri.pathSegments[1].isEmpty ||
          uri.queryParametersAll.keys.any((key) => key != 'tab') ||
          uri.queryParametersAll.values.any((values) => values.length != 1)) {
        return null;
      }
      return uri.toString();
    } on FormatException {
      return null;
    }
  }

  static String? singleQueryValue(Uri uri, String name) {
    try {
      final values = uri.queryParametersAll[name];
      return values?.length == 1 ? values!.single : null;
    } on FormatException {
      return null;
    }
  }
}
