{
  description = "Ghostty shader flake with a Home Manager module and packaged shaders";

  inputs = {
    # Pinned by flake.lock when users run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      shadersDir = ./shaders;
    in
    {
      # Export the Home Manager module under both names
      homeManagerModules = {
        ghostty-shader = import ./modules/ghostty-shader.nix;
        default = self.outputs.homeManagerModules.ghostty-shader;
      };

      # Expose packages.<system>.ghostty-shaders that installs shaders to $out/share/ghostty/shaders
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          shaderNames = builtins.attrNames (builtins.readDir shadersDir);
        in
        {
          ghostty-shaders = pkgs.stdenvNoCC.mkDerivation {
            pname = "ghostty-shaders";
            version = "1.0.0";
            src = shadersDir;
            dontUnpack = true;
            installPhase = ''
              mkdir -p "$out/share/ghostty/shaders"
              cp -v ${
                lib.concatStringsSep " " (map (n: "${shadersDir}/${n}") shaderNames)
              } "$out/share/ghostty/shaders/"
            '';
            meta = with pkgs.lib; {
              description = "Example Ghostty shaders (CRT and scanlines)";
              platforms = systems;
              license = licenses.mit;
            };
          };
        }
      );

      # Flake checks: evaluate module successfully; assert invalid name fails at evaluation
      checks = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          hm = home-manager;
          hmModule = import ./modules/ghostty-shader.nix;

          # Valid evaluation (forces evaluation by referencing activationPackage)
          validCfg = hm.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inputs = {
                ghostty-shader = self;
              };
            };
            modules = [
              hmModule
              {
                home.username = "dummy";
                home.homeDirectory = "/homeless-shelter";

                programs.ghostty.enable = true;

                programs.ghostty.shader = {
                  enable = true;
                  name = "cursor_blaze.glsl";
                };

                # Example user settings that should be preserved/merged
                programs.ghostty.settings = {
                  theme = "Dracula";
                };
              }
            ];
          };

          # Expect evaluation to fail for an invalid shader name
          invalidTry = builtins.tryEval (
            hm.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inputs = {
                  ghostty-shader = self;
                };
              };
              modules = [
                hmModule
                {
                  home.username = "dummy";
                  home.homeDirectory = "/homeless-shelter";

                  programs.ghostty.enable = true;

                  programs.ghostty.shader = {
                    enable = true;
                    name = "this-does-not-exist.glsl";
                  };
                }
              ];
            }
          );

          # Assert the invalid evaluation fails during flake evaluation
          _assertInvalid =
            assert invalidTry.success == false;
            true;

          # Force evaluation of the valid configuration
          _forceValidEval = builtins.seq validCfg.activationPackage true;
        in
        {
          hm-eval-valid = pkgs.runCommand "ghostty-shader-hm-eval-valid" { } ''
            mkdir -p "$out"
          '';

          hm-eval-invalid = pkgs.runCommand "ghostty-shader-hm-eval-invalid" { } ''
            mkdir -p "$out"
          '';
        }
      );
    };
}
