import SwiftUI
import SwiftData

// MARK: - Simple list item model (view-local)
private struct ListItem: Identifiable, Hashable {
    let id = UUID()
    var text: String = ""
}

struct CharacterSheetView: View {
    @Bindable var character: Character

    // MARK: - Temporary placeholders for fields not yet in your model
    @State private var playerName = ""
    @State private var backgroundText = ""
    @State private var raceText = ""
    @State private var alignmentText = ""
    @State private var experiencePoints = ""
    @State private var inspirationOn = false

    // Right-column narrative sections now as arrays
    @State private var personalityItems: [ListItem] = [.init()]
    @State private var idealsItems: [ListItem]      = [.init()]
    @State private var bondsItems: [ListItem]       = [.init()]
    @State private var flawsItems: [ListItem]       = [.init()]

    // Features/traits, proficiencies/languages, and equipment as arrays
    @State private var featuresItems: [ListItem]    = [.init()]
    @State private var profLangItems: [ListItem]    = [.init()]
    @State private var equipmentItems: [ListItem]   = [.init()]

    // Collapse toggles for the new list sections
    @State private var showPersonality = true
    @State private var showIdeals      = true
    @State private var showBonds       = true
    @State private var showFlaws       = true
    @State private var showFeatures    = true
    @State private var showProfLang    = true
    @State private var showEquipment   = true

    // Combat details
    @State private var hitDiceTotal = ""
    @State private var deathSaveSuccesses = 0
    @State private var deathSaveFailures = 0

