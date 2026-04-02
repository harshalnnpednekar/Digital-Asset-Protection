# ASTRA — Digital Asset Protection Console

> **Institutional-grade media provenance and real-time piracy enforcement for the next generation of sports broadcasting.**

ASTRA is a high-stakes, enterprise-grade cybersecurity dashboard designed for sports organizations and leagues (e.g., IPL, ISL). It provides a unified "Command & Control" interface to authenticate, monitor, and protect high-value digital assets using cutting-edge cryptographic and neural technologies.

---

## 🛡️ Core Technical Pillars

ASTRA operates on a multi-layered security architecture that ensures content integrity from ingest to delivery.

### 1. Cryptographic Authenticity (C2PA)
Leveraging **C2PA (Coalition for Content Provenance and Authenticity)** protocols, ASTRA attaches tamper-proof cryptographic manifests to every high-value master. This ensures that the history of an asset is verifiable and transparent to all stakeholders.

### 2. Steganographic Watermarking
Invisible, redundant steganographic markers are embedded deep within the pixel data of every asset. Unlike traditional watermarks, these survive aggressive cropping, transcoding, and illegal re-recording, allowing for precise **"Patient Zero"** leak detection.

### 3. Neural Enforcement Engine
Powered by **Gemini AI**, our neural engine differentiates between legitimate fair-use and unauthorized piracy in real-time. It uses semantic matching (Neural CLIP Embeddings) to identify leaked content even when metadata has been stripped.

---

## 🕹️ Operational Interface Modes

ASTRA adapts to the environment of the operator with two distinct visual identities.

### 🌑 Ops Center (Dark Mode)
**Designed for Tactical Monitoring.** High-contrast, monospace-focused interface optimized for low-light "War Room" environments. Focuses on real-time threat detection and active mitigation.

### 📄 Briefing Document (Light Mode)
**Designed for Institutional Reporting.** A "paper-white" sleek corporate aesthetic using cool slate tones and soft diffuse shadows. Optimized for high-level executive review and data analysis.

---

## 📟 Command Modules

### 🏛️ Asset Vault
The primary repository for authenticated masters. View detailed C2PA manifests, technical specifications, and cryptographic health reports for every league asset.

### 📡 Live Threat Radar
A tactical monitoring screen visualizing real-time neural-engine matches across global decentralized vectors. It identifies unauthorized streams and provides one-click enforcement options.

### 📈 Propagation Analysis (Contagion Map)
A graph-theory-based visualization that traces the "Ripple Effect" of unauthorized distribution. It identifies the origin of a leak and maps its viral spread across platforms.

---

## ⚙️ Technical Architecture

- **Core Framework**: Flutter Web (Canvaskit / HTML Renderer optimized)
- **State Management**: `flutter_riverpod` (Reactive infrastructure)
- **Navigation**: `go_router` with `ShellRoute` nested navigation.
- **Animations**: `flutter_animate` for high-impact micro-interactions.
- **Iconography**: `phosphor_flutter` (Institutional/Technical aesthetic).
- **Typography**:
  - **Outfit**: Brand elements and headings.
  - **Inter**: Body text and technical UI elements.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/Digital-Asset-Protection.git
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -d chrome
   ```

### Operational Modes
The application currently operates in **Demo Mode**. Live backend connectors can be configured in `lib/core/config/demo_config.dart`.

---

## ⚖️ License
Internal Use Only. Copyright © 2026 ASTRA. All Rights Reserved.
