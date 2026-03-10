# CHANGELOG

## [v1.2.0] - 2026-03-10

- **Added Color Customization** ([#4](https://github.com/PRASSamin/SysPeek/issues/4))
  - Support for overriding standard Kirigami colors with custom user-defined widgets colors.
  - Introduced **Dynamic Thresholding**: Configure distinct warning and critical thresholds (with custom highlight colors) for CPU, RAM, Swap (%), and Network speeds (MB/s).

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
