// Stub file for non-web platforms
class WebUtils {
  static String getCurrentUrl() => '';
  static String getUserAgent() => '';
  static int getMaxTouchPoints() => 0;
  static String getBaseUrl() => '';
  static Future<bool> shareContent(
    String title,
    String text,
    String url,
  ) async => false;
  static Future<bool> copyToClipboard(String text) async => false;
  static void navigateBack() {}
  static Future<bool> openUsdzInAR(String usdzUrl) async => false;
  static bool isIPad() => false;
  static Future<bool> openGlbOnIPad(String glbUrl) async => false;
  static void prepareModelViewerAR(String glbUrl,
      {void Function(String status)? onStatus}) {}
  static bool activateModelViewerAR() => false;
  static bool get webXRPending => false;
  static bool get cameraDenied => false;
  static void disposeModelViewerAR() {}
  static void launchAndroidSceneViewer({
    required String glbUrl,
    required String title,
    required String fallbackUrl,
  }) {}
}
