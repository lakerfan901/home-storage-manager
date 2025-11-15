# iOS App Setup Guide

Complete step-by-step guide to set up and build the Home Storage iOS app.

## Prerequisites

- Mac with macOS (required for Xcode)
- Xcode 14.0 or later
- Apple Developer Account ($99/year)
- iPhone 7 or later (for NFC support)
- Your Next.js backend running and accessible

## Step 1: Create Xcode Project

1. **Open Xcode** and create a new project:
   - File → New → Project
   - Select "iOS" → "App"
   - Click "Next"

2. **Configure Project**:
   - Product Name: `HomeStorage`
   - Team: Select your Apple Developer team
   - Organization Identifier: `com.yourname` (or your domain)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None
   - Include Tests: Optional
   - Click "Next"

3. **Save Location**:
   - Choose where to save the project
   - Click "Create"

## Step 2: Add Source Files

1. **Copy Files**:
   - Copy all files from `ios-app/HomeStorage/` into your Xcode project
   - Maintain the folder structure

2. **Add to Project**:
   - In Xcode, right-click on the project
   - Select "Add Files to HomeStorage..."
   - Navigate to the `ios-app/HomeStorage/` directory
   - Select all folders (App, Models, Services, Views, Components, Utilities)
   - Check "Create groups" (not folder references)
   - Check "Copy items if needed"
   - Make sure "HomeStorage" target is selected
   - Click "Add"

3. **Verify Structure**:
   Your project should now have:
   ```
   HomeStorage
   ├── App
   │   └── HomeStorageApp.swift
   ├── Models
   │   ├── Floor.swift
   │   ├── Room.swift
   │   ├── Box.swift
   │   ├── Item.swift
   │   ├── Stats.swift
   │   └── APIError.swift
   ├── Services
   │   ├── APIService.swift
   │   ├── NFCService.swift
   │   └── ConfigService.swift
   ├── Views
   │   ├── ContentView.swift
   │   ├── Dashboard
   │   ├── Floors
   │   ├── Rooms
   │   ├── Boxes
   │   ├── Items
   │   ├── NFC
   │   └── Settings
   ├── Components
   │   └── (all form components)
   └── Utilities
       ├── Constants.swift
       └── Extensions.swift
   ```

## Step 3: Configure NFC Capability

1. **Select Project**:
   - Click on "HomeStorage" project in navigator
   - Select "HomeStorage" target

2. **Add NFC Capability**:
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability" button
   - Search for "Near Field Communication Tag Reading"
   - Double-click to add it
   - Ensure "NDEF" format is checked

3. **Add Entitlements File**:
   - In the same tab, you should see "Near Field Communication Tag Reading" added
   - If an entitlements file wasn't created automatically:
     - File → New → File
     - Select "Property List"
     - Name it `HomeStorage.entitlements`
     - Add the NFC capability manually (see template)

## Step 4: Configure Info.plist

1. **Open Info.plist**:
   - Find `Info.plist` in your project
   - Right-click → "Open As" → "Source Code"

2. **Add NFC Usage Description**:
   ```xml
   <key>NFCReaderUsageDescription</key>
   <string>This app needs NFC access to read and write NFC tags for box identification.</string>
   ```

