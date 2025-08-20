{
  lib,
  pkgs,
  bibata-cursor-src,
}:

{
  # Build default Bibata Classic variants (no customization)
  makeBibataCursorsClassic = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "bibata-cursors-classic";
    version = "2.0.7";

    src = bibata-cursor-src;

    bitmaps = pkgs.fetchzip {
      url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v${version}/bitmaps.zip";
      hash = "sha256-4VjyNWry0NPnt5+s0od/p18gry2O0ZrknYZh+PAPM8Q=";
    };

    nativeBuildInputs = with pkgs; [
      clickgen
      python3
    ];

    buildPhase = ''
      runHook preBuild

      # Build only classic cursors (classic variants)
      # Modern style classic
      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Classic -n 'Bibata-Modern-Classic' -c 'Classic Bibata modern XCursors'

      # Original/sharp style classic
      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Original-Classic -n 'Bibata-Original-Classic' -c 'Classic Bibata sharp edge XCursors'

      # Right-handed variants
      ctgen configs/right/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Classic-Right -n 'Bibata-Modern-Classic-Right' -c 'Classic right-hand Bibata modern XCursors'
      ctgen configs/right/x.build.toml -p x11 -d $bitmaps/Bibata-Original-Classic-Right -n 'Bibata-Original-Classic-Right' -c 'Classic right-hand Bibata sharp edge XCursors'

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -dm 0755 $out/share/icons
      cp -rf themes/* $out/share/icons/

      runHook postInstall
    '';

    meta = with lib; {
      description = "Material Based Cursor Theme (Classic variants)";
      homepage = "https://github.com/ful1e5/Bibata_Cursor";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      maintainers = with maintainers; [
        rawkode
        AdsonCicilioti
      ];
    };
  };
}
