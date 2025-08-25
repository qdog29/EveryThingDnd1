import SwiftUI
import SwiftData

struct CharacterSheetView: View {
    @Bindable var character: Character

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                abilitiesAndSkills
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

    private var abilitiesAndSkills: some View {
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

    private func abilityBlock(for ability: Ability) -> some View {
        let mod = modifier(for: ability)
        return VStack {
            Text(ability.title)
                .font(.headline)
            TextField("", value: scoreBinding(for: ability), formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
            Text(mod >= 0 ? "+\(mod)" : "\(mod)")
                .font(.subheadline)
            Picker("Proficiency", selection: abilityProfBinding(for: ability)) {
                Text("None").tag(ProficiencyLevel.none)
                Text("Proficient").tag(ProficiencyLevel.proficient)
                Text("Expertise").tag(ProficiencyLevel.expertise)
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke())
    }

    private func skillRow(_ skill: Skill) -> some View {
        let binding = skillBinding(for: skill)
        let level = binding.wrappedValue
        let mod = modifier(for: skill.ability)
        let profBonus = level == .none ? 0 : character.proficiencyBonus * (level == .expertise ? 2 : 1)
        return HStack {
            Picker("", selection: binding) {
                Text("None").tag(ProficiencyLevel.none)
                Text("Proficient").tag(ProficiencyLevel.proficient)
                Text("Expertise").tag(ProficiencyLevel.expertise)
            }
            .pickerStyle(.menu)
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
    private func scoreBinding(for ability: Ability) -> Binding<Int> {
        switch ability {
        case .str: return $character.str
        case .dex: return $character.dex
        case .con: return $character.con
        case .int: return $character.intScore
        case .wis: return $character.wis
        case .cha: return $character.cha
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

    private func abilityProfBinding(for ability: Ability) -> Binding<ProficiencyLevel> {
        Binding(get: { character.abilityProficiency(for: ability) },
                set: { character.setAbilityProficiency($0, for: ability) })
    }

    private func skillBinding(for skill: Skill) -> Binding<ProficiencyLevel> {
        Binding(get: { character.proficiency(for: skill) },
                set: { character.setProficiency($0, for: skill) })
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
