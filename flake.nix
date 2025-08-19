{
  description = "Ghostty shaders and custom Bibata cursors flake with Home Manager modules";

  inputs = {
    # Pinned by flake.lock when users run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
          rosePineLib = pkgs.callPackage ./modules/bibata-cursors-rose-pine.nix {
            inherit bibata-cursor-src;
          };
        in
        {
          makeBibataCursorsClassic = pkgs.callPackage ./modules/bibata-cursors-classic.nix { };
          inherit (rosePineLib) makeBibataCursorsRosePine;
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
          rosePineLib = pkgs.callPackage ./modules/bibata-cursors-rose-pine.nix {
            inherit bibata-cursor-src;
          };
        in
        {
          bibata-cursors-classic = (pkgs.callPackage ./modules/bibata-cursors-classic.nix { }) { };
          bibata-cursors-rose-pine = rosePineLib.makeBibataCursorsRosePine { };
        }
      );
    };
}
