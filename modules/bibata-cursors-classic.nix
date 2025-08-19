{
  fetchurl,
  python3,
  stdenv,
  lib,
}:
{
  enableRightHanded ? true,
  primaryColor ? "#000000",
}:
# Function to create bibata cursors with only classic variants
let
  pname = "bibata-cursors-classic";
  version = "2.0.7";

  src = fetchurl {
    url = "https://github.com/ful1e5/Bibata_Cursor/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-4VjyNWry0NPnt5+s0od/p18gry2O0ZrknYZh+PAPM8Q=";
  };

  bitmaps = fetchurl {
    url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v${version}/bitmaps.zip";
    hash = "sha256-z6JFXd4E5VmTr21xqOAWKDTfVec0BqEjmZ4sCYJtY5Y=";
  };

  clickgen = python3.pkgs.clickgen;
  ctgen = "${clickgen}/bin/ctgen";
in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    python3
    clickgen
  ];

  buildPhase = ''
    # Extract bitmaps
    unzip -o ${bitmaps}

    # Build only classic cursors (classic variants)
    ${ctgen} build.toml -p x11 -d "bitmaps/Bibata-Modern-Classic" -n "Bibata-Modern-Classic" -c "Material Based Classic Cursor Theme"

    ${ctgen} build.toml -p x11 -d "bitmaps/Bibata-Original-Classic" -n "Bibata-Original-Classic" -c "Material Based Classic Cursor Theme"

    ${lib.optionalString enableRightHanded ''
      # Build right-handed variants
      ${ctgen} build.toml -p x11 -d "bitmaps/Bibata-Modern-Classic-Right" -n "Bibata-Modern-Classic-Right" -c "Material Based Classic Cursor Theme (Right Handed)"

      ${ctgen} build.toml -p x11 -d "bitmaps/Bibata-Original-Classic-Right" -n "Bibata-Original-Classic-Right" -c "Material Based Classic Cursor Theme (Right Handed)"
    ''}
  '';

  installPhase = ''
    install -dm 0755 $out/share/icons
    cp -rf themes/* $out/share/icons/
  '';

  meta = {
    description = "Material Based Classic Cursor Theme (Classic variants)";
    homepage = "https://github.com/ful1e5/Bibata_Cursor";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
