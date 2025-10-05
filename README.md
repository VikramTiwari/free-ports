# Port Manager - macOS Menu Bar App

A lightweight Swift-based macOS menu bar application that allows you to view all open ports on your system and kill processes running on those ports directly from your menu bar.

## Features

- **Menu Bar Integration**: Simple "P" icon in your Mac's top status bar
- **Port Scanning**: Scans and displays all open ports using `lsof`
- **Grouped by Service**: Services with multiple ports get submenus, single ports show directly
- **Perfect Alignment**: Right-aligned port numbers for easy scanning
- **One-Click Process Management**: Kill processes with a single click (no confirmation needed)
- **Manual Refresh**: Refresh ports when needed
- **Memory Optimized**: Minimal memory usage with optimized parsing
- **Single Instance**: Only one instance can run at a time

## Requirements

- macOS 14.0 or later
- Swift 5.0 or later

## Quick Start

### Option 1: Download Pre-built App (Recommended)
1. **Go to [Releases](https://github.com/vikramtiwari/free-ports/releases)**
2. **Download** the latest `PortManager.pkg` (App Store ready)
3. **Double-click** to install
4. **Run** the app and look for "P" in menu bar

**Alternative Direct Installation:**
1. **Download** `PortManager.zip` instead
2. **Extract** and drag `PortManager.app` to Applications
3. **Right-click** on the app and select "Open" (to bypass security warnings)
4. **Run** the app and look for "P" in menu bar

## 🏪 Mac App Store Distribution Setup

### Required GitHub Secrets

To enable automated App Store releases, add these secrets to your GitHub repository:

**Go to**: Repository → Settings → Secrets and variables → Actions

#### App Store Connect API
```
APPSTORE_API_KEY_ID: [10-character Key ID from App Store Connect]
APPSTORE_API_ISSUER_ID: [UUID Issuer ID from App Store Connect]
APPSTORE_API_KEY_BASE64: [Base64 encoded .p8 file]
```

**Find these at**: https://appstoreconnect.apple.com/ → Users and Access → Keys → App Store Connect API

#### Certificates
```
CERTIFICATE_APP_BASE64: [Base64 encoded Mac App Distribution .p12]
CERTIFICATE_INSTALLER_BASE64: [Base64 encoded Mac Installer Distribution .p12]
CERTIFICATE_PASSWORD: [Password for .p12 files]
```

**Create certificates at**: https://developer.apple.com/account/resources/certificates/list
- Select "Mac App Distribution" 
- Select "Mac Installer Distribution"

#### App Store Connect
```
APPLE_ID: [Your Apple ID email]
APPLE_ID_PASSWORD: [App-specific password from appleid.apple.com]
TEAM_ID: [10-character Team ID from developer.apple.com/account/#!/membership/]
APP_IDENTIFIER: com.portmanager.app
```

### Certificate Export Process
1. **Export from Keychain Access** as .p12 files
2. **Convert to base64**:
   ```bash
   base64 -i MacAppDistribution.p12 -o cert_app.txt
   base64 -i MacInstallerDistribution.p12 -o cert_installer.txt
   ```
3. **Copy contents** to GitHub secrets

### Option 2: Run from Source (Development)
```bash
# Clone or download this repository
git clone <repository-url>
cd free-ports

# Run the app
swift run PortManager

# Look for the "P" icon in your Mac's top menu bar
```

## How It Works

### Menu Bar Interface
- **Simple Icon**: "P" icon appears in your Mac's top status bar
- **Dropdown Menu**: Click the icon to see all open ports
- **Grouped Services**: Services are organized with port counts
- **Perfect Alignment**: Port numbers are right-aligned for easy scanning

### Menu Structure
```
Port Manager
─────────────
1 - node →
├── node                    5173
─────────────
2 - ControlCenter →
├── ControlCenter           5000
└── ControlCenter           7000
─────────────
Refresh
Quit Port Manager
```

### Process Management
1. **Click on any port** in the menu
2. **Process is killed immediately** (no confirmation needed)
3. **Port list refreshes** automatically
4. **Silent operation** - no notifications

## Distribution

### Automatic Releases
- **GitHub Actions** automatically build and create releases
- **Pre-built apps** available in the [Releases](https://github.com/vikramtiwari/free-ports/releases) section
- **Cross-platform** support (Intel + Apple Silicon)
- **Versioned releases** with proper app bundle metadata

## Sharing with Friends

### What to Share
- **File**: `PortManager.app` (the entire folder)
- **Size**: ~150KB (very lightweight!)
- **Requirements**: macOS 14.0+

### How Friends Install It
1. **Download** the `PortManager.app` file
2. **Drag** it to their Applications folder
3. **Double-click** to run it
4. **Look for "P"** in the menu bar

### First-Time Security Warning
Friends may see a security warning the first time they run it:
- **Right-click** on `PortManager.app`
- **Select "Open"**
- **Click "Open"** in the security dialog
- **Future launches** will work normally

## Technical Details

- **Port Scanning**: Uses `lsof` command-line tool for accurate port information
- **Process Killing**: Uses the `kill` command to terminate processes
- **Menu Bar**: Built with NSStatusItem for native macOS integration
- **Memory Optimized**: Uses efficient string parsing and minimal memory allocation
- **Single Instance**: Prevents multiple instances from running simultaneously
- **Built with**: Swift Package Manager
- **Target**: macOS 14.0+
- **Architecture**: Universal (Intel + Apple Silicon)
- **Size**: ~150KB
- **Memory usage**: ~2-5MB when idle

## Memory Optimization

- **Simple text icon** instead of complex graphics
- **Optimized string parsing** with efficient algorithms
- **Limited service display** (10 services max)
- **No auto-refresh timer** - manual refresh only
- **Silent operations** - no notification overhead

## Security Note

This app requires appropriate permissions to:
- Read system process information
- Kill processes
- Access network information

The app uses standard macOS APIs and follows security best practices.

## Troubleshooting

### General Issues
- **No menu bar icon**: Make sure the app is running
- **No ports shown**: Ensure you have processes running that use network ports
- **Can't kill process**: Some system processes may require administrator privileges
- **App not starting**: Check that you have the required macOS version and Swift installed

### Distribution Issues

#### "App can't be opened because it's from an unidentified developer"
**Solution**: Right-click → Open → Open

#### "App is damaged and can't be opened"
**Solution**: 
1. Right-click → Open → Open
2. Or run: `xattr -cr PortManager.app`

#### "Apple could not verify this app is free of malware"
**Solution**: 
1. Right-click → Open → Open (in the new dialog)
2. Or go to System Preferences → Security & Privacy → General → Click "Open Anyway"
3. Or run: `xattr -d com.apple.quarantine PortManager.app`

#### App doesn't appear in menu bar
**Solution**: 
1. Check Applications folder
2. Try running from Terminal: `open /Applications/PortManager.app`
3. Check Activity Monitor for "PortManager" process

## Project Structure

```
free-ports/
├── Package.swift              # Swift Package Manager configuration
├── README.md                  # This guide
├── LICENSE                    # MIT License
├── CONTRIBUTING.md           # Contributing guidelines
├── .github/
│   └── workflows/
│       └── release.yml       # GitHub Actions for releases
└── Sources/
    └── PortManager/
        └── main.swift        # Main application code
```

## Releases

### Creating a Release
1. **Create and push a tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **GitHub Actions automatically:**
   - Builds the app
   - Creates app bundle with proper metadata
   - Generates distribution zip
   - Creates GitHub release with download

### Release Process
- **Tag-based releases**: Push a tag like `v1.0.0`
- **Automatic building**: GitHub Actions handles everything
- **No local setup needed**: Just push tags to trigger releases

## Building from Source

### Swift Package Manager
```bash
# Clone the repository
git clone <repository-url>
cd free-ports

# Build the project
swift build

# Run the app
swift run PortManager

# Build for release
swift build -c release
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Clone your fork
3. Make your changes
4. Test with `swift run PortManager`
5. Submit a pull request

## Benefits of This Approach

### For Development:
- ✅ **Fast development** with Swift Package Manager
- ✅ **No Xcode project complexity**
- ✅ **Easy to modify and test**
- ✅ **Simple build process**

### For Distribution:
- ✅ **Automatic releases** via GitHub Actions
- ✅ **Lightweight** (~150KB)
- ✅ **Easy installation** for users
- ✅ **Works on all macOS versions**
- ✅ **No local build setup required**

## License

This project is open source and available under the MIT License.

---

**Enjoy managing your ports from the menu bar!** 🚀