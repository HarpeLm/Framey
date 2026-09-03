import SwiftUI
import SwiftData

@main
struct FrameyApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MediaItemEntity.self,
            WatchedEntry.self,
            WatchlistEntry.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            FilmsView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
