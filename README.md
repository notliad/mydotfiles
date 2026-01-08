# 🛠️ Dotfiles - Omarchy

This repository hosts the personal configuration files for my Linux environment (**Arch Linux**), aimed at productivity and customization.

## 🎯 Motivation

I created this repository to better organize and automate my **Omarchy** installation. Having a centralized and reproducible setup allows me to quickly get my development environment running on any machine, ensuring consistency across my Arch Linux setups.

## 📋 Contents

This repository features configurations for:

### 🔧 Applications & Tools

- **Code** - VS Code settings and preferences.
- **Fish Shell** - Interactive shell with custom configs.
- **Hyprland** - Tiling window manager (Wayland compositor).
- **Waybar** - Status/taskbar for Wayland (includes `wttrbar` for weather).
- **Walker** - Modern application runner/launcher.

### 📦 Installation

The repository includes an automated post-installation script to speed up the setup process:

```bash
sudo bash install.sh
```

This script performs the following actions:
- Full system update (via `yay`).
- **Node.js Environment Setup**: Installs `NVM`, `Node.js` (LTS), and `npm`.
- **VS Code Installation**: Installs `visual-studio-code-bin`.
- **Dotfiles Management**: Installs `GNU Stow` and symlinks configuration files automatically.
- **Extras**: Installs `wttrbar` for weather widgets.

> ⚠️ **Requirement**: Must be run as root.

## 🏗️ Project Structure

```
dotfiles/
├── install.sh          # Post-installation script
├── Code/              # VS Code configurations
│   └── .config/Code/
├── fish/              # Fish Shell configurations
│   └── .config/fish/
├── hypr/              # Hyprland configurations
│   └── .config/hypr/
├── waybar/            # Waybar configurations
│   └── .config/waybar/
└── walker/            # Walker configurations
    └── .config/walker/
```

## 🚀 Usage

### Initial Setup

1. Clone the repository:
```bash
git clone https://github.com/notliad/dotfiles.git
cd dotfiles
```

2. Run the installation script:
```bash
sudo bash install.sh
```

### Manual Configuration Sync

If you prefer to sync configurations manually using `stow` or copying:

```bash
# Symlink specific packages
stow Code waybar hypr fish walker pritunl
```

## 🔨 Features Details

### Hyprland
Modern tiling window manager for Wayland featuring:
- Dynamic workspaces.
- Custom keybindings.
- Personalized themes.

### Fish Shell
Modern shell with:
- Smart autocompletion.
- Syntax highlighting.
- Custom aliases.

### Waybar
Status bar configured with:
- CPU, RAM, and Disk monitors.
- Volume and brightness controls.
- Date/Time display.
- Weather widget integration (`wttrbar`).

### VS Code
Editor setup including:
- Web Development & Node.js environment.
- Auto-formatting.
- Custom themes.

## 👤 Author

**Dailton** - notliad

## 📝 License

This project is provided as-is. Feel free to adapt and customize it for your needs.

## 🤝 Contributions

Suggestions and improvements are welcome! Feel free to open an issue or pull request if you have ideas to enhance the configurations.

---

**Last updated**: January 2026
