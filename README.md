<p align="center">
  <img src="assets/icon.png" alt="Net Bar Icon" width="128" height="128">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License">
</p>

<p align="center">
  <b>A lightweight, aesthetically pleasing network speed monitor for the macOS menu bar.</b>
  <br>
  Real-time download/upload speeds • Detailed diagnostics • Fully customizable
</p>

---

## Overview

Net Bar provides real-time network monitoring directly in your menu bar. It allows users to view download and upload speeds at a glance and access detailed network diagnostics with a single click.

## Features

- **Real-time Monitoring**: View current download and upload speeds in the menu bar.
- **Detailed Statistics**: Access rich diagnostics including Wi-Fi details (SSID, Link Rate, Signal Strength, Noise) and Latency (Ping and Jitter).
- **Customization**:
  - **Typography**: Adjust font size, line spacing, and kerning.
  - **Display Modes**: Choose to show download, upload, or both monitoring stats.
  - **Units**: Switch between Bytes (MB/s) and Bits (Mbps).
  - **Appearance**: Toggle direction arrows and other visual elements.
- **Native Experience**: Built with SwiftUI and AppKit for seamless macOS integration.

## Privacy and Security

Net Bar is fully open source. The application does not collect, store, or transmit any personal data. All network monitoring is performed locally on the device.

### Gatekeeper Warning

As this application is not signed with an Apple Developer certificate, macOS may display a warning stating that the app is "damaged" or "cannot be opened." This is a standard security message for unsigned software.

To resolve this, execute the following command in Terminal after moving the app to the Applications folder:

```bash
xattr -rd com.apple.quarantine /Applications/NetBar.app
```

## Installation

### DMG Installer (Recommended)

1.  Download the latest `NetBar_Installer.dmg` from the [Releases](https://github.com/iad1tya/Net-Bar/releases) page.
2.  Open the mounted image.
3.  Drag `Net Bar.app` into the `Applications` directory.
4.  Run the Gatekeeper command mentioned above if necessary.
5.  Launch Net Bar from the Applications folder.

### Build from Source

To compile the application manually:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/iad1tya/Net-Bar
    cd Net-Bar
    ```

2.  **Build and Install**:
    Run the following script to build and install the application to the Applications folder:

    ```bash
    swift build -c release && \
    rm -rf "Net Bar.app" && \
    BIN_PATH=$(swift build -c release --show-bin-path) && \
    mkdir -p "Net Bar.app/Contents/MacOS" && \
    mkdir -p "Net Bar.app/Contents/Resources" && \
    cp "$BIN_PATH/NetBar" "Net Bar.app/Contents/MacOS/NetBar" && \
    cp Sources/NetSpeedMonitor/Info.plist "Net Bar.app/Contents/Info.plist" && \
    cp Sources/NetSpeedMonitor/Resources/AppIcon.icns "Net Bar.app/Contents/Resources/AppIcon.icns" && \
    cp -r Sources/NetSpeedMonitor/Assets.xcassets "Net Bar.app/Contents/Resources/" && \
    rm -rf "/Applications/Net Bar.app" && \
    mv "Net Bar.app" /Applications/
    ```

## Requirements

- macOS 14.0 (Sonoma) or later.

## Inspiration

The **More Info** page design draws inspiration from [Whyfi](https://whyfi.network/).

## Support

If you find Net Bar useful, please consider supporting its development.

<div align="center">

<a href="https://www.buymeacoffee.com/iad1tya" target="_blank">
  <img src="assets/bmac.png" alt="Buy Me A Coffee" height="50">
</a>

| Currency | Address |
| :--- | :--- |
| **Bitcoin (BTC)** | `bc1qcvyr7eekha8uytmffcvgzf4h7xy7shqzke35fy` |
| **Ethereum (ETH)** | `0x51bc91022E2dCef9974D5db2A0e22d57B360e700` |
| **Solana (SOL)** | `9wjca3EQnEiqzqgy7N5iqS1JGXJiknMQv6zHgL96t94S` |

[Visit Support Website](https://support.iad1tya.cyou)

</div>
