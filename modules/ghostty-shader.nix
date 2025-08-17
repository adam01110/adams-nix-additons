{ self }:
{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mkIf;
  cfg = config.programs.ghostty.shader;

  # Directory of shaders shipped by this flake
  shaderDir = self + "/shaders";

  # List shader filenames in the flake's shaders directory
  shaderNames = builtins.attrNames (builtins.readDir shaderDir);

  # Package shaders into $out/share/ghostty/shaders
  shadersPkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "ghostty-shaders";
    version = "1.0.0";
    src = shaderDir;
    dontUnpack = true;
    installPhase = ''
      mkdir -p "$out/share/ghostty/shaders"
      cp -v ${
        lib.concatStringsSep " " (map (n: "${shaderDir}/${n}") shaderNames)
      } "$out/share/ghostty/shaders/"
    '';
  };

  shaderPath = "${shadersPkg}/share/ghostty/shaders/${cfg.name}";
in
{
  options.programs.ghostty.shader = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Enable setting a Ghostty shader packaged by this flake.";
    };

    name = mkOption {
      type = types.str;
      default = "cursor_blaze.glsl";
      example = "manga_slash.glsl";
      description = ''
        Filename of the shader from this flake's shaders directory.
        Must be one of: ${lib.concatStringsSep ", " shaderNames}
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.elem cfg.name shaderNames;
        message =
          "ghostty-shader: name '${cfg.name}' not found. Available shaders: "
          + (lib.concatStringsSep ", " shaderNames);
      }
    ];

    # Only add the shader field; do not override user-defined settings.
    programs.ghostty = {
      settings.shader = shaderPath;

      # For older Ghostty versions that rely on extraConfig
      # Use mkAfter so we do not overwrite user-provided extraConfig.
      extraConfig = lib.mkAfter "shader ${shaderPath}\n";
    };
  };
}
