# DBWork

A sample iOS app demonstrating CRUD with [Realm](https://realm.io), rebuilt with
modern **SwiftUI** and the **iOS 27 SDK**.

## Requirements

- Xcode 26+ (iOS 27 SDK)
- Swift 6
- Minimum deployment: iOS 17
- RealmSwift via Swift Package Manager (resolved automatically on first build)

## Getting started

1. Open `DBWork.xcodeproj` in Xcode.
2. Let Xcode resolve the `realm-swift` package (≥ 10.54) on first open.
3. Pick an iPhone simulator and press Run.

No CocoaPods, no storyboards, no extra setup.

## What the app does

A searchable list of people backed by a local Realm database:

- **Create** — tap `+`, enter a name, save. IDs are millisecond timestamps.
- **Update** — tap a row to edit its name.
- **Delete** — swipe to delete, or use Clear All.
- **Search** — filter by name (case- and diacritic-insensitive).

## Project structure

```text
DBWork/
├── DBWorkApp.swift          # @main SwiftUI app entry point
├── Models/
│   └── Person.swift         # Realm Object (@Persisted, primary key)
├── Stores/
│   └── PersonStore.swift    # @Observable CRUD store, value-type snapshots
├── Views/
│   ├── ContentView.swift    # NavigationStack list + search + dialogs
│   └── PersonEditorView.swift # Shared add/edit form sheet
├── Assets.xcassets
└── Info.plist
```

## Modernization notes (v2.0)

Migrated from the 2017 UIKit codebase:

| Before | After |
| --- | --- |
| `AppDelegate` + `Main.storyboard` + `LaunchScreen.storyboard` | `@main` SwiftUI `App`, `UILaunchScreen` |
| `ViewController` with `IBOutlet`/`IBAction` | `NavigationStack`, `List`, sheets, `confirmationDialog` |
| `dynamic var` + `primaryKey()` override (Realm 2.x) | `@Persisted` + `@Persisted(primaryKey:)` |
| `realm.add(_:update: true)`, interpolated `filter("id=…")` | `update: .modified`, primary-key lookup |
| Force-unwrapped `UITextField` input | Validated form state, save disabled when empty |
| CocoaPods (`RealmSwift` 2.6.2, committed `Pods/`) | Swift Package Manager (`realm-swift` ≥ 10.54) |
| Swift 3, iOS 10.3 target | Swift 6 (strict concurrency), iOS 17 minimum |
| Fixed personal Development Team | Automatic signing — set your own team in Xcode |

Views render `PersonItem` snapshots instead of live Realm objects, keeping the
UI concurrency-safe: writes re-resolve objects by primary key inside a write
transaction.
