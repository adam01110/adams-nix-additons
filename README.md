# Ghostty Shaders and Custom Bibata Cursors Flake

A Nix flake that provides both Ghostty shaders and customizable Bibata cursor themes, with Home Manager integration.

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

### 🖱️ Custom Bibata Cursors

- Material design cursor theme based on [Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor)
- Support for custom colors (primary, secondary, tertiary)
- Both modern and original styles
- Support for left and right-handed variants

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

# Install default bibata cursors
nix profile install github:yourusername/adams-nix-additons#bibata-cursors-custom
```

### Creating Custom Colored Bibata Cursors

Use the library function to create cursors with custom colors:

```nix
let
  myCustomCursors = inputs.adams-nix-additons.lib.${system}.makeBibataCursors {
    primaryColor = "#FF6B6B";    # Custom red
    secondaryColor = "#4ECDC4";  # Custom teal
    tertiaryColor = "#45B7D1";   # Custom blue
  };
in
{
  # Use myCustomCursors in your configuration
  home.packages = [ myCustomCursors ];
}
```

## Available Outputs

- **packages**: Pre-built packages for multiple systems

  - `ghostty-shaders`: Collection of Ghostty shader files
  - `bibata-cursors-custom`: Default Bibata cursors with original colors

- **lib**: Library functions for customization

  - `makeBibataCursors`: Function to create custom colored Bibata cursors

- **homeManagerModules**: Home Manager integration
  - `ghostty-shader`: Module for easy Ghostty shader configuration
  - `default`: Alias for the ghostty-shader module

## Development

### Testing the Flake

```bash
# Check flake validity
nix flake check

# Show available outputs
nix flake show

# Build packages locally
nix build .#ghostty-shaders
nix build .#bibata-cursors-custom
```

### Color Customization

The `makeBibataCursors` function accepts the following color parameters:

- `primaryColor` (default: `"#FF8C00"`): Amber color for primary variants
- `secondaryColor` (default: `"#000000"`): Black color for classic variants
- `tertiaryColor` (default: `"#FFFFFF"`): White color for ice variants

Colors should be provided as hex color codes (e.g., `"#FF6B6B"`).

## License

- Ghostty shaders: MIT License (from original repository)
- Bibata cursors: GPL-3.0 License (from original repository)
- This flake: MIT License

## Contributing

Feel free to submit issues and pull requests for improvements to the flake configuration or additional shader/cursor variants.
