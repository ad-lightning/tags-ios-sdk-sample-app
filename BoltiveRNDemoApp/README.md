# Boltive React Native Demo

A React Native application demonstrating integration with the Boltive SDK for ad blocking and monitoring banner advertisements.

## Prerequisites

Before running this app, ensure you have the following installed:

- **Node.js** (>= 14.x) - [Download here](https://nodejs.org/)
- **React Native CLI** - Install with `npm install -g @react-native-community/cli`
- **Xcode** (for iOS development) - Available on Mac App Store
- **CocoaPods** - Install with `sudo gem install cocoapods`
- **iOS Simulator** or physical iOS device
- **Valid Boltive client ID** - Obtain from Boltive

## Installation & Setup

### 1. Install Dependencies

```bash
# Install npm dependencies
npm install

# Install iOS dependencies
cd ios && pod install && cd ..
```

### 2. Configure Boltive Client ID

Edit `App.js` and replace the placeholder client ID:

```javascript
// Line ~54 in App.tsx
await boltiveSDK.initialize({
    clientId: 'YOUR_BOLTIVE_CLIENT_ID', // Replace this
    adNetwork: BoltiveAdNetwork.GoogleAdManager
});
```

## Running the App

### iOS (Simulator)

```bash
npx react-native run-ios
```

### iOS (Specific Simulator)

```bash
# iPhone 14
npx react-native run-ios --simulator="iPhone 14"

# iPhone 15 Pro
npx react-native run-ios --simulator="iPhone 15 Pro"
```

### iOS (Physical Device)

1. Connect your iOS device via USB
2. Run:
```bash
npx react-native run-ios --device
```

### Alternative: Using Xcode

```bash
# Open the workspace in Xcode
open ios/BoltiveDemo.xcworkspace

# Then build and run from Xcode
```

## Troubleshooting

### Pod Install Issues

```bash
cd ios
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Metro Bundler Issues

```bash
# Reset Metro cache
npx react-native start --reset-cache
```

### Build Errors

```bash
# Clean build
cd ios
xcodebuild clean
cd ..
```