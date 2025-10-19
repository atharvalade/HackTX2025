# API Key Setup Instructions

## 🔐 Secure API Key Configuration

To keep your API keys secure and out of version control, follow these steps:

### Option 1: Using APIKeys.plist (Recommended for Production)

1. **Create APIKeys.plist file:**
   - In Xcode, right-click on the **"Toyota Financial Services"** folder
   - Select **"New File..."**
   - Choose **"Property List"**
   - Name it exactly: `APIKeys.plist`
   - Make sure it's added to your target

2. **Add your API key:**
   - Open `APIKeys.plist`
   - Add a new row with:
     - Key: `GEMINI_API_KEY`
     - Type: `String`
     - Value: `AIzaSyC-x0w8MdwBzfVDVnHhD7683G48HTh5oUk` (or your key)

3. **Verify .gitignore:**
   - The `.gitignore` file already includes `APIKeys.plist`
   - This ensures your API key won't be committed to git

### Option 2: Using Info.plist (Quick Development Setup)

For quick development, you can add the key to Info.plist:

1. Open your `Info.plist` file
2. Add a new entry:
   - Key: `GEMINI_API_KEY`
   - Value: `AIzaSyC-x0w8MdwBzfVDVnHhD7683G48HTh5oUk` (or your key)

⚠️ **Warning:** This method is less secure. Never commit this to a public repository.

### How It Works

The app will look for the API key in this order:
1. First: `APIKeys.plist` (gitignored, secure)
2. Fallback: `Info.plist` (for development)

### Testing the Integration

1. Build and run the app
2. Navigate to the Location Permission screen
3. Tap "Enable Location"
4. The app will:
   - Request location permission
   - Get your current location
   - Extract the ZIP code
   - Call Gemini API to get county and tax info
   - Display the results

### Troubleshooting

**"API key not configured" error:**
- Make sure `APIKeys.plist` exists and is added to your target
- Verify the key name is exactly `GEMINI_API_KEY`
- Check that your API key is valid

**Location not updating:**
- Make sure you've added location permissions to Info.plist
- Check that location services are enabled on your device/simulator

**Network errors:**
- Verify your internet connection
- Check that the Gemini API key is active
- Make sure you've enabled network permissions (they're allowed by default)

### For Team Development

Each team member should:
1. Copy `APIKeys.plist.example` to `APIKeys.plist`
2. Add their own API key to `APIKeys.plist`
3. Never commit `APIKeys.plist` to version control

The `.gitignore` file will prevent accidental commits of the API key.

