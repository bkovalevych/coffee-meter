# Coffee Meter App

## Project Overview
Native iOS app to track coffee purchases and show monthly spending with lock screen widget and Apple Watch support.

## Core Requirements
- Manual coffee purchase entry (amount spent)
- Display total monthly spending
- Lock screen widget showing current month total
- Apple Watch companion app
- Local storage only (no backend)
- **Beautiful UI with smooth animations and transitions**

## Tech Stack
- **Language**: Swift
- **UI**: SwiftUI
- **Data**: SwiftData (built on Core Data, uses SQLite under the hood but abstracted)
- **Watch Sync**: WatchConnectivity framework
- **Widgets**: WidgetKit (lock screen + home screen)

## UI/UX Libraries & Resources

### Animation Libraries (SPM - Swift Package Manager)
- **Lottie** (Airbnb): JSON-based animations, huge library at lottiefiles.com
  - `https://github.com/airbnb/lottie-ios`
- **ConfettiSwiftUI**: Celebration effects when adding coffee
  - `https://github.com/simibac/ConfettiSwiftUI`
- **SwiftUI-Shimmer**: Skeleton loading effects
  - `https://github.com/markiv/SwiftUI-Shimmer`

### UI Components
- **SwiftUIX**: Extended SwiftUI components, more controls
  - `https://github.com/SwiftUIX/SwiftUIX`
- **PopupView**: Beautiful modal popups
  - `https://github.com/exyte/PopupView`
- **ActivityIndicatorView**: Elegant loading indicators
  - `https://github.com/exyte/ActivityIndicatorView`

### Charts & Visualization
- **Swift Charts** (Built-in iOS 16+): Native, beautiful charts
- **SwiftUICharts**: Alternative if need more customization
  - `https://github.com/AppPear/ChartView`

### Icons & Images (Free)
- **SF Symbols** (Built-in): 5000+ Apple icons, perfect for coffee cups, money, etc.
- **Unsplash/Pexels**: Free high-quality stock photos
- **Flaticon**: Free icons (SVG export to SF Symbol compatible)

### Color Palettes
- **Coolors.co**: Generate beautiful color schemes
- **iOS Human Interface Guidelines**: System colors that adapt to dark mode

### Design Inspiration
- **Dribbble**: UI patterns for expense tracking apps
- **Mobbin**: Real iOS app screenshot library
- **Apple HIG**: Official design guidelines

## Data Model (SwiftData)
```swift
@Model
class CoffeePurchase {
    var id: UUID
    var amount: Decimal
    var date: Date
    var note: String?
}
```

## Storage
- SwiftData handles persistence automatically
- Data stored in app's container (SQLite backing store managed by framework)
- No manual database setup needed

## Key Features
1. ✅ Add coffee purchase (manual test button)
2. ✅ View monthly total with adaptive font sizing
3. ✅ Budget tracking with progress bar
4. ✅ Settings page (language, currency, budget)
5. ✅ Full localization (English + Ukrainian)
6. ✅ Lock screen widgets (3 types: circular, rectangular, inline)
7. 🔄 View purchase history (planned)
8. 🔄 Monthly summary with chart visualization (placeholder exists)
9. 🔄 Celebration animations (Lottie, Confetti - planned)
10. 🔄 Apple Watch app (WatchConnectivity for sync - planned)
11. ✅ Dark mode support (automatic)

## Architecture
- **iPhone App**: Main UI, data entry, history, settings
  - ContentView: Main screen with monthly total, budget progress
  - SettingsView: Language, currency, budget configuration
  - Theme: Custom color palette (coffee brown, cream, orange accent)
  - LocalizationManager: Runtime language switching
- **Widget Extension**: Lock screen widgets (WidgetKit)
  - Circular: Shows monthly cost with currency symbol
  - Rectangular: Shows cost/budget ratio with progress bar
  - Inline: Single line text format (☕ 450/1000 ₴)
  - Updates hourly, reads from shared SwiftData container
- **Watch App**: View total, quick add (synced via WatchConnectivity) - *planned*

## Development Notes
- User has backend C# experience, learning Swift/iOS
- Focus on best practices and clear code structure
- Use native SwiftUI animations first (springs, easeInOut)
- Fast deployment to TestFlight/App Store

## Widget Setup Instructions

The widget files have been created in `CoffeeMeterWidget/` directory:
- `CoffeeMeterWidget.swift` - Main widget with 3 views (circular, rectangular, inline)
- `CoffeeMeterWidgetBundle.swift` - Widget bundle entry point
- `Info.plist` - Widget extension configuration

**To add the widget to your Xcode project:**

1. In Xcode, go to File → New → Target
2. Select "Widget Extension" template
3. Name it "CoffeeMeterWidget"
4. When prompted, do NOT activate the scheme
5. Delete the auto-generated files in the new `CoffeeMeterWidget` folder
6. Drag the widget files from `CoffeeMeterWidget/` into the widget target in Xcode
7. Make sure to check "Copy items if needed" and add to "CoffeeMeterWidget" target

**Configure App Group for data sharing:**

1. In the main app target capabilities, enable "App Groups"
2. Add a new group: `group.com.yourdomain.coffeemeter`
3. In the widget target capabilities, enable "App Groups"
4. Add the same group: `group.com.yourdomain.coffeemeter`
5. Update SwiftData ModelConfiguration to use the shared container

**Testing the widget:**

1. Build and run the main app
2. Add some coffee purchases to populate data
3. Long-press on the lock screen
4. Tap "Customize"
5. Add the "Coffee Meter" widget
6. Choose circular, rectangular, or inline style

## Recommended Next Additions
1. **Lottie** - coffee cup animation when adding purchase
2. **SF Symbols** - all icons (already using some)
3. **Swift Charts** - monthly spending chart
4. **ConfettiSwiftUI** - celebration when adding coffee
