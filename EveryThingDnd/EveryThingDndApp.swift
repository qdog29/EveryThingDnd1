//
//  EveryThingDndApp.swift
//  EveryThingDnd
//
//  Created by Quinlan Taylor on 2025-08-24.
//

import SwiftUI
import SwiftData

@main
struct EveryThingDndApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(DnDSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
