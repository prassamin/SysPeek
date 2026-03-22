# CHANGELOG

## [v1.3.0] - 2026-03-23

- **Custom Settings Window**: Replaced the default KDE Plasma config dialog with a fully custom frameless dark-themed window featuring sidebar navigation and custom window controls.
  - **6 Settings Pages**: General, Layout, Typography, Colors, Alerts, and About — each in its own dedicated page file.
  - **Custom Controls**: Hand-crafted toggle switches, spin boxes with keyboard editing and scroll-wheel support, gauge-style sliders with shimmer animations, combo boxes with edge-safe dropdowns, and color swatches.
  - **About Page**: Dynamically reads app name, version, description, author, license, and links from `Plasmoid.metaData` — no hardcoded values.
  - **Modular Architecture**: Extracted all UI components into a reusable `components/` folder with a shared `Theme` singleton, and all pages into a `pages/` folder for maintainability.
- **Desktop Widget Background**: The widget now renders a native KDE Plasma background frame (`KSvg.FrameSvgItem`) when placed directly on the desktop instead of a panel.
  - **Configurable Opacity**: Added a slider to the settings menu to adjust the opacity of this desktop background (from 0% to 100%).
- **Flexible Widget Dimensions**: Added a "Use Fixed Width" toggle in settings. The widget can now intelligently resize its width perfectly to its varying content, or stick strictly to a user-defined fixed width.
- **Improved Adaptive Layout**: The internal spacing logic now seamlessly adapts its bounds and mouse-click areas dynamically depending on whether the widget is placed in a thin Plasma panel or directly on the desktop screen.
- **Data Formatting Customization**: Users can now select from 4 distinct auto-scaling formatting strategies for network speeds (`KB, MB, GB, TB`, `B, KB, MB, GB, TB`, `Kbps, Mbps, Gbps, Tbps`, and `bps, Kbps, Mbps, Gbps, Tbps`).
  - Bit-rate formats (`bps`, `Kbps`, etc.) rigorously apply auto-scaling thresholds against their underlying Byte boundaries to mathematically prevent premature "Kilo" jumps (e.g. 188 Bytes/sec correctly displays as `1504 bps` without jumping to `1.5 Kbps`).

## [v1.2.0] - 2026-03-10

- **Added Comprehensive Color Customization** ([#4](https://github.com/PRASSamin/SysPeek/issues/4))
  - Support for overriding standard Kirigami colors with custom user-defined widgets colors.
  - Introduced **Dynamic Thresholding**: Configure distinct warning and critical thresholds (with custom highlight colors) for CPU, RAM, Swap (%), and Network speeds (MB/s).
- **Icon Size Scaling**: Icon sizes now scale proportionally with the selected font size setting.
- **Icon Coloring**: Icons now automatically inherit the chosen custom UI and dynamic threshold colors alongside the text.
- **Fixed Font Scaling**: Switched from `pixelSize` to `pointSize` so font size settings scale properly on high-DPI displays and across varying Plasma environments.

## [v1.1.0] - 2026-02-06

- Configuration Options ([#1](https://github.com/PRASSamin/SysPeek/issues/1)):
  - **Visibility**: Toggle individual monitors (CPU, RAM, Swap, Upload, Download)
  - **Dimensions**: Configurable widget width (100-800px)
  - **Spacing & Padding**: Item spacing, icon-label spacing, horizontal/vertical padding
  - **Typography**: Font size (6-48px) and font family selection

- Stability Improvements ([#3](https://github.com/PRASSamin/SysPeek/issues/3)):
  - Network speed values now always display in KB format to prevent label width jumping

## [v1.0.0] - 2025-07-27

- Resource Monitoring:
  - CPU usage display.
  - Memory usage display.
  - Swap usage display.
  - Network download/upload speed display.
