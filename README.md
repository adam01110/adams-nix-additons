# Ghostty Shader Flake

This flake ships a collection of Ghostty post-processing shaders and a Home Manager module that exposes two options:

- `programs.ghostty.shader.enable` (boolean; default `false`)
- `programs.ghostty.shader.name` (string; must be the filename of a shader in this flake's `shaders/` directory)

When enabled, the module sets `programs.ghostty.settings.shader` to the derivation path of the selected shader packaged by this flake, and also appends a compatible line to `programs.ghostty.extraConfig`. When disabled, it does not alter Ghostty settings.

The shader files are shipped inside the flake and referenced via `self + "/shaders"` for purity and reproducibility.

Available shaders include cursor effects (blaze, smear, frozen), animated effects (manga slash), and debug utilities.

## Outputs

- `homeManagerModules.default` and `homeManagerModules.ghostty-shader` — the Home Manager module.
- `packages.<system>.ghostty-shaders` — installs the shaders to `$out/share/ghostty/shaders` for consumption outside Home Manager.

## Example usage from another flake

Below are minimal examples showing how to consume this module with both standalone Home Manager style and NixOS + Home Manager style. Replace the GitHub URL with the repository of this flake.

### Flake inputs and outputs

```nix
{
  description = "My desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty-shader.url = "github:example/ghostty-shader-flake";
    ghostty-shader.inputs.nixpkgs.follows = "nixpkgs";
    ghostty-shader.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ghostty-shader, ... }:
  let
    lib = nixpkgs.lib;
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  in {
    # Your outputs go here...
## Validation and checks

- The module asserts that when `programs.ghostty.shader.enable = true;`, the `name` exists in this flake's `shaders/` directory and fails evaluation otherwise with a clear message.
- `nix flake check` includes:
  - A valid evaluation that forces the module to evaluate successfully.
  - A negative test that asserts enabling with an invalid name fails at evaluation.

  };
}
```

### Standalone Home Manager configuration

- Case A: disabled (no Ghostty settings altered by this module)

```nix
{
  homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "x86_64-linux"; };

    modules = [
      ghostty-shader.homeManagerModules.default

      {
        home.username = "me";
        home.homeDirectory = "/home/me";

        programs.ghostty.enable = true;

        # Existing user settings are preserved; the module will not modify them when disabled.
        programs.ghostty.settings = {
          theme = "Dracula";
          font-size = 12;
        };

        programs.ghostty.shader = {
          enable = false;
          # name is ignored while disabled
          name = "cursor_blaze.glsl";
        };
      }
    ];
  };
}
```

- Case B: enabled with the built-in "cursor_blaze.glsl"

```nix
{
  homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { system = "x86_64-linux"; };

    modules = [
      ghostty-shader.homeManagerModules.default

      {
        home.username = "me";
        home.homeDirectory = "/home/me";

        programs.ghostty.enable = true;

        # Your existing settings remain; the module only adds the 'shader' key.
        programs.ghostty.settings = {
          theme = "Catppuccin Mocha";
          font-size = 12;
        };

        programs.ghostty.shader = {
          enable = true;
          name = "cursor_blaze.glsl"; # or "manga_slash.glsl", "cursor_smear.glsl", etc.
        };
      }
    ];
  };
}
```

### NixOS + Home Manager module style

```nix
{
  nixosConfigurations.mach = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      home-manager.nixosModules.home-manager

      {
        users.users.me = {
          isNormalUser = true;
          home = "/home/me";
          extraGroups = [ "wheel" ];
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.users.me = {
          imports = [ ghostty-shader.homeManagerModules.default ];

          programs.ghostty.enable = true;

          # Example: disabled (does not change settings)
          # programs.ghostty.shader.enable = false;

          # Example: enabled with "cursor_blaze.glsl"
          programs.ghostty.shader.enable = true;
          programs.ghostty.shader.name = "cursor_blaze.glsl";

          # Existing settings are merged, not overwritten
          programs.ghostty.settings = {
            font-size = 13;
            theme = "Dracula";
          };
        };
      }
    ];
  };
}
```

### Consuming shaders without Home Manager

To install the shaders derivation directly:

- NixOS: add to `environment.systemPackages`
- Home Manager: add to `home.packages`

```nix
# Example inside a per-system output or module
{
  home.packages = [
    ghostty-shader.packages.${pkgs.system}.ghostty-shaders
  ];
}
```

The shaders will be available under `$out/share/ghostty/shaders`.
