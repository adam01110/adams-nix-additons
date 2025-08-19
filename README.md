# adams-nix-additons

A Nix flake providing **Ghostty terminal shader effects** and **Bibata cursor themes** for NixOS and Home Manager.

## Features

### 🎨 Ghostty Shaders

High-quality visual effects and themes for the [Ghostty terminal emulator](https://github.com/ghostty-org/ghostty).

### 🖱️ Bibata Cursors

Material-based cursor themes with two variants:

#### Classic Cursors

- **Description**: Traditional black cursors with white outlines
- **Package**: `bibata-cursors-classic`
- **Style**: Material design aesthetic with classic black theme

#### Rose Pine Cursors

- **Description**: Rose Pine themed cursors with a carefully crafted color palette
- **Package**: `bibata-cursors-rose-pine`
- **Colors**:
  - **base**: `#191724` (primary background)
  - **outline**: `#21202e` (cursor outline)
  - **watch background**: `#26233a` (loading/wait states)
  - **watch colors**: `#32a0da`, `#7eba41`, `#f05024`, `#fcb813` (animated elements)

## Installation

### Flake Inputs

Add this flake to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    adams-nix-additons = {
      url = "github:yourusername/adams-nix-additons";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
}
```

### Package Installation

#### Classic Cursors

```nix
# In your system configuration or home-manager
environment.systemPackages = [
  inputs.adams-nix-additons.packages.${system}.bibata-cursors-classic
];

# Or in home-manager
home.packages = [
  inputs.adams-nix-additons.packages.${system}.bibata-cursors-classic
];
```

#### Rose Pine Cursors

```nix
# In your system configuration or home-manager
environment.systemPackages = [
  inputs.adams-nix-additons.packages.${system}.bibata-cursors-rose-pine
];

# Or in home-manager
home.packages = [
  inputs.adams-nix-additons.packages.${system}.bibata-cursors-rose-pine
];
```

### Ghostty Shader Module

Enable in your Home Manager configuration:

```nix
{
  imports = [
    inputs.adams-nix-additons.homeManagerModules.ghostty-shader
  ];

  programs.ghostty-shader = {
    enable = true;
    # Optional: specify shader files
    shaderFiles = ["blur.frag" "glow.frag"];
  };
}
```

## Available Outputs

### Packages

- **`bibata-cursors-classic`** - Material based classic cursor theme
- **`bibata-cursors-rose-pine`** - Rose pine themed cursor set

### Home Manager Modules

- **`ghostty-shader`** - Module for managing Ghostty shader effects

## Development

### Building Locally

```bash
nix build .#bibata-cursors-classic
nix build .#bibata-cursors-rose-pine
nix build .#ghostty-shader
```

### Testing

```bash
nix flake check
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