    // MARK: - Multi-classing
    struct ClassLevel: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var level: Int
    }
    @State private var classes: [ClassLevel] = []
    @State private var showClasses = false

    // MARK: - Attacks & Spellcasting
    struct AttackRow: Identifiable, Hashable {
        let id = UUID()
        var name = ""
        var atkBonus = ""
        var damage = ""
    }
    @State private var attacks: [AttackRow] = [.init(), .init(), .init()]
    @State private var showAttacks = true

    // Equipment coins (kept as-is)
    @State private var cp = ""
    @State private var sp = ""
    @State private var ep = ""
    @State private var gp = ""
    @State private var pp = ""

    // iOS 15 fallback
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private func ensureSeededClasses() {
        if classes.isEmpty {
            classes = [ClassLevel(name: character.className.isEmpty ? "Class" : character.className,
                                  level: max(1, character.level))]
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                header
                threeColumnContent
            }
            .padding()
            .padding(.bottom, 40)
            .onAppear { ensureSeededClasses() }
        }
        .navigationTitle(character.name)
    }

    // MARK: - Header (unchanged from your version)
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Character Name", text: $character.name)
                .font(.largeTitle).fontWeight(.bold)

            // Row 1
            HStack(spacing: 12) {
                SheetBox("CLASS & LEVEL") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                showClasses.toggle()
                            }
                        } label: {
                            HStack {
                                Text(classSummary)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: showClasses ? "chevron.up" : "chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        if showClasses {
                            VStack(spacing: 8) {
                                ForEach($classes) { $cls in
                                    HStack(spacing: 8) {
                                        TextField("Class", text: $cls.name)
                                            .textFieldStyle(.roundedBorder)
                                        Stepper(value: $cls.level, in: 1...20) {
                                            Text("Lvl \(cls.level)")
                                                .frame(width: 64, alignment: .trailing)
                                        }
                                        Button(role: .destructive) {
                                            withAnimation { classes.removeAll { $0.id == cls.id } }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .disabled(classes.count == 1)
                                        .help("Remove class")
                                    }
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation {
                            classes.append(.init(name: "Class", level: 1))
                            showClasses = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(8)
                    .help("Add class")
                }

                SheetBox("BACKGROUND") { TextField("—", text: $backgroundText) }
                SheetBox("PLAYER NAME") { TextField("—", text: $playerName) }
            }

            // Row 2
            HStack(spacing: 12) {
                SheetBox("RACE") { TextField("—", text: $raceText) }
                SheetBox("ALIGNMENT") { TextField("—", text: $alignmentText) }
                SheetBox("EXPERIENCE POINTS") { TextField("—", text: $experiencePoints) }
            }
        }
    }

    // MARK: - Three-column content
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

            // Saving Throws
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

            // Other Proficiencies & Languages (LIST)
            CollapsibleListBox(
                title: "OTHER PROFICIENCIES & LANGUAGES",
                items: $profLangItems,
                isExpanded: $showProfLang,
                listHeight: 180,
                placeholder: "Add a proficiency or language"
            )
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

            // Attacks & Spellcasting (unchanged)
            SheetBox("ATTACKS & SPELLCASTING") {
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            showAttacks.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Attacks")
                                .font(.subheadline).bold()
                            Spacer()
                            Image(systemName: showAttacks ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if showAttacks {
                        HStack {
                            Text("Name").font(.subheadline).bold()
                            Spacer()
                            Text("Atk Bonus").font(.subheadline).bold()
                                .frame(width: 90, alignment: .trailing)
                            Text("Damage/Type").font(.subheadline).bold()
                                .frame(width: 130, alignment: .trailing)
                        }

                        ScrollView(.vertical) {
                            VStack(spacing: 8) {
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
                            .padding(.vertical, 4)
                        }
                        .frame(height: 220)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    withAnimation {
                        attacks.append(.init())
                        showAttacks = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(8)
                .help("Add attack or spell")
            }

            // Equipment as LIST + coins
            CollapsibleListBox(
                title: "EQUIPMENT",
                items: $equipmentItems,
                isExpanded: $showEquipment,
                listHeight: 220,
                placeholder: "Add an item"
            )
            .overlay(alignment: .bottom) {
                // Coins stay visible below the list
                VStack(spacing: 8) {
                    Divider().padding(.top, 8)
                    HStack(spacing: 8) {
                        CoinField("CP", text: $cp)
                        CoinField("SP", text: $sp)
                        CoinField("EP", text: $ep)
                        CoinField("GP", text: $gp)
                        CoinField("PP", text: $pp)
                    }
                    .padding(.bottom, 8)
                }
                .background(Color.clear)
            }
            .padding(.bottom, 64) // give room for coin row overlay
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - RIGHT COLUMN
    private var rightColumn: some View {
        VStack(spacing: 12) {
            CollapsibleListBox(
                title: "PERSONALITY TRAITS",
                items: $personalityItems,
                isExpanded: $showPersonality,
                listHeight: 160,
                placeholder: "Add a trait"
            )

            CollapsibleListBox(
                title: "IDEALS",
                items: $idealsItems,
                isExpanded: $showIdeals,
                listHeight: 140,
                placeholder: "Add an ideal"
            )

            CollapsibleListBox(
                title: "BONDS",
                items: $bondsItems,
                isExpanded: $showBonds,
                listHeight: 140,
                placeholder: "Add a bond"
            )

            CollapsibleListBox(
                title: "FLAWS",
                items: $flawsItems,
                isExpanded: $showFlaws,
                listHeight: 140,
                placeholder: "Add a flaw"
            )

            CollapsibleListBox(
                title: "FEATURES & TRAITS",
                items: $featuresItems,
                isExpanded: $showFeatures,
                listHeight: 200,
                placeholder: "Add a feature or trait"
            )
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - Helpers (bindings & calculations)

    private var classSummary: String {
        guard !classes.isEmpty else { return "\(character.className) \(character.level)" }
        return classes.map { "\($0.name) \($0.level)" }.joined(separator: " / ")
    }

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

    private var passivePerception: Int {
        let wis = modifier(for: .wis)
        let pb = character.proficiencyBonus
        let perception = Skill.allCases.first { $0.title.lowercased() == "perception" }
        let level = perception.map { character.proficiency(for: $0) } ?? .none
        let prof = level == .none ? 0 : pb * (level == .expertise ? 2 : 1)
        return 10 + wis + prof
    }
}

// MARK: - Reusable views (SheetBox, StatPill, LabeledValueRow, CounterRow, CoinField are unchanged)
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

// MARK: - Collapsible, scrollable list editor
private struct CollapsibleListBox: View {
    let title: String
    @Binding var items: [ListItem]
    @Binding var isExpanded: Bool
    var listHeight: CGFloat = 180
    var placeholder: String = "Add item"

    var body: some View {
        SheetBox(title) {
            VStack(spacing: 8) {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("\(title.capitalized)")
                            .font(.subheadline).bold()
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    ScrollView(.vertical) {
                        VStack(spacing: 8) {
                            ForEach($items) { $item in
                                HStack(spacing: 8) {
                                    TextField(placeholder, text: $item.text)
                                        .textFieldStyle(.roundedBorder)
                                    Button {
                                        withAnimation { items.removeAll { $0.id == item.id } }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }
                                    .help("Remove")
                                }
                            }

                        }
                        .padding(.vertical, 4)
                    }
                    .frame(height: listHeight)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    items.append(.init())
                    isExpanded = true
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(8)
            .help("Add item")
        }
    }
}

// MARK: - Ability block (unchanged styling)
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
