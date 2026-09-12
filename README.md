# Flanki 🎴

[![Release](https://img.shields.io/github/v/release/zoroneo/flanki?display_name=tag&style=flat-square)](https://github.com/zoroneo/flanki/releases)
[![Build & Release](https://github.com/zoroneo/flanki/actions/workflows/release.yml/badge.svg)](https://github.com/zoroneo/flanki/actions/workflows/release.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&style=flat-square)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

**Flanki** is a modern, high-performance, cross-platform spaced repetition flashcard application built with Flutter. Designed for seamless learning across Desktop (Windows, macOS, Linux) and Mobile (Android), Flanki combines modern UI aesthetics with powerful memory algorithms (FSRS v5 and SM-2) and seamless synchronization.

---

## ✨ Features

- 🧠 **Next-Gen Spaced Repetition**: Native implementation of the cutting-edge **FSRS v5** (Free Spaced Repetition Scheduler) algorithm alongside classic **SM-2**.
- ☁️ **Anki Ecosystem Compatible**: Seamlessly import/export `.apkg` packages and sync flashcards, media, and progress with **AnkiWeb**.
- 🎨 **Modern Minimalist UI**: Beautifully styled with `shadcn_flutter` and `lucide_icons_flutter`, supporting both dark and light modes.
- 🔊 **Rich Multimedia**: Full audio playback support for pronunciation and listening exercises, with integrated media caching.
- 🖥️ **Desktop Native Integration**:
  - System tray minimization and quick controls (`tray_manager`).
  - Global hotkeys and custom window controls (`window_manager`).
  - Auto-start on boot (`launch_at_startup`).
- 🔄 **Integrated Auto-Updates**:
  - Direct GitHub Releases distribution with background check & one-click in-app update.
  - Native installer triggers: Inno Setup executable (`.exe`) on Windows, disk image (`.dmg`) on macOS, bundle (`.tar.gz`) on Linux, and native `FileProvider` package installer on Android (`.apk`).
- ⚡ **Local-First & Offline Ready**: Powered by **Drift (SQLite)** for sub-millisecond local queries and full offline capability.

---

## 📥 Downloads & Installation

Get the latest release for your platform from [GitHub Releases](https://github.com/zoroneo/flanki/releases/latest):

| Platform | Format | Download Link | Notes |
| :--- | :--- | :--- | :--- |
| **Windows** | Setup Installer (`.exe`) | [flanki-setup-windows.exe](https://github.com/zoroneo/flanki/releases/latest/download/flanki-setup-windows.exe) | Standard installer with start menu & desktop shortcut |
| **Windows** | Portable (`.zip`) | [flanki-windows-x64.zip](https://github.com/zoroneo/flanki/releases/latest/download/flanki-windows-x64.zip) | Extract and run `flanki.exe` directly |
| **macOS** | Portable (`.zip`) | [flanki-macos.zip](https://github.com/zoroneo/flanki/releases/latest/download/flanki-macos.zip) | Extract `flanki.app` and drag to Applications |
| **Linux** | Tarball (`.tar.gz`) | [flanki-linux.tar.gz](https://github.com/zoroneo/flanki/releases/latest/download/flanki-linux.tar.gz) | Extract and run `./flanki` |
| **Android** | Sideload APK (`.apk`) | [flanki-android.apk](https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk) | Direct install on Android phones/tablets |

### 📱 Quick Install on Android (Scan to Download)

Scan this QR code with your phone camera to download and install the latest `flanki-android.apk` directly:

<div align="center">
  <a href="https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk">
    <img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk" alt="Scan QR Code to Download Android APK" width="220" height="220" />
  </a>
  <p><sub><b>Direct Link:</b> <a href="https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk">https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk</a></sub></p>
</div>

> [!TIP]
> **macOS Note**: Since Flanki is an open-source app distributed outside the App Store without an Apple Developer ID, macOS Gatekeeper may show *"macOS cannot verify that this app is free from malware"*.
> - **Option 1 (GUI)**: Go to **System Settings** > **Privacy & Security** > scroll to **Security** and click **Open Anyway**. Alternatively, right-click `Flanki.app` in Finder and select **Open**.
> - **Option 2 (Terminal)**: Run `xattr -cr /Applications/Flanki.app` to remove the quarantine flag.

---

## 🏗️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── config/             # App & version configuration (AppConfig)
│   ├── database/           # Drift SQLite schema, DAOs, and migrations
│   ├── models/             # Data models (Decks, Cards, Reviews, Updates)
│   ├── notifiers/          # Riverpod state management & async notifiers
│   ├── services/           # Sync, FSRS scheduler, audio, update services
│   └── storage/            # Secure key-value storage & media cache
├── l10n/                   # Internationalization (English, Vietnamese)
└── ui/
    ├── screens/            # Decks, Study, Review, Card Editor, Settings
    └── widgets/            # Reusable UI components, modals, dialogs
```

- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.13.2 / Flutter 3.47.2 via FVM)
- **State Management**: [Riverpod](https://riverpod.dev) (`hooks_riverpod`, `flutter_hooks`)
- **Database**: [Drift](https://drift.simonbinder.eu) (SQLite) with WAL mode & encryption support
- **SRS Scheduling**: [FSRS](https://github.com/open-spaced-repetition/fsrs) v5 & SM-2
- **Networking**: `http` with standard REST & GitHub API integration
- **Packaging**: Inno Setup (Windows), Gradle (Android), CPack / Tarball (Linux)

---

## 💻 Developer Setup

### Prerequisites

- [FVM (Flutter Version Management)](https://fvm.app/) installed.
- Git, CMake, and C++ compiler for desktop development:
  - **Windows**: Visual Studio 2022 with C++ Desktop Workload + [Inno Setup 6](https://jrsoftware.org/isinfo.php).
  - **macOS**: Xcode 15+ & CocoaPods.
  - **Linux (Ubuntu/Debian)**:
    ```bash
    sudo apt-get update && sudo apt-get install -y clang cmake ninja-build pkg-config \
      libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
      libsecret-1-dev libjsoncpp-dev libayatana-appindicator3-dev
    ```
  - **Android**: JDK 17 & Android SDK (API 34+).

### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/zoroneo/flanki.git
cd flanki

# 2. Install pinned Flutter SDK via FVM
fvm install
fvm flutter pub get

# 3. Generate drift & localization code
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter gen-l10n

# 4. Run application
fvm flutter run -d windows    # For Windows
fvm flutter run -d macos      # For macOS
fvm flutter run -d linux      # For Linux
fvm flutter run -d android    # For Android
```

---

## 🚀 CI / CD Workflow

Releases are fully automated via GitHub Actions on every tag push matching `v*.*.*`:

1. **Parallel Build Matrix**:
   - `build-windows`: Builds 64-bit release, creates portable `.zip`, and compiles Inno Setup `.exe`.
   - `build-macos`: Builds macOS release bundle and packages `.zip`.
   - `build-linux`: Installs required system headers (`gstreamer`, `appindicator`, `libsecret`), builds release binary and packages `.tar.gz`.
   - `build-android`: Builds release APK and renames to `flanki-android.apk`.
2. **Publish Release**:
   - Aggregates all 5 platform artifacts.
   - Automatically generates changelog from commit messages.
   - Publishes GitHub Release marked with the corresponding tag.

To release a new version:
```bash
# Bump version in pubspec.yaml and lib/core/config/app_config.dart
git commit -am "chore: bump version to v1.0.2"
git tag v1.0.2
git push origin main --tags
```

---

## ⚖️ Disclaimer

Flanki is an independent, open-source project and is not affiliated with, endorsed by, or sponsored by Ankitects Pty Ltd or the official Anki project. "Anki" and "AnkiWeb" are registered trademarks of Ankitects Pty Ltd.

---

## 🔒 Privacy Policy

We value your privacy. Flanki is local-first and does not track or collect personal analytics. Read our complete [Privacy Policy](PRIVACY_POLICY.md) for details.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



