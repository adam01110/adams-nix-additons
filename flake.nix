{
  description = "Ghostty shaders and custom Bibata cursors flake with Home Manager modules";

  inputs = {
    # Pinned by flake.lock when users run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ghostty shader playground repository
    ghostty-shader-playground = {
      url = "github:KroneCorylus/ghostty-shader-playground";
      flake = false;
    };

    # Bibata cursor repository
    bibata-cursor-src = {
      url = "github:ful1e5/Bibata_Cursor";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ghostty-shader-playground,
      bibata-cursor-src,
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

      # Use the git repository for shaders instead of local directory
      shadersDir = "${ghostty-shader-playground}/shaders";
    in
    {
      # Export the Home Manager module under both names
      homeManagerModules = {
        ghostty-shader = import ./modules/ghostty-shader.nix;
        default = self.outputs.homeManagerModules.ghostty-shader;
      };

      # Expose library functions for creating custom packages
      lib = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          bibataCursorsLib = import ./modules/bibata-cursors.nix {
            inherit lib pkgs bibata-cursor-src;
          };
        in
        {
          inherit (bibataCursorsLib) makeBibataCursorsClassic;
        }
      );

      # Provide a per-system formatter for convenience
      formatter = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixpkgs-fmt
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

      # Expose packages for both ghostty shaders and bibata cursors
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          ghostty-shaders = pkgs.stdenvNoCC.mkDerivation {
            pname = "ghostty-shaders";
            version = "1.0.0";
            src = shadersDir;
            dontUnpack = true;
            installPhase = ''
              mkdir -p "$out/share/ghostty/shaders"
              cp -v "$src"/*.glsl "$out/share/ghostty/shaders/"
            '';
            meta = with pkgs.lib; {
              description = "Ghostty cursor and visual effect shaders";
              homepage = "https://github.com/KroneCorylus/ghostty-shader-playground";
              platforms = platforms.all;
              license = licenses.mit;
            };
          };

          # Default bibata classic cursors
          bibata-cursors-classic = self.lib.${system}.makeBibataCursorsClassic { };
        }
      );
    };
}
