{
  lib,
  config,
  pkgs,
  ...
}@args:

let
  # Get the ghostty-shader flake from inputs (more user-friendly)
  inputs =
    args.specialArgs.inputs or (throw "ghostty-shader module requires 'inputs' in extraSpecialArgs");
  self = inputs.ghostty-shader or (throw "ghostty-shader module requires inputs.ghostty-shader");

  inherit (lib) mkOption types mkIf;
  cfg = config.programs.ghostty.shader;

  # Directory of shaders shipped by this flake
  shaderDir = self + "/shaders";

  # List shader filenames in the flake's shaders directory
  shaderNames = builtins.attrNames (builtins.readDir shaderDir);

  # Reuse the flake's packaged shaders for the current system
  shadersPkg = self.packages.${pkgs.system}.ghostty-shaders;

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
      type = types.enum shaderNames;
      default = "cursor_blaze.glsl";
      example = "manga_slash.glsl";
      description = ''
        Filename of the shader from this flake's shaders directory.
        One of: ${lib.concatStringsSep ", " shaderNames}
      '';
    };
  };

  config = mkIf cfg.enable {
    # Only add the shader field; do not override user-defined settings.
    programs.ghostty = {
      settings.shader = shaderPath;
    };
  };
}
