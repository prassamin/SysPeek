# CHANGELOG

## [v2.1.0] - 2026-09-15

### Added
- **Human-Friendly Condition Units & Evaluation Engine** ([#12](https://github.com/prassamin/SysPeek/issues/12)):
  - Added context-aware unit dropdowns next to threshold inputs in the condition editor (`%`, `MB/s`, `KB/s`, `GB`, `MB`, `°C`, `°F`, `s`, `m`, `h`, `d`, etc.).
  - Implemented automatic runtime conversion of human-readable values to raw sensor units.
  - Added dual-value evaluation for memory modules (`RAM`, `SWAP`, `VRAM`), supporting threshold comparisons against both percentage and raw byte totals.
  - Full backwards compatibility with automatic migration of legacy byte thresholds (e.g., `1048576` to `1 MB/s`).
- **Parallel GPU Scanner & Dedicated GPU Prioritization** ([#12](https://github.com/prassamin/SysPeek/issues/12), [#16](https://github.com/prassamin/SysPeek/issues/16)):
  - Centralized multi-probe GPU scanner scanning `gpu0` through `gpu8` simultaneously.
  - Automatically identifies and prioritizes dedicated GPUs (dGPU) over integrated graphics (iGPU) for temperature, usage, and VRAM.
- **Built-in VRAM Module**:
  - Restored full VRAM monitoring support integrated with auto-detected GPU prefix.
  - Configurable display mode toggle between **Percentage** (`%`) and **Value** (`GB/MB`).
  - Integrated into Live Preview Card and Placement Page grid layout builder.
- **Sensor Explorer Overrides for Built-in Modules** ([#18](https://github.com/prassamin/SysPeek/issues/18)):
  - Built-in modules (CPU, GPU, RAM, Swap, Temp, etc.) now support custom Sensor ID overrides via the interactive Sensor Explorer tree.
- **Fixed Value Label Width & Text Alignment** ([#11](https://github.com/prassamin/SysPeek/issues/11), [#13](https://github.com/prassamin/SysPeek/issues/13), [#17](https://github.com/prassamin/SysPeek/pull/17)):
  - Anti-jitter fixed label width reservations utilizing `TextMetrics` and dynamic width hints (`100%`, total memory size, network speed format, 3-digit uptime).
  - Configurable text alignment settings (**Left**, **Center**, **Right**) under Layout settings.
  - Configurable extra width padding (`fixedLabelWidthExtra`) to fine-tune spacing between modules.
- **New Distinct GPU Icon** ([#11](https://github.com/prassamin/SysPeek/issues/11)):
  - Replaced the generic chip silhouette with a dedicated graphics card design featuring PCIe bracket, card shroud, and cooling fans.

### Changed
- **System Theme Color Support**:
  - Module colors set to default white or "system" now dynamically follow the active desktop color scheme (`Kirigami.Theme.textColor`), ensuring high contrast and legibility on both dark and light desktop themes.
- **Placement Builder Refinements**:
  - Streamlined module placement and drag-and-drop tiles in the layout builder to prevent layout collapse and simplify custom module organization.

### Performance
- **Selective Sensor Subscriptions & Reduced Polling** ([#15](https://github.com/prassamin/SysPeek/issues/15)):
  - Inactive modules that are not placed on the panel now automatically unsubscribe from sensor polling (`enabled: isModuleActive(...)`), drastically reducing background CPU and D-Bus usage.
  - Applied `updateRateLimit: 1000` to background temperature and usage probe sensors during GPU device scanning.

### Fixed
- **VRAM and Outgrowing Label Stability**: Sized VRAM width hint dynamically from total VRAM, and allowed the reserved label slot to expand smoothly without jitter for outgrowing labels.
- **Dynamic Network Speed Width Hints**: Network speed width hints now update reactively whenever the speed format or unit changes.
- **QML Lint & Binding Errors**: Cleaned up binding loops, undefined property accesses, and invalid string coercions across all settings pages.

## [v2.0.0] - 2026-05-20

### Added
- **Unified Module Architecture**: Completely refactored the core monitoring engine to treat built-in and custom modules identically.
- **Deep Customization for Built-in Modules**: Users can now override icons, labels, and base colors for every default system sensor (CPU, GPU, RAM, etc.).
- **Per-Module Data Formatting**:
  - **RAM & Swap**: Moved display mode settings from General Page to the individual module customization dialog, allowing independent selection between "Percentage" and "Value" (GB/MB) for each monitor.
  - **Temperature**: Unit switching between Celsius (°C) and Fahrenheit (°F) per module.
  - **Network Speed**: Per-module unit overrides for the global network speed setting.
- **Live Preview System**: Added a real-time preview card to the module customization dialog that shows exactly how a monitor will look (including live data and dynamic conditions) before saving.
- **Modern UI Overhaul**:
  - Replaced legacy dropdowns with high-performance **Segmented Option Switchers** for a modern, web-like experience.
  - Integrated professional **Interactive Color Swatches** and system-standard color picker dialogs.
  - Replaced text/emoji-based icons with high-quality SVG icons from the KDE system theme.
- **DnD Placement System** ([#6](https://github.com/prassamin/SysPeek/issues/6)): A highly customizable Drag-and-Drop builder to group and arrange system monitors in any grid layout, enabling space-saving vertical groupings.

### Fixed
- **Mathematical Bit-Rate Conversion** ([#9](https://github.com/prassamin/SysPeek/issues/9)): Network speed formatting now correctly multiplies byte values by 8 when bit-based units (Kbps, Mbps, etc.) are selected.
- **QML Stability**: Fixed several "Index out of range" and "Undefined property" errors in the settings UI.
- **Path Resolution**: Resolved issues with relative icon paths failing to load in certain UI contexts.

### Removed
- Removed legacy global threshold settings (`Usage Above`, `Speed Color`, etc.) in favor of the more powerful and flexible per-module Dynamic Conditions system.

## [v1.4.0] - 2026-05-17

### Added

- **GPU Monitoring** ([#6](https://github.com/prassamin/SysPeek/issues/6)): Introduced a new GPU usage counter that tracks aggregate GPU load across all detected hardware using KDE's system statistics daemon.
- **Value-Based Display Mode** ([#6](https://github.com/prassamin/SysPeek/issues/6)): RAM and Swap monitors now support a configurable display mode, allowing users to switch between traditional percentage-based usage and formatted raw byte values (e.g., 4.5 GB). This can be toggled independently for each counter in the "Data Format" settings.
- **Global Icon Toggle**: Added an option in the "Layout" settings to hide icons globally, enabling a more compact, text-only appearance.
- **GPU Color Customization**: Full support for custom coloring and dynamic thresholding (Warning/Critical) for the new GPU monitor.
- **Configurable Click Actions**: Left click now supports 4 action types — Launch Application, Open URL, Run Command, or Do Nothing. Each action type preserves its own input value independently when switching between types.
  - **Application Picker**: A built-in app chooser dialog scans all installed applications (including Flatpak and Snap) and presents them in a searchable list with icons for quick selection.
- **Premium Tooltips**: Replaced plain default tooltips with gorgeous, glassmorphic dark-theme card tooltips for all monitor items.

### Fixed

- **Dropdown Z-Order**: Custom combo box dropdowns now render above all other content by reparenting to the window root, preventing options from being obscured by sibling elements.

## [v1.3.0] - 2026-03-23

- **Custom Settings Window**: Replaced the default KDE Plasma config dialog with a fully custom frameless dark-themed window featuring sidebar navigation and custom window controls.
  - **6 Settings Pages**: General, Layout, Typography, Colors, Alerts, and About — each in its own dedicated page file.
  - **Custom Controls**: Hand-crafted toggle switches, spin boxes with keyboard editing and scroll-wheel support, gauge-style sliders with shimmer animations, combo boxes with edge-safe dropdowns, and color swatches.
  - **About Page**: Dynamically reads app name, version, description, author, license, and links from `Plasmoid.metaData` — no hardcoded values.
  - **Modular Architecture**: Extracted all UI components into a reusable `components/` folder with a shared `Theme` singleton, and all pages into a `pages/` folder for maintainability.
- **Desktop Widget Background**: The widget now renders a native KDE Plasma background frame (`KSvg.FrameSvgItem`) when placed directly on the desktop instead of a panel.
  - **Configurable Opacity**: Added a slider to the settings menu to adjust the opacity of this desktop background (from 0% to 100%).
- **Flexible Widget Dimensions**: Added a "Use Fixed Width" toggle in settings. The widget can now intelligently resize its width perfectly to its varying content, or stick strictly to a user-defined fixed width.
- **Improved Adaptive Layout**: The internal spacing logic now adapts its bounds and mouse-click areas dynamically depending on whether the widget is placed in a thin Plasma panel or directly on the desktop screen.
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