3. **Configure App Transport Security** (for local network):
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <false/>
       <key>NSExceptionDomains</key>
       <dict>
           <key>192.168.1.75</key>
           <dict>
               <key>NSExceptionAllowsInsecureHTTPLoads</key>
               <true/>
               <key>NSIncludesSubdomains</key>
               <true/>
           </dict>
       </dict>
   </dict>
   ```
   **Note**: Replace `192.168.1.75` with your actual server IP address.

## Step 5: Update Constants

1. **Open `Constants.swift`**:
   - Find `Utilities/Constants.swift` in your project

2. **Update Base URL**:
   ```swift
   static let defaultBaseURL = "http://192.168.1.75:3000"
   ```
   Replace with your server's IP address.

## Step 6: Apple Developer Setup

### 6.1 Create App ID

1. Go to [developer.apple.com/account](https://developer.apple.com/account/)
2. Navigate to: **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** button
4. Select **App IDs** → Continue
5. Select **App** → Continue
6. Fill in:
   - **Description**: Home Storage Manager
   - **Bundle ID**: `com.yourname.homestorage` (must match your Xcode project)
7. Scroll down to **Capabilities**
8. Check **Near Field Communication Tag Reading**
9. Click **Continue** → **Register**

### 6.2 Register Your Device

1. Connect your iPhone to your Mac
2. Open **Xcode** → **Window** → **Devices and Simulators**
3. Select your iPhone
4. Copy the **Identifier** (UDID) - it's a long string
5. Go to [developer.apple.com/account](https://developer.apple.com/account/)
6. Navigate to: **Certificates, Identifiers & Profiles** → **Devices**
7. Click **+** button
8. Enter:
   - **Name**: Your iPhone name
   - **UDID**: Paste the identifier you copied
9. Click **Continue** → **Register**

### 6.3 Create Provisioning Profile

1. In Apple Developer Portal, go to **Profiles**
2. Click **+** button
3. Select **Ad Hoc** → Continue
4. Select your **App ID** (the one you created) → Continue
5. Select your **Certificate** → Continue
6. Select your **Device(s)** → Continue
7. Enter **Profile Name**: `HomeStorage Ad Hoc`
8. Click **Generate** → **Download**
9. Double-click the downloaded `.mobileprovision` file to install it

### 6.4 Configure Code Signing in Xcode

1. In Xcode, select your project
2. Select **HomeStorage** target
3. Go to **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Select your **Team**
6. Xcode should automatically select your provisioning profile

## Step 7: Build and Run

1. **Connect iPhone**:
   - Connect your iPhone to Mac via USB
   - Unlock your iPhone
   - Trust the computer if prompted

2. **Select Device**:
   - In Xcode toolbar, select your iPhone from device dropdown

3. **Build and Run**:
   - Click the **Play** button (⌘R)
   - Or go to **Product** → **Run**

4. **Trust Developer** (First Time Only):
   - On your iPhone, go to **Settings** → **General** → **VPN & Device Management**
   - Tap on your developer certificate
   - Tap **Trust**

## Step 8: Configure App Settings

1. **Launch the app** on your iPhone
2. **Go to Settings tab**
3. **Update API Base URL** if needed:
   - Enter your server IP: `http://192.168.1.75:3000`
   - Tap "Save"

## Step 9: Test NFC Functionality

1. **Test Reading**:
   - Go to Dashboard
   - Tap "Scan NFC"
   - Hold iPhone near an NFC tag
   - Should read tag and lookup box

2. **Test Writing**:
   - Create a new box
   - Scan NFC tag during creation
   - Or use NFC Write view to write to tag

## Troubleshooting

### Build Errors

**Error: "No such module 'CoreNFC'"**
- Solution: Ensure you're building for a physical device, not simulator
- NFC doesn't work in iOS Simulator

**Error: "Signing for HomeStorage requires a development team"**
- Solution: Select your team in Signing & Capabilities

**Error: "Provisioning profile doesn't match"**
- Solution: Ensure bundle ID matches App ID in developer portal

### Runtime Errors

**NFC not working**
- Check device supports NFC (iPhone 7+)
- Verify NFC capability is enabled
- Check Info.plist has NFCReaderUsageDescription
- Ensure running on physical device (not simulator)

**API connection fails**
- Verify server is running
- Check API URL in Settings
- Ensure iPhone and server are on same network
- Check App Transport Security settings

**"Box not found" after NFC scan**
- Verify box exists in database with that NFC tag ID
- Check API endpoint `/api/boxes?nfc_tag_id=xxx` works in browser

## Next Steps

1. Test all CRUD operations
2. Test NFC reading and writing
3. Customize UI if desired
4. Add additional features as needed

## Distribution Options

### Option 1: Direct Install (Ad-Hoc)
- Build and install directly via Xcode
- Works for up to 100 devices
- Requires device UDID registration

### Option 2: TestFlight (Internal)
- Upload to App Store Connect
- Distribute via TestFlight app
- No device limit for internal testing
- Valid for 90 days per build

### Option 3: Enterprise Distribution
- Requires Enterprise Developer account ($299/year)
- No device limit
- No expiration

## Support

For issues or questions:
- Check the main project README
- Review API documentation
- Check Xcode console for error messages

