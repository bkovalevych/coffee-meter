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
1. Add coffee purchase (amount + optional note) - **with celebration animation**
2. View purchase history (list with smooth transitions)
3. Monthly summary with chart visualization
4. Lock screen widget (iOS WidgetKit)
5. Apple Watch app (WatchConnectivity for sync)
6. Dark mode support (automatic)

## Architecture
- **iPhone App**: Main UI, data entry, history
- **Widget Extension**: Read-only access to SwiftData, shows monthly total
- **Watch App**: View total, quick add (synced via WatchConnectivity)

## Development Notes
- User has backend C# experience, learning Swift/iOS
- Focus on best practices and clear code structure
- Use native SwiftUI animations first (springs, easeInOut)
- Fast deployment to TestFlight/App Store

## Recommended First Additions
1. **Lottie** - coffee cup animation when adding purchase
2. **SF Symbols** - all icons (no extra library needed)
3. **Swift Charts** - monthly spending chart
4. **ConfettiSwiftUI** - celebration when adding coffee
