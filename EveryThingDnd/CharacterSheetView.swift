import SwiftUI
import SwiftData

struct CharacterSheetView: View {
    @Bindable var character: Character

    // MARK: - Temporary placeholders for fields not yet in your model
    @State private var playerName = ""
    @State private var backgroundText = ""
    @State private var raceText = ""
    @State private var alignmentText = ""
    @State private var experiencePoints = ""
    @State private var inspirationOn = false

    // Right-column narrative boxes
    @State private var personality = ""
    @State private var ideals = ""
    @State private var bonds = ""
    @State private var flaws = ""

    // Combat details
    @State private var hitDiceTotal = ""
    @State private var deathSaveSuccesses = 0
    @State private var deathSaveFailures = 0

    // Attacks & Spellcasting (placeholder rows)
    struct AttackRow: Identifiable {
        let id = UUID()
        var name = ""
        var atkBonus = ""
        var damage = ""
    }
    @State private var attacks: [AttackRow] = [.init(), .init(), .init()]

    // Equipment + coins
    @State private var equipmentText = ""
    @State private var cp = ""
    @State private var sp = ""
    @State private var ep = ""
    @State private var gp = ""
    @State private var pp = ""

    // iOS 15 fallback
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                header
                threeColumnContent
            }
            .padding()
            .padding(.bottom, 40) // keeps last editors above keyboard
        }
        .navigationTitle(character.name)
    }

    // MARK: - Header (banner rows)
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Character Name", text: $character.name)
                .font(.largeTitle).fontWeight(.bold)

            // Row 1: Class & Level | Background | Player Name
            HStack(spacing: 12) {
                SheetBox("CLASS & LEVEL") {
                    Text("\(character.className) • Level \(character.level)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                SheetBox("BACKGROUND") { TextField("—", text: $backgroundText) }
                SheetBox("PLAYER NAME") { TextField("—", text: $playerName) }
            }

            // Row 2: Race | Alignment | Experience Points
            HStack(spacing: 12) {
                SheetBox("RACE") { TextField("—", text: $raceText) }
                SheetBox("ALIGNMENT") { TextField("—", text: $alignmentText) }
                SheetBox("EXPERIENCE POINTS") { TextField("—", text: $experiencePoints) }
            }
        }
    }

    // MARK: - Three-column content (no GeometryReader; scroll-safe)
    private var threeColumnContent: some View {
        Group {
            if #available(iOS 16.0, *) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        leftColumn
                        centerColumn
                        rightColumn
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        leftColumn
                        centerColumn
                        rightColumn
                    }
                }
            } else {
                // iOS 15 fallback: use size class
                if hSizeClass == .compact {
                    VStack(alignment: .leading, spacing: 16) {
                        leftColumn
                        centerColumn
                        rightColumn
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        leftColumn
                        centerColumn
                        rightColumn
                    }
                }
            }
        }
    }

    // MARK: - LEFT COLUMN
    private var leftColumn: some View {
        VStack(spacing: 12) {
            // Inspiration & PB
            HStack(spacing: 12) {
                SheetBox("INSPIRATION") {
                    Toggle("", isOn: $inspirationOn)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                SheetBox("PROFICIENCY BONUS") {
                    Text("+\(character.proficiencyBonus)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Ability blocks
            ForEach(Ability.allCases) { ability in
                abilityBlock(for: ability)
            }

            // Saving Throws (auto from ability proficiency/expertise)
            SheetBox("SAVING THROWS") {
                VStack(spacing: 6) {
                    ForEach(Ability.allCases) { ability in
                        let level = character.abilityProficiency(for: ability)
                        let mod = modifier(for: ability)
                        let pb = character.proficiencyBonus
                        let profBonus = level == .none ? 0 : pb * (level == .expertise ? 2 : 1)

                        HStack {
                            Picker("", selection: abilityProfBinding(for: ability)) {
                                Text("None").tag(ProficiencyLevel.none)
                                Text("Prof.").tag(ProficiencyLevel.proficient)
                                Text("Expert.").tag(ProficiencyLevel.expertise)
                            }
                            .pickerStyle(.menu)
                            Text(ability.title)
                            Spacer()
                            Text(mod >= 0 ? "+\(mod + profBonus)" : "\(mod + profBonus)")
                                .monospacedDigit()
                        }
                    }
                }
            }

            // Skills
            SheetBox("SKILLS") {
                VStack(spacing: 4) {
                    ForEach(Skill.allCases, id: \.self) { skill in
                        skillRow(skill)
                    }
                }
            }

            // Passive Perception
            SheetBox("PASSIVE WISDOM (PERCEPTION)") {
                Text("\(passivePerception)")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Other Proficiencies & Languages (placeholder)
            SheetBox("OTHER PROFICIENCIES & LANGUAGES") {
                TextEditor(text: .constant(""))
                    .frame(minHeight: 100)
                    .disabled(true)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
                    .overlay(alignment: .topLeading) {
                        Text("Placeholder")
                            .foregroundStyle(.secondary).padding(8)
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - CENTER COLUMN
    private var centerColumn: some View {
        VStack(spacing: 12) {
            // AC | Initiative | Speed
            HStack(spacing: 12) {
                StatPill("ARMOR CLASS", value: "\(character.ac)")
                StatPill("INITIATIVE", value: "\(character.initiative)")
                StatPill("SPEED", value: "\(character.speed)")
            }

            // HP block
            SheetBox("") {
                VStack(spacing: 10) {
                    LabeledValueRow(label: "Hit Point Maximum") {
                        Text("\(character.maxHP)")
                    }
                    Divider()
                    LabeledValueRow(label: "CURRENT HIT POINTS") {
                        TextField("—", value: $character.currentHP, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    LabeledValueRow(label: "TEMPORARY HIT POINTS") {
                        TextField("—", value: $character.tempHP, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                }
            }

            // Hit Dice & Death Saves
            HStack(spacing: 12) {
                SheetBox("HIT DICE (Total)") {
                    TextField("—", text: $hitDiceTotal)
                        .keyboardType(.default)
                }
                SheetBox("DEATH SAVES") {
                    VStack(alignment: .leading, spacing: 8) {
                        CounterRow(title: "Successes", value: $deathSaveSuccesses)
                        CounterRow(title: "Failures", value: $deathSaveFailures)
                    }
                }
            }

            // Attacks & Spellcasting (placeholder)
            SheetBox("ATTACKS & SPELLCASTING") {
                VStack(spacing: 8) {
                    HStack {
                        Text("Name").font(.subheadline).bold()
                        Spacer()
                        Text("Atk Bonus").font(.subheadline).bold()
                            .frame(width: 90, alignment: .trailing)
                        Text("Damage/Type").font(.subheadline).bold()
                            .frame(width: 130, alignment: .trailing)
                    }
                    ForEach($attacks) { $row in
                        HStack(spacing: 8) {
                            TextField("—", text: $row.name)
                            TextField("—", text: $row.atkBonus)
                                .frame(width: 90, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                            TextField("—", text: $row.damage)
                                .frame(width: 130, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                        }
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }

            // Equipment + coins
            SheetBox("EQUIPMENT") {
                VStack(spacing: 12) {
                    TextEditor(text: $equipmentText)
                        .frame(minHeight: 120)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))

                    HStack(spacing: 8) {
                        CoinField("CP", text: $cp)
                        CoinField("SP", text: $sp)
                        CoinField("EP", text: $ep)
                        CoinField("GP", text: $gp)
                        CoinField("PP", text: $pp)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - RIGHT COLUMN
    private var rightColumn: some View {
        VStack(spacing: 12) {
            SheetBox("PERSONALITY TRAITS") { PlaceholderEditor(text: $personality) }
            SheetBox("IDEALS") { PlaceholderEditor(text: $ideals) }
            SheetBox("BONDS") { PlaceholderEditor(text: $bonds) }
            SheetBox("FLAWS") { PlaceholderEditor(text: $flaws) }

            SheetBox("FEATURES & TRAITS") {
                TextEditor(text: $character.features)
                    .frame(minHeight: 200)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - Helpers (bindings & calculations)

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
        Binding(
            get: { character.abilityProficiency(for: ability) },
            set: { character.setAbilityProficiency($0, for: ability) }
        )
    }

    private func skillBinding(for skill: Skill) -> Binding<ProficiencyLevel> {
        Binding(
            get: { character.proficiency(for: skill) },
            set: { character.setProficiency($0, for: skill) }
        )
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
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }

    // Passive Perception = 10 + Wis mod + Perception proficiency (incl. expertise)
    private var passivePerception: Int {
        let wis = modifier(for: .wis)
        let pb = character.proficiencyBonus
        let perception = Skill.allCases.first { $0.title.lowercased() == "perception" }
        let level = perception.map { character.proficiency(for: $0) } ?? .none
        let prof = level == .none ? 0 : pb * (level == .expertise ? 2 : 1)
        return 10 + wis + prof
    }
}

// MARK: - Reusable views

private struct SheetBox<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.4), lineWidth: 1)
        )
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }
    var body: some View {
        SheetBox(title) {
            Text(value)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct LabeledValueRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
    }
}

private struct CounterRow: View {
    let title: String
    @Binding var value: Int
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Stepper(value: $value, in: 0...3) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .strokeBorder(index < value ? Color.primary : .secondary.opacity(0.4), lineWidth: 1)
                            .background(Circle().fill(index < value ? Color.primary.opacity(0.15) : .clear))
                            .frame(width: 18, height: 18)
                    }
                }
            }
            .labelsHidden()
        }
    }
}

private struct CoinField: View {
    let label: String
    @Binding var text: String
    init(_ label: String, text: Binding<String>) {
        self.label = label
        self._text = text
    }
    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField("—", text: $text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 64)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PlaceholderEditor: View {
    @Binding var text: String
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
            if text.isEmpty {
                Text("Placeholder")
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }
}

// MARK: - Ability block (reusing your style)
extension CharacterSheetView {
    private func abilityBlock(for ability: Ability) -> some View {
        let mod = modifier(for: ability)
        return VStack {
            Text(ability.title).font(.headline)
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
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.4)))
    }
}

// MARK: - Preview
#Preview {
    let character = Character(name: "Aragorn", className: "Ranger", level: 5)
    character.skills = Skill.allCases.map { SkillEntry(skill: $0) }
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Character.self, configurations: config)

    return CharacterSheetView(character: character)
        .modelContainer(container)
}
