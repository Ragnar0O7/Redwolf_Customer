// Web implementation
import 'dart:html' as html;
import 'dart:js' as js;

class WebUtils {
  static String getCurrentUrl() {
    return html.window.location.href;
  }

  /// Get the base URL (origin) of the website
  static String getBaseUrl() {
    try {
      // Get origin (protocol + host + port if any)
      return html.window.location.origin;
    } catch (e) {
      print('Error getting base URL: $e');
      // Fallback: try to construct from current URL
      try {
        final href = html.window.location.href;
        final uri = Uri.parse(href);
        return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      } catch (e2) {
        print('Error parsing URL: $e2');
        return ''; // Return empty string as last resort
      }
    }
  }

  static String getUserAgent() {
    return html.window.navigator.userAgent;
  }

  static int getMaxTouchPoints() {
    try {
      return html.window.navigator.maxTouchPoints ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Enhanced iPad detection
  static bool isIPad() {
    try {
      final userAgent = getUserAgent().toLowerCase();
      final maxTouchPoints = getMaxTouchPoints();

      // Direct iPad detection
      if (userAgent.contains('ipad')) {
        return true;
      }

      // iPadOS 13+ detection (reports as Mac but has touch)
      if ((userAgent.contains('macintel') || userAgent.contains('macintosh')) &&
          maxTouchPoints > 1) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Try to open GLB file on iPad using model-viewer approach
  static Future<bool> openGlbOnIPad(String glbUrl) async {
    try {
      if (!isIPad()) {
        return false;
      }

      print('Attempting to open GLB file on iPad: $glbUrl');

      // Method 1: Try to create a model-viewer element
      try {
        final modelViewer = html.Element.tag('model-viewer')
          ..setAttribute('src', glbUrl)
          ..setAttribute('ar', '')
          ..setAttribute('ar-modes', 'webxr scene-viewer quick-look')
          ..setAttribute('camera-controls', '')
          ..setAttribute('auto-rotate', '')
          ..style.width = '100%'
          ..style.height = '400px'
          ..style.position = 'fixed'
          ..style.top = '50%'
          ..style.left = '50%'
          ..style.transform = 'translate(-50%, -50%)'
          ..style.zIndex = '9999'
          ..style.backgroundColor = 'white';

        // Add to body
        html.document.body?.append(modelViewer);

        // Try to activate AR
        final activateAR = html.document.createElement('script');
        activateAR.text = '''
          setTimeout(() => {
            const viewer = document.querySelector('model-viewer');
            if (viewer && viewer.canActivateAR) {
              viewer.activateAR();
            }
          }, 1000);
        ''';
        html.document.head?.append(activateAR);

        // Remove after delay
        Future.delayed(const Duration(seconds: 10), () {
          try {
            modelViewer.remove();
            activateAR.remove();
          } catch (e) {
            print('Error cleaning up model-viewer: $e');
          }
        });

        return true;
      } catch (e) {
        print('Model-viewer approach failed: $e');
      }

      // Method 2: Try direct navigation
      try {
        html.window.location.href = glbUrl;
        return true;
      } catch (e) {
        print('Direct navigation failed: $e');
      }

      return false;
    } catch (e) {
      print('Error opening GLB on iPad: $e');
      return false;
    }
  }

  static Future<bool> shareContent(
    String title,
    String text,
    String url,
  ) async {
    try {
      // Check if Web Share API is supported by trying to access it
      print('🔗 Attempting to use Web Share API');
      await html.window.navigator.share({
        'title': title,
        'text': text,
        'url': url,
      });
      print('✅ Web Share API successful');
      return true;
    } catch (e) {
      print('❌ Web Share API error: $e');
      // Check if user cancelled the share dialog
      if (e.toString().contains('AbortError') ||
          e.toString().contains('NotAllowedError')) {
        print('ℹ️ User cancelled share dialog');
        return true; // Don't show error for user cancellation
      }
      // Check if API is not supported
      if (e.toString().contains('TypeError') ||
          e.toString().contains('not supported')) {
        print('❌ Web Share API not supported on this browser');
      }
      return false;
    }
  }

  static Future<bool> copyToClipboard(String text) async {
    try {
      // Check if Clipboard API is supported
      if (html.window.navigator.clipboard != null) {
        print('📋 Using Clipboard API');
        await html.window.navigator.clipboard!.writeText(text);
        print('✅ Clipboard API successful');
        return true;
      } else {
        print('❌ Clipboard API not supported, trying fallback');
        // Fallback: Create a temporary textarea element
        final textarea = html.TextAreaElement();
        textarea.value = text;
        textarea.style.position = 'fixed';
        textarea.style.left = '-999999px';
        textarea.style.top = '-999999px';
        html.document.body?.append(textarea);
        textarea.focus();
        textarea.select();

        final success = html.document.execCommand('copy');
        textarea.remove();

        print(
          success ? '✅ Fallback copy successful' : '❌ Fallback copy failed',
        );
        return success;
      }
    } catch (e) {
      print('❌ Clipboard error: $e');
      return false;
    }
  }

  /// Open USDZ file in AR Quick Look on iOS/iPad Safari
  /// This creates an anchor element with rel="ar" attribute which triggers AR Quick Look
  /// Apple's AR Quick Look requires:
  /// 1. An anchor element with rel="ar" attribute
  /// 2. The href pointing to a USDZ file (from products/usdz/ folder)
  /// 3. User interaction (click) to trigger AR
  ///
  /// Note: Autorotate is controlled by the USDZ file itself, not URL parameters.
  /// The USDZ file must have autorotate enabled in its metadata for it to work.
  /// Navigate back - uses browser history on web
  static void navigateBack() {
    try {
      // Try to go back in browser history
      // On web, we always try to go back - if there's no history,
      // the browser will handle it appropriately (usually stays on page)
      html.window.history.back();
    } catch (e) {
      print('Error navigating back: $e');
      // Fallback: navigate to home page if history.back fails
      try {
        html.window.location.href = '/';
      } catch (e2) {
        print('Error navigating to home: $e2');
      }
    }
  }

  static Future<bool> openUsdzInAR(String usdzUrl) async {
    // Properly encode the URL to handle spaces and special characters
    // PRESERVE CASE SENSITIVITY - critical for file names like "43_EASEL STANDEE.USDZ"
    String encodedUrl;

    // Check if URL needs encoding (has spaces or unencoded special chars)
    if (usdzUrl.contains(' ') ||
        (usdzUrl.contains('%') == false && usdzUrl.contains('&'))) {
      // URL needs encoding - preserve case while encoding
      try {
        // Parse to get components
        final uri = Uri.parse(usdzUrl);

        // Encode path segments individually to preserve case
        final encodedSegments = uri.pathSegments.map((segment) {
          // Uri.encodeComponent preserves case of letters
          return Uri.encodeComponent(segment);
        }).toList();

        // Reconstruct with preserved case
        final encodedPath = '/' + encodedSegments.join('/');
        encodedUrl = '${uri.scheme}://${uri.authority}$encodedPath';

        // Preserve query and fragment
        if (uri.hasQuery) encodedUrl += '?${uri.query}';
        if (uri.hasFragment) encodedUrl += '#${uri.fragment}';

        print('URL encoding - case preserved');
        print('Original: $usdzUrl');
        print('Encoded:  $encodedUrl');
      } catch (e) {
        print('Error in URL parsing, using manual encoding: $e');
        // Manual encoding: only encode spaces, preserve everything else
        encodedUrl = usdzUrl.replaceAll(' ', '%20');
      }
    } else {
      // URL is already properly encoded or doesn't need encoding
      // Use as-is to preserve exact case
      encodedUrl = usdzUrl;
      print('URL already encoded or no encoding needed');
      print('Using URL as-is: $encodedUrl');
    }

    try {
      print('Opening USDZ in AR Quick Look');
      print('Original URL: $usdzUrl');
      print('Encoded URL: $encodedUrl');

      // Validate URL - ensure it's a USDZ file from the usdz/ folder
      if (usdzUrl.isEmpty) {
        print('Invalid USDZ URL: URL is empty');
        return false;
      }

      print('Encoded USDZ URL: $encodedUrl');

      // Case-insensitive check for USDZ extension (but preserve case in URL)
      final lowerUrl = encodedUrl.toLowerCase();
      if (!lowerUrl.contains('usdz')) {
        print('Invalid USDZ URL: URL does not contain .usdz extension');
        print('Original URL: $usdzUrl');
        print('Encoded URL: $encodedUrl');
        return false;
      }

      // Verify URL points to Supabase storage usdz/ folder (case-insensitive check)
      final hasUsdzFolder =
          lowerUrl.contains('/usdz/') ||
          lowerUrl.contains('usdz%') ||
          lowerUrl.contains('/usdz%2f'); // Encoded forward slash
      if (!hasUsdzFolder) {
        print('Warning: USDZ URL may not be from usdz/ folder');
        print('URL: $encodedUrl');
        print('Lower URL: $lowerUrl');
        // Continue anyway as URL might be encoded differently
      }

      // Final check: ensure the encoded URL preserves the original case
      print('=== Case Sensitivity Verification ===');
      final originalHasUpper = usdzUrl.contains(RegExp(r'[A-Z]'));
      final encodedHasUpper = encodedUrl.contains(RegExp(r'[A-Z]'));
      final originalHasLower = usdzUrl.contains(RegExp(r'[a-z]'));
      final encodedHasLower = encodedUrl.contains(RegExp(r'[a-z]'));

      print('Original URL: $usdzUrl');
      print('  Has uppercase: $originalHasUpper');
      print('  Has lowercase: $originalHasLower');
      print('Encoded URL: $encodedUrl');
      print('  Has uppercase: $encodedHasUpper');
      print('  Has lowercase: $encodedHasLower');

      // Verify case is preserved
      if (originalHasUpper != encodedHasUpper ||
          originalHasLower != encodedHasLower) {
        print('⚠️ WARNING: Case may not be fully preserved!');
      } else {
        print('✅ Case sensitivity preserved correctly');
      }
      print('=====================================');

      // Method 1: Create an anchor element with rel="ar" attribute
      // This is Apple's recommended way to trigger AR Quick Look on iOS/iPad Safari
      // The rel="ar" attribute tells Safari to open the file in AR Quick Look
      // Note: Autorotate must be enabled in the USDZ file itself, not via URL
      final anchor = html.AnchorElement()
        ..href = encodedUrl.contains('#') ? encodedUrl : '$encodedUrl#allowsContentScaling=1'
        ..rel =
            'ar' // Critical: This attribute triggers AR Quick Look
        ..style.position = 'fixed'
        ..style.left = '0'
        ..style.top = '0'
        ..style.width = '1px'
        ..style.height = '1px'
        ..style.opacity = '0.01'
        ..style.pointerEvents = 'none'
        ..setAttribute('aria-hidden', 'true');

      // Apple Quick Look requirement: First child MUST be a rendered <img> element.
      // NOTE: Never use display='none', as WebKit treats hidden images as unrendered and triggers a raw download dialog.
      final img = html.ImageElement()
        ..src =
            'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
        ..alt = 'AR Quick Look'
        ..style.width = '1px'
        ..style.height = '1px'
        ..style.opacity = '0.01'
        ..style.position = 'fixed';
      anchor.append(img);

      // Add to document body
      html.document.body?.append(anchor);

      print('Anchor element created with rel="ar"');
      print('Original URL: $usdzUrl');
      print('Encoded URL: $encodedUrl');
      print('Anchor href: ${anchor.href}');

      // Programmatically click the anchor
      // This must be triggered by user interaction (which it is, from button click)
      anchor.click();

      print('Anchor clicked - AR Quick Look should open on iPad/iPhone');
      print(
        'Note: Autorotate is controlled by the USDZ file metadata, not URL parameters',
      );

      // Remove the anchor after a delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          anchor.remove();
          print('Anchor element removed');
        } catch (e) {
          print('Error removing anchor: $e');
        }
      });

      return true;
    } catch (e) {
      print('Error opening USDZ in AR with anchor method: $e');
      print('Stack trace: ${StackTrace.current}');

      // Fallback 1: Try direct window.location navigation with encoded URL
      // Safari might open USDZ files directly in AR Quick Look
      try {
        print('Fallback 1: Trying window.location.href with encoded URL');
        print('Using encoded URL: $encodedUrl');
        html.window.location.href = encodedUrl;
        return true;
      } catch (e2) {
        print('Error with window.location fallback: $e2');

        // Fallback 2: Try window.open in new tab with encoded URL
        // Safari might detect USDZ and open in AR Quick Look
        try {
          print('Fallback 2: Trying window.open with encoded URL');
          print('Using encoded URL: $encodedUrl');
          html.window.open(encodedUrl, '_blank');
          return true;
        } catch (e3) {
          print('Error with window.open fallback: $e3');
          return false;
        }
      }
    }
  }

  /// Safari can open rel="ar" links in AR Quick Look; in-app browsers
  /// (Instagram, Facebook, Gmail...) can't, and the tap does nothing there.
  /// Same test model-viewer uses: Chrome/Edge/Firefox/Google app on iOS support
  /// it but don't report it through relList.
  static bool supportsQuickLook() {
    if (RegExp(r'CriOS/|EdgiOS/|FxiOS/|GSA/|DuckDuckGo/').hasMatch(getUserAgent())) {
      return true;
    }
    try {
      final relList = js.JsObject.fromBrowserObject(html.AnchorElement())['relList'];
      return relList is js.JsObject && relList.callMethod('supports', ['ar']) == true;
    } catch (_) {
      return false;
    }
  }

  /// Android in-app browsers (WebView) have neither WebXR nor intent:// links.
  static bool isAndroidWebView() => getUserAgent().contains('; wv)');

  static void Function()? _onWebXRFailed;
  static bool _webXRTapped = false;

  /// Preload a hidden <model-viewer> so a tap can start Chrome's in-browser
  /// WebXR AR (same path modelviewer.dev uses) inside the user gesture.
  /// [onFailed] runs when the session fails, e.g. the camera prompt is dismissed.
  static void prepareModelViewerAR(String glbUrl, {void Function()? onFailed}) {
    _onWebXRFailed = onFailed;
    final existing = html.document.getElementById('rw-ar-viewer');
    if (existing != null && existing.getAttribute('src') == glbUrl) return;
    existing?.remove();
    final viewer = html.document.createElement('model-viewer')
      ..id = 'rw-ar-viewer'
      ..setAttribute('src', glbUrl)
      ..setAttribute('ar', '')
      ..setAttribute('ar-modes', 'webxr')
      ..setAttribute('ar-placement', 'floor')
      ..setAttribute('loading', 'eager')
      ..style.cssText = _hiddenViewerCss
      // model-viewer has no scan prompt of its own; the model only appears
      // once the floor is found, so tell the user to scan for it.
      ..append(html.DivElement()
        ..className = 'rw-ar-prompt'
        ..text = 'Point your phone at the floor and move it slowly side to side');
    if (html.document.getElementById('rw-ar-style') == null) {
      html.document.head?.append(html.StyleElement()
        ..id = 'rw-ar-style'
        ..text = '''
#rw-ar-viewer > .rw-ar-prompt { display: none; position: absolute; left: 50%;
  bottom: 72px; transform: translateX(-50%); width: max-content; max-width: 80vw;
  padding: 12px 18px; border-radius: 24px; background: rgba(0,0,0,.72);
  color: #fff; font: 500 15px/1.35 Roboto, sans-serif; text-align: center; }
#rw-ar-viewer[ar-status="session-started"] > .rw-ar-prompt,
#rw-ar-viewer[ar-tracking="not-tracking"] > .rw-ar-prompt { display: block; }
''');
    }
    viewer.addEventListener('ar-status', (event) {
      final detail = js.JsObject.fromBrowserObject(event)['detail'];
      final status = detail is js.JsObject ? detail['status'] : null;
      if (status == 'not-presenting' || status == 'failed') {
        viewer.style.cssText = _hiddenViewerCss;
      }
      // 'failed' also fires on load when the phone has no WebXR; only a tap counts.
      if (_webXRTapped && status == 'failed') {
        _webXRTapped = false;
        _onWebXRFailed?.call();
      }
    });
    html.document.body?.append(viewer);
  }

  /// Start WebXR AR on the preloaded viewer. False if the device can't, or if
  /// the model is still downloading: model-viewer would wait for the download
  /// before asking for the camera, the tap's user activation expires on a slow
  /// network, and the session fails with nothing on screen. Scene Viewer
  /// downloads the model itself and shows its own loader, so it takes over.
  /// After a failed session model-viewer stops offering WebXR, so the next tap
  /// lands on Scene Viewer too.
  static bool activateModelViewerAR() {
    final viewer = html.document.getElementById('rw-ar-viewer');
    if (viewer == null) return false;
    final jsViewer = js.JsObject.fromBrowserObject(viewer);
    if (jsViewer['canActivateAR'] != true || jsViewer['loaded'] != true) {
      return false;
    }
    _webXRTapped = true;
    // model-viewer draws its AR UI (scan-the-floor prompt, exit button) inside
    // the element, so it must fill the screen while AR runs; at 1px it's invisible.
    viewer.style.cssText = _arViewerCss;
    jsViewer.callMethod('activateAR');
    return true;
  }

  static const _hiddenViewerCss =
      'position:fixed;left:0;bottom:0;width:1px;height:1px;pointer-events:none;';
  static const _arViewerCss =
      'position:fixed;inset:0;width:100vw;height:100vh;z-index:2147483647;';

  static void disposeModelViewerAR() =>
      html.document.getElementById('rw-ar-viewer')?.remove();

  /// Launch Google Scene Viewer on Android web in the CURRENT window (same tab).
  ///
  /// CRITICAL: Never use window.open() or url_launcher's LaunchMode.externalApplication (_blank).
  /// Spawning an empty _blank tab causes Android Chrome to immediately abort/bounce back to fallback URL.
  ///
  /// When the phone can't run Scene Viewer (no Google app / AR services), Chrome
  /// opens the fallback URL, which is this same page (hash routing, no reload).
  /// If the page never went to the background, Scene Viewer didn't open, and
  /// [onUnavailable] tells the user instead of the tap doing nothing.
  static void launchAndroidSceneViewer({
    required String glbUrl,
    required String title,
    void Function()? onUnavailable,
  }) {
    try {
      var leftPage = false;
      final sub = html.document.onVisibilityChange.listen((_) {
        if (html.document.hidden == true) leftPage = true;
      });
      Future.delayed(const Duration(seconds: 4), () {
        sub.cancel();
        if (!leftPage) onUnavailable?.call();
      });
      final cleanGlbUrl = glbUrl.trim();
      final encodedFile = Uri.encodeComponent(cleanGlbUrl);
      final encodedTitle = Uri.encodeComponent(title.trim());
      final encodedFallback = Uri.encodeComponent(html.window.location.href);

      final intentUrl = 'intent://arvr.google.com/scene-viewer/1.0'
          '?file=' + encodedFile +
          '&mode=ar_preferred' +
          '&title=' + encodedTitle +
          '&resizable=true' +
          '#Intent;' +
          'scheme=https;' +
          'package=com.google.android.googlequicksearchbox;' +
          'action=android.intent.action.VIEW;' +
          'S.browser_fallback_url=' + encodedFallback +
          ';end;';

      print('Launching Scene Viewer in current window: ' + intentUrl);
      html.window.location.href = intentUrl;
    } catch (e) {
      print('Error launching Android Scene Viewer: ' + e.toString());
    }
  }
}
