# adams-nix-additons

A Nix flake that provides both Ghostty shaders and Bibata cursor themes, with Home Manager integration.

## Features

### 🎨 Ghostty Shaders

- Collection of visual effect shaders for the [Ghostty terminal emulator](https://github.com/ghostty-org/ghostty)
- Fetched directly from the [KroneCorylus/ghostty-shader-playground](https://github.com/KroneCorylus/ghostty-shader-playground) repository
- Home Manager module for easy configuration
- Available shaders:
  - `cursor_blaze.glsl` (default)
  - `cursor_blaze_no_trail.glsl`
  - `cursor_blaze_tapered.glsl`
  - `cursor_frozen.glsl`
  - `cursor_smear_fade.glsl`
  - `cursor_smear.glsl`
  - `debug_cursor_animated.glsl`
  - `debug_cursor_static.glsl`
  - `manga_slash.glsl`
  - `WIP.glsl`

### 🖱️ Bibata Cursors

Material design cursor themes based on [Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor) with two variants:

#### Classic Cursors

- Classic black/dark cursor variants
- Both modern and original (sharp edge) styles
- Support for left and right-handed variants
- Modular architecture for easy customization

#### Rose Pine Cursors

- Rose Pine themed cursor variants with custom colors
- Both modern and original (sharp edge) styles
- Support for left and right-handed variants
- Uses the following Rose Pine color palette:
  - **base**: `#191724` (primary background)
  - **outline**: `#21202e` (cursor outline)
  - **watch background**: `#26233a` (loading/wait states)
  - **watch colors**: `#32a0da`, `#7eba41`, `#f05024`, `#fcb813` (animated elements)

## Installation & Usage

### Adding to Your Flake

Add this flake as an input to your system flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # Add this flake
    adams-nix-additons.url = "github:yourusername/adams-nix-additons";
    adams-nix-additons.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

### Using Ghostty Shaders with Home Manager

```nix
{
  home-manager.users.yourusername = { inputs, ... }: {
    imports = [
      inputs.adams-nix-additons.homeManagerModules.ghostty-shader
    ];

    programs.ghostty = {
      enable = true;

      # Enable shader support
      shader = {
        enable = true;
        name = "cursor_blaze.glsl";  # Choose any available shader
      };

      # Your other ghostty settings
      settings = {
        theme = "Dracula";
        font-size = 14;
      };
    };
  };
}
```

### Installing Packages Directly

You can install the packages directly without Home Manager:

```bash
# Install ghostty shaders
nix profile install github:yourusername/adams-nix-additons#ghostty-shaders

# Install classic bibata cursors
nix profile install github:yourusername/adams-nix-additons#bibata-cursors-classic

# Install rose pine bibata cursors
nix profile install github:yourusername/adams-nix-additons#bibata-cursors-rose-pine
```

## Development

### Testing the Flake

```bash
# Check flake validity
nix flake check

# Show available outputs
nix flake show

# Build packages locally
nix build .#ghostty-shaders
nix build .#bibata-cursors-classic
nix build .#bibata-cursors-rose-pine
```

### Customization Options

#### Classic Cursors

The `makeBibataCursorsBlack` function accepts the following parameters:

- `primaryColor` (default: `"#000000"`): Color for the black cursor variants
- `enableRightHanded` (default: `true`): Whether to include right-handed cursor variants

#### Rose Pine Cursors

The `makeBibataCursorsRosePine` function accepts the following parameters:

- `enableRightHanded` (default: `true`): Whether to include right-handed cursor variants

Colors should be provided as hex color codes (e.g., `"#000000"`).

## License

- Ghostty shaders: MIT License (from original repository)
- Bibata cursors: GPL-3.0 License (from original repository)
- This flake: MIT License
