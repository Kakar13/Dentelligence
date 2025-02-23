//
//  HackAI2025.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import SwiftData


// MARK: - App Entry Point
@main
struct HackAI2025: App {
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Patient.self, Treatment.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(container)
    }
}
