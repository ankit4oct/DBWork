import SwiftUI

/// Modern SwiftUI app entry point.
///
/// Replaces the legacy UIKit `AppDelegate` + `Main.storyboard` bootstrap with
/// the SwiftUI `App` protocol (`@main`). No storyboards, no
/// `UIApplicationMain`, no scene delegate — the window is managed by SwiftUI.
@main
struct DBWorkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
