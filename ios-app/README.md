# Home Storage Manager - iOS App

Native iOS app for the Home Storage Management system with full NFC tag reading and writing support.

## Features

- **NFC Tag Reading**: Scan NFC tags to quickly find boxes
- **NFC Tag Writing**: Write box information to NFC tags
- **Full CRUD Operations**: Create, read, update, delete for floors, rooms, boxes, and items
- **Search & Filter**: Search boxes/items, filter by tags
- **Native iOS Experience**: Built with SwiftUI for optimal iOS performance

## Requirements

- **iOS**: 15.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **Device**: iPhone 7 or later (for NFC support)
- **Apple Developer Account**: Required for ad-hoc distribution

## Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. Create a new project:
   - Choose "iOS" → "App"
   - Product Name: `HomeStorage`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum iOS: 15.0

### 2. Add Files to Project

1. Copy all files from `ios-app/HomeStorage/` into your Xcode project
2. Maintain the folder structure:
   - App/
   - Models/
   - Services/
   - Views/
   - Components/
   - Utilities/
   - Resources/

### 3. Configure NFC Capability

1. Select your project in Xcode
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Near Field Communication Tag Reading"
5. Enable "NDEF" format

### 4. Configure Info.plist

1. Open `Info.plist` in your project
2. Add the following keys (or merge with the template):
   - `NFCReaderUsageDescription`: "This app needs NFC access to read and write NFC tags for box identification."
   - `NSAppTransportSecurity`: Configure for your local network (see template)

### 5. Configure Entitlements

1. Add `HomeStorage.entitlements` file to your project
2. In project settings, set "Code Signing Entitlements" to `HomeStorage.entitlements`

### 6. Update API Base URL

1. Open `Constants.swift`
2. Update `defaultBaseURL` to match your server IP:
   ```swift
   static let defaultBaseURL = "http://192.168.1.75:3000"
   ```
3. Or configure it in Settings after first launch

## Apple Developer Setup

### 1. Create App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Certificates, Identifiers & Profiles → Identifiers
3. Click "+" to create new App ID
4. Select "App" type
5. Bundle ID: `com.yourname.homestorage` (or your choice)
6. Enable "Near Field Communication Tag Reading" capability
7. Register the App ID

### 2. Create Provisioning Profile

1. Certificates, Identifiers & Profiles → Profiles
2. Click "+" to create new profile
3. Select "Ad Hoc" distribution
4. Select your App ID
5. Select your development certificate
6. Select your device(s) UDID
7. Download and install the profile

### 3. Register Device UDID

1. Connect your iPhone to Mac
2. Open Xcode → Window → Devices and Simulators
3. Select your device
4. Copy the Identifier (UDID)
5. Add it to your provisioning profile

### 4. Configure Code Signing

1. In Xcode project settings
2. Select your target
3. Go to "Signing & Capabilities"
4. Select your Team
5. Select the provisioning profile you created

## Building and Installing

### Via Xcode

1. Connect your iPhone to your Mac
2. Select your device in Xcode
3. Click "Run" (⌘R)
4. Trust the developer certificate on your iPhone (Settings → General → VPN & Device Management)

### Via TestFlight (Internal Testing)

1. Archive your app in Xcode (Product → Archive)
2. Upload to App Store Connect
3. Add internal testers
4. Install via TestFlight app

## API Endpoints

The app connects to your Next.js backend at the configured base URL. All endpoints match the web app:

- `GET /api/stats` - Dashboard statistics
- `GET /api/floors` - List all floors
- `GET /api/floors/{id}` - Floor details with rooms
- `GET /api/rooms` - List all rooms
- `GET /api/rooms/{id}` - Room details with boxes
- `POST /api/rooms` - Create room
- `PATCH /api/rooms/{id}` - Update room
- `DELETE /api/rooms/{id}` - Delete room
- `GET /api/boxes` - List all boxes
- `GET /api/boxes?nfc_tag_id={id}` - Lookup box by NFC tag
- `GET /api/boxes/{id}` - Box details with items
- `POST /api/boxes` - Create box
- `PATCH /api/boxes/{id}` - Update box
- `DELETE /api/boxes/{id}` - Delete box
- `GET /api/items` - List all items
- `GET /api/items/{id}` - Item details
- `POST /api/items` - Create item
- `PATCH /api/items/{id}` - Update item
- `DELETE /api/items/{id}` - Delete item

## NFC Functionality

### Reading NFC Tags

1. Tap "Scan NFC" button
2. Hold iPhone near NFC tag
3. App reads tag identifier
4. Automatically looks up box in database
5. Navigate to box details if found

### Writing NFC Tags

1. When creating a new box, scan NFC tag
2. Or use NFC Write view to write box ID to tag
3. Hold iPhone near writable NFC tag
4. App writes tag identifier to tag

## Troubleshooting

### NFC Not Working

- Ensure device supports NFC (iPhone 7+)
- Check NFC capability is enabled in project
- Verify Info.plist has NFCReaderUsageDescription
- Make sure entitlements file is configured

### API Connection Issues

- Verify server is running and accessible
- Check API base URL in Settings
- Ensure local network access is allowed
- Check App Transport Security settings in Info.plist

### Build Errors

- Ensure all Swift files are added to target
- Check that minimum iOS version is 15.0+
- Verify all imports are correct
- Check for missing dependencies

## Project Structure

```
HomeStorage/
├── App/
│   └── HomeStorageApp.swift
├── Models/
│   ├── Floor.swift
│   ├── Room.swift
│   ├── Box.swift
│   ├── Item.swift
│   ├── Stats.swift
│   └── APIError.swift
├── Services/
│   ├── APIService.swift
│   ├── NFCService.swift
│   └── ConfigService.swift
├── Views/
│   ├── ContentView.swift
│   ├── Dashboard/
│   ├── Floors/
│   ├── Rooms/
│   ├── Boxes/
│   ├── Items/
│   ├── NFC/
│   └── Settings/
├── Components/
│   ├── AddRoomForm.swift
│   ├── EditRoomForm.swift
│   ├── AddBoxForm.swift
│   ├── EditBoxForm.swift
│   ├── AddItemForm.swift
│   └── EditItemForm.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

## License

MIT License - Same as main project

