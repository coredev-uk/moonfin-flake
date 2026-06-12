{
  lib,
  runCommand,
  yq,
  flutter341,
  fetchFromGitHub,
  alsa-lib,
  libass,
  libplacebo,
  ffmpeg,
  mpv-unwrapped,
  libsecret,
  webkitgtk_4_1,
  copyDesktopItems,
  makeDesktopItem,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "moonfin";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Moonfin-Client";
    repo = "Moonfin-Core";
    tag = finalAttrs.version;
    hash = "sha256-rCxWoACl0Q8RM461jh4X+OGWINwAuXu0XInOjnR1qFQ=";
  };

  pubspecLock =
    let
      lock = lib.importJSON (
        runCommand "${finalAttrs.pname}-${finalAttrs.version}-pubspec-lock.json"
          { nativeBuildInputs = [ yq ]; }
          ''
            yq . '${finalAttrs.src}/pubspec.lock' > "$out"
          ''
      );
    in
    lock
    // {
      sdks = lock.sdks // {
        dart = ">=3.11.0 <4.0.0";
        flutter = ">=3.41.0";
      };
    };

  customSourceBuilders =
    let
      patchSdk =
        name:
        { src, version, ... }:
        runCommand "pub-${name}-${version}" { passthru = src.passthru; } ''
          cp -r '${src}' "$out"
          chmod -R u+w "$out"
          substituteInPlace "$out/pubspec.yaml" --replace-fail "sdk: ^3.12.0" "sdk: ^3.11.0"
        '';
    in
    {
      shared_preferences_android = patchSdk "shared_preferences_android";
      sqflite = patchSdk "sqflite";
      sqflite_android = patchSdk "sqflite_android";
      sqflite_common = patchSdk "sqflite_common";
      sqflite_darwin = patchSdk "sqflite_darwin";
      sqflite_platform_interface = patchSdk "sqflite_platform_interface";
      url_launcher_android = patchSdk "url_launcher_android";
      video_player_android = patchSdk "video_player_android";

      webview_flutter_android =
        { src, version, ... }:
        runCommand "pub-webview_flutter_android-${version}" { passthru = src.passthru; } ''
                cp -r '${src}' "$out"
                chmod -R u+w "$out"
                substituteInPlace "$out/pubspec.yaml" --replace-fail "sdk: ^3.12.0" "sdk: ^3.11.0"
                sed -i '/AndroidSslAuthError._({/,/^  });/c\  AndroidSslAuthError._({\
            required super.certificate,\
            required super.description,\
            required android.SslErrorHandler handler,\
            required this.url,\
          }) : _handler = handler;' "$out/lib/src/android_ssl_auth_error.dart"
                substituteInPlace "$out/lib/src/android_webview_controller.dart" \
                  --replace-fail "const AndroidWebViewPermissionRequest._({required super.types, required this._request});" \
                    "const AndroidWebViewPermissionRequest._({required super.types, required android_webview.PermissionRequest request}) : _request = request;"
        '';

      webview_flutter_wkwebview =
        { src, version, ... }:
        runCommand "pub-webview_flutter_wkwebview-${version}" { passthru = src.passthru; } ''
                cp -r '${src}' "$out"
                chmod -R u+w "$out"
                substituteInPlace "$out/pubspec.yaml" --replace-fail "sdk: ^3.12.0" "sdk: ^3.11.0"
                sed -i '/WebKitSslAuthError({/,/^  });/c\  WebKitSslAuthError({\
            required super.certificate,\
            required super.description,\
            required SecTrust trust,\
            required this.host,\
            required this.port,\
            required Future<void> Function(UrlSessionAuthChallengeDisposition disposition, URLCredential? credential) onResponse,\
          }) : _trust = trust,\
               _onResponse = onResponse;' "$out/lib/src/webkit_ssl_auth_error.dart"
                substituteInPlace "$out/lib/src/webkit_webview_controller.dart" \
                  --replace-fail "const WebKitWebViewPermissionRequest._({required super.types, required this._onDecision});" \
                    "const WebKitWebViewPermissionRequest._({required super.types, required void Function(PermissionDecision) onDecision}) : _onDecision = onDecision;"
        '';

      pdfium_flutter = { src, ... }: src;
      sqlite3_flutter_libs = { src, ... }: src;
    };

  buildInputs = [
    alsa-lib
    libass
    ffmpeg
    libplacebo
    mpv-unwrapped
    libsecret
    webkitgtk_4_1
  ];

  CXXFLAGS = [ "-Wno-deprecated-literal-operator" ];

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "org.moonfin.linux";
      desktopName = "Moonfin";
      genericName = "Media Client";
      comment = "Jellyfin and Emby media client";
      exec = "moonfin %u";
      icon = "moonfin";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
      ];
      mimeTypes = [
        "x-scheme-handler/jellyfin"
        "x-scheme-handler/emby"
      ];
      startupWMClass = "moonfin";
      terminal = false;
    })
  ];

  postInstall = ''
    install -Dm644 assets/icons/moonfin.png "$out/share/pixmaps/moonfin.png"
  '';

  meta = {
    description = "Jellyfin and Emby media client for Linux";
    homepage = "https://github.com/Moonfin-Client/Moonfin-Core";
    changelog = "https://github.com/Moonfin-Client/Moonfin-Core/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "moonfin";
    platforms = lib.platforms.linux;
  };
})
