//
//  ContentView.swift
//  EveryThingDnd
//
//  Created by Quinlan Taylor on 2025-08-24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Character.name) private var characters: [Character]
    @SceneStorage("selectedCharacterName") private var selectedCharacterName: String?

    @State private var selection: SidebarItem?

    enum SidebarItem: Hashable {
        case character(Character)
        case rolls
        case settings
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Characters") {
                    ForEach(characters) { character in
                        NavigationLink(value: SidebarItem.character(character)) {
                            Text(character.name)
                        }
                    }
                    .onDelete(perform: deleteCharacters)
                    Button(action: addCharacter) {
                        Label("New Character", systemImage: "plus")
                    }
                }
                Section {
                    NavigationLink(value: SidebarItem.rolls) {
                        Label("Rolls", systemImage: "dice")
                    }
                    NavigationLink(value: SidebarItem.settings) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        } detail: {
            switch selection {
            case .character(let character):
                CharacterSheetView(character: character)
            case .rolls:
                RollsView(character: selectedCharacter)
            case .settings:
                SettingsView()
            default:
                Text("Select a character")
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if case .character(let c) = newValue {
                selectedCharacterName = c.name
            }
        }
        .onAppear {
            if let stored = selectedCharacterName,
               let existing = characters.first(where: { $0.name == stored }) {
                selection = .character(existing)
            }
        }
    }

    private var selectedCharacter: Character? {
        if case .character(let c) = selection {
            return c
        }
        if let name = selectedCharacterName {
            return characters.first(where: { $0.name == name })
        }
        return nil
    }

    private func addCharacter() {
        withAnimation {
            let newCharacter = Character()
            modelContext.insert(newCharacter)
            selection = .character(newCharacter)
        }
    }

    private func deleteCharacters(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(characters[index])
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Character.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
