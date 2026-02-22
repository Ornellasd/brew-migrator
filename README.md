# 🍺 Brew-Migrator

A lightweight Bash utility to identify "drag-and-drop" macOS applications and migrate them to **Homebrew Cask** management.

## 🚀 Why use this?
Manually installing apps by dragging them into `/Applications` makes them hard to update. By moving them to Homebrew, you can update every app on your system with a single command: `brew upgrade`.

## ✨ Features
- **Smart Scanning**: Compares your `/Applications` folder against the Homebrew Cask database.
- **Interactive Menu**: Choose specific apps to convert using numbers (e.g., `1 3 5`) or convert all at once.
- **Force Takeover**: Uses `--force` to let Homebrew take control of existing `.app` bundles without losing your settings.
- **Auto-Manifest**: Automatically updates a `~/.Brewfile` so you can replicate your setup on any Mac.
