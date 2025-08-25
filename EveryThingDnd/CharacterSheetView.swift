import SwiftUI
import SwiftData

struct CharacterSheetView: View {
    @Bindable var character: Character
    @AppStorage("layoutStyle") private var layoutStyle: String = "2014"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if layoutStyle == "2014" {
                    abilitiesAndSkills2014
                } else {
                    abilitiesAndSkills2024
                }
                combatSection
                featuresSection
            }
            .padding()
        }
        .navigationTitle(character.name)
    }

    // MARK: - Sections
    private var header: some View {
        VStack(alignment: .leading) {
            Text(character.name)
                .font(.largeTitle)
            Text("\(character.className) Level \(character.level)")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var abilitiesAndSkills2014: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                abilitiesColumn
                skillsColumn
            }
        }
    }

    private var abilitiesAndSkills2024: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Ability.allCases) { ability in
                VStack(alignment: .leading) {
                    abilityBlock(for: ability)
                    let related = Skill.allCases.filter { $0.ability == ability }
                    ForEach(related, id: \.self) { skill in
                        skillRow(skill)
                    }
                }
                Divider()
            }
        }
    }

    private var abilitiesColumn: some View {
        VStack(alignment: .leading) {
            ForEach(Ability.allCases) { ability in
                abilityBlock(for: ability)
            }
        }
    }

    private var skillsColumn: some View {
        VStack(alignment: .leading) {
            ForEach(Skill.allCases, id: \.self) { skill in
                skillRow(skill)
            }
        }
    }

    private func abilityBlock(for ability: Ability) -> some View {
        let score = score(for: ability)
        let mod = modifier(for: ability)
        return VStack {
            Text(ability.title)
                .font(.headline)
            Text("\(score)")
                .font(.title)
            Text(mod >= 0 ? "+\(mod)" : "\(mod)")
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke())
    }

    private func skillRow(_ skill: Skill) -> some View {
        let level = character.proficiency(for: skill)
        let mod = modifier(for: skill.ability)
        let profBonus = level == .none ? 0 : character.proficiencyBonus * (level == .expertise ? 2 : 1)
        return HStack {
            if level != .none { Image(systemName: level == .expertise ? "checkmark.seal.fill" : "checkmark") }
            Text(skill.title)
            Spacer()
            Text(String(mod + profBonus))
        }
        .padding(.vertical, 4)
    }

    private var combatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Combat")
                .font(.headline)
            HStack {
                VStack { Text("AC"); Text("\(character.ac)") }
                VStack { Text("Initiative"); Text("\(character.initiative)") }
                VStack { Text("Speed"); Text("\(character.speed)") }
            }
            HStack {
                VStack { Text("Max HP"); Text("\(character.maxHP)") }
                VStack { Text("Current HP"); TextField("", value: $character.currentHP, formatter: NumberFormatter()) }
                VStack { Text("Temp HP"); TextField("", value: $character.tempHP, formatter: NumberFormatter()) }
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Features & Traits")
                .font(.headline)
            TextEditor(text: $character.features)
                .frame(minHeight: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
        }
    }

    // MARK: - Helpers
    private func score(for ability: Ability) -> Int {
        switch ability {
        case .str: return character.str
        case .dex: return character.dex
        case .con: return character.con
        case .int: return character.intScore
        case .wis: return character.wis
        case .cha: return character.cha
        }
    }

    private func modifier(for ability: Ability) -> Int {
        switch ability {
        case .str: return character.strMod
        case .dex: return character.dexMod
        case .con: return character.conMod
        case .int: return character.intMod
        case .wis: return character.wisMod
        case .cha: return character.chaMod
        }
    }
}

#Preview {
    let character = Character(name: "Aragorn", className: "Ranger", level: 5)
    character.skills = Skill.allCases.map { SkillEntry(skill: $0) }
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Character.self, configurations: config)
    
    return CharacterSheetView(character: character)
        .modelContainer(container)
}
