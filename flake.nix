{
  description = "Ghostty shaders and custom Bibata cursors flake with Home Manager modules";

  inputs = {
    # Pinned by flake.lock when users run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bibata-cursor-src = {
      url = "github:ful1e5/Bibata_Cursor";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      bibata-cursor-src,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
    in
    {
      lib = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          lib = nixpkgs.lib;
          bibataCursorsLib = import ./modules/bibata-cursors-classic.nix {
            inherit lib pkgs bibata-cursor-src;
          };
          bibataCursorsRosePineLib = import ./modules/bibata-cursors-rose-pine.nix {
            inherit lib pkgs bibata-cursor-src;
          };
        in
        {
          inherit (bibataCursorsLib) makeBibataCursorsBlack;
          inherit (bibataCursorsRosePineLib) makeBibataCursorsRosePine;
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixpkgs-fmt
      );

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          bibata-cursors-classic = self.lib.${system}.makeBibataCursorsBlack { };
          bibata-cursors-rose-pine = self.lib.${system}.makeBibataCursorsRosePine { };
        }
      );
    };
}
