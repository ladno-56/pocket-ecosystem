import SwiftUI

@main
struct PocketEcosystemApp: App {
    var body: some Scene {
        WindowGroup {
            GameScreen()
                .preferredColorScheme(.dark)
        }
    }
}
