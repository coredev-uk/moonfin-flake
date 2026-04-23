{
  lib,
  flutter341,
  fetchFromGitHub,
  alsa-lib,
  libass,
  ffmpeg,
  mpv-unwrapped,
  libsecret,
  copyDesktopItems,
  makeDesktopItem,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "moonfin";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Moonfin-Client";
    repo = "Mobile-Desktop";
    tag = finalAttrs.version;
    hash = "sha256-oFPzyaXrUccXjksvOVb8MAej1cP1rTv4VpwdGKRqHeI=";
  };

  autoPubspecLock = finalAttrs.src + "/pubspec.lock";

  buildInputs = [
    alsa-lib
    libass
    ffmpeg
    mpv-unwrapped
    libsecret
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
    homepage = "https://github.com/Moonfin-Client/Mobile-Desktop";
    changelog = "https://github.com/Moonfin-Client/Mobile-Desktop/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "moonfin";
    platforms = lib.platforms.linux;
  };
})
