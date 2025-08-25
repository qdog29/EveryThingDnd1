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

    @State private var selection: Character?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(characters) { character in
                    HStack {
                        Text(character.name)
                        Spacer()
                        if selection?.id == character.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .tag(character as Character?)
                }
                .onDelete(perform: deleteCharacters)
                Button(action: addCharacter) {
                    Label("New Character", systemImage: "plus")
                }
            }
        } detail: {
            if let character = selection {
                TabView {
                    CharacterSheetView(character: character)
                        .tabItem { Label("Sheet", systemImage: "person.text.rectangle") }
                    RollsView(character: character)
                        .tabItem { Label("Roll", systemImage: "dice") }
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gear") }
                }
            } else {
                Text("Select a character")
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            selectedCharacterName = newValue?.name
        }
        .onAppear {
            if let stored = selectedCharacterName,
               let existing = characters.first(where: { $0.name == stored }) {
                selection = existing
            }
        }
    }

    private func addCharacter() {
        withAnimation {
            let newCharacter = Character()
            modelContext.insert(newCharacter)
            selection = newCharacter
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
