//
//  HackAI2025App.swift
//  HackAI2025
//
//  Created by Mihir Joshi on 2/22/25.
//

<<<<<<< HEAD
//import SwiftUI
//import SwiftData
//
//@main
//struct HackAI2025App: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}
=======
import SwiftUI
import SwiftData

@main
struct HackAI2025App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
//            ContentView()
            TestUI()
        }
        .modelContainer(sharedModelContainer)
    }
}
>>>>>>> 3683b45185150a68ac07d24713d0d84928997f38
