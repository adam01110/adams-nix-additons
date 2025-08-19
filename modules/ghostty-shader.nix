{
  lib,
  config,
  pkgs,
  ...
}@args:

let
  # Get the adams-nix-additons flake from inputs (updated from ghostty-shader)
  inputs =
    args.specialArgs.inputs or (throw "ghostty-shader module requires 'inputs' in extraSpecialArgs");
  self =
    inputs.adams-nix-additons or (throw "ghostty-shader module requires inputs.adams-nix-additons");

  inherit (lib) mkOption types mkIf;
  cfg = config.programs.ghostty.shader;

  # Directory of shaders from the git repository
  shaderDir = "${inputs.adams-nix-additons.inputs.ghostty-shader-playground}/shaders";

  # List shader filenames in the git repository's shaders directory
  shaderNames = builtins.attrNames (builtins.readDir shaderDir);

  # Use direct path to shader instead of packaged approach
  shaderPath = "${shaderDir}/${cfg.name}";
in
{
  options.programs.ghostty.shader = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Enable setting a Ghostty shader from the shader playground.";
    };

    name = mkOption {
      type = types.enum shaderNames;
      default = "cursor_blaze.glsl";
      example = "manga_slash.glsl";
      description = ''
        Filename of the shader from the shader playground repository.
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
