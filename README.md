<p align="center">
  <img src="assets/icon.png" alt="Net Bar Icon" width="128" height="128">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License">
</p>

<p align="center">
  <b>A lightweight, aesthetically pleasing network speed monitor that lives in your macOS menu bar.</b>
  <br>
  Real-time download/upload speeds • Detailed diagnostics • Fully customizable
</p>

---

## 🚀 Features

- **Real-time Monitoring**: View current download and upload speeds directly in your menu bar.
- **Detailed Stats**: Click the menu bar icon to see rich diagnostics:
  - **Wi-Fi Details**: SSID, Link Rate, Signal Strength, and Noise graphs.
  - **Latency**: Continuous Ping and Jitter monitoring to your router and the internet (1.1.1.1).
- **Customizable**:
  - **Typography**: Adjust font size, line spacing, and kerning.
  - **Display Modes**: Show download, upload, or both.
  - **Units**: Switch between Bytes (MB/s) and Bits (Mbps).
  - **Appearance**: Toggle direction arrows and more.
- **Native Experience**: Built with SwiftUI and AppKit for seamless macOS integration.

## 🔒 Safety & Privacy

**Net Bar is 100% Open Source and Safe.**

This application does **not** collect, store, or transmit any of your personal data. All network monitoring happens locally on your machine. You can verify this by checking the source code in this repository.

### "App is Damaged" Warning?
You might see a warning saying *"Net Bar is damaged and can't be opened"* or *"can't be opened because Apple cannot check it for malicious software"*.

**Why?**
This happens because I am an independent developer and do not have a paid Apple Developer Program membership ($99/year). Therefore, I cannot "sign" the app with an Apple certificate. **The app is not actually damaged.**

**The Solution:**
You can easily fix this by running a simple terminal command. See the installation instructions below.

## 📥 Installation

### Option 1: DMG Installer (Recommended)

1.  **Download** the latest `NetBar_Installer.dmg` from the [Releases](https://github.com/iad1tya/Net-Bar/releases) page.
2.  **Open** the `.dmg` file.
3.  **Drag** `Net Bar.app` into the `Applications` folder.
4.  **Important**: If you see a warning that the app is "damaged", it is because it is not signed. Run this command in Terminal to fix it:
    ```bash
    xattr -rd com.apple.quarantine /Applications/NetBar.app
    ```
5.  Launch **Net Bar** from your Applications folder.

### Option 2: Build from Source

If you prefer to compile it yourself:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/iad1tya/Net-Bar
    cd Net-Bar
    ```

2.  **Build and Install**:
    Run the following command to build and install to Applications:

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

## 💻 Requirements

- macOS 14.0 (Sonoma) or later.

## ❤️ Support

If you enjoy **Net Bar**, please consider supporting the development!

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
