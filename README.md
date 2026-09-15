<div align="center">

# SysPeek

**A sleek, lightweight, and deeply customizable system monitor plasmoid for KDE Plasma 6.**

Keep an eye on your system's vital signs with a clean, compact, and jitter-free layout on your panel or desktop.

[![KDE Plasma 6](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-3daee9?logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![License](https://img.shields.io/badge/License-GPL%202.0-blue.svg)](LICENSE.md)
[![Pling Store](https://img.shields.io/badge/Pling-Download-orange.svg)](https://www.pling.com/p/2304482/)


<a href="https://www.pras.me/donate" target="_blank"><img src="https://iili.io/JoQcIJS.md.png" alt="Buy Me A Coffee" height="100" /></a>


![SysPeek Preview](demo.png)

</div>

---

## Highlights

- **Comprehensive System Monitoring:** Tracks CPU, GPU, VRAM, RAM, Swap, CPU/GPU temperatures, network upload/download speeds, and system uptime in real time.
- **Parallel GPU Scanner & dGPU Prioritization:** Centralized multi-probe detection automatically discovers and prioritizes dedicated graphics cards over integrated GPUs.
- **Drag-and-Drop Layout Builder:** Arrange and group monitors in multi-row and multi-column grid layouts to save vertical panel space.
- **Dynamic Conditions & Color Alerts:** Set human-friendly warning and critical thresholds with context-aware units (`%`, `MB/s`, `KB/s`, `GB`, `MB`, `°C`, `°F`, `h`, etc.).
- **Anti-Jitter Fixed Sizing:** Reserves fixed label widths based on maximum value hints with configurable text alignment (Left, Center, Right) to eliminate panel jitter.
- **Sensor Explorer:** Browse and bind any hardware sensor from the KSysGuard sensor tree (e.g. AMD Ryzen `Tccd1`/`Tdie` sensors, disk metrics, custom probes).
- **Per-Module Display Formatting:** Toggle between percentage and raw formatted bytes (`GB`/`MB`) for RAM, Swap, and VRAM; choose auto-scaling speed units (`B/s`, `KB/s`, `MB/s`, `bps`, `Mbps`); switch temperature units between `°C` and `°F`.
- **System Theme Adaptive:** Default module colors automatically adapt to your desktop color scheme for perfect legibility on both dark and light themes.
- **Lightweight & Efficient:** Selective sensor subscriptions ensure unplaced monitors consume zero background CPU or D-Bus resources.
- **Configurable Click Actions:** Launch applications (with a searchable system app chooser), execute terminal commands, or open URLs on left-click.

---

## Installation

### Method 1: KDE Applet Store (Recommended)

1. Right-click on your KDE Plasma panel or desktop and select **Add Widgets...**
2. Click **Get New Widgets...** &rarr; **Download New Plasma Widgets**
3. Search for **SysPeek**
4. Click **Install**, then drag **SysPeek** onto your panel or desktop.

### Method 2: Pling / KDE Store

1. Download the latest `.plasmoid` package from the [SysPeek Pling Page](https://www.pling.com/p/2304482/).
2. Right-click your panel or desktop &rarr; **Add Widgets...** &rarr; **Install from Local File...**
3. Select the downloaded `.plasmoid` file to install.

### Method 3: From Source (Command Line)

```bash
git clone https://github.com/PRASSamin/SysPeek.git
cd SysPeek
kpackagetool6 -t Plasma/Applet -i .
```

To update an existing installation from source:

```bash
kpackagetool6 -t Plasma/Applet -u .
```

---

## Built with Prasmoid

SysPeek was developed and structured using [**Prasmoid**](https://github.com/PRASSamin/prasmoid) — a CLI tool designed to simplify and streamline KDE Plasma plasmoid development.

---

## Contributing & Bug Reports

Contributions, feature suggestions, and bug reports are warmly welcome!

- Found a bug or have a suggestion? Open an issue on the [GitHub Issues page](https://github.com/PRASSamin/SysPeek/issues).
- Want to contribute code? Fork the repository, create a branch, and open a pull request.

---

## License

This project is open source and licensed under the [GNU General Public License v2.0](LICENSE.md).
