import SwiftUI

struct RollsView: View {
    var character: Character?
    @State private var ability: Ability = .str
    @State private var proficiency: ProficiencyLevel = .none
    @State private var advantage: AdvantageState = .normal
    @State private var damageExpression: String = "1d6"
    @State private var critical: Bool = false
    @State private var resultText: String = ""

    var body: some View {
        Form {
            Section("Checks & Saves") {
                Picker("Ability", selection: $ability) {
                    ForEach(Ability.allCases) { ability in
                        Text(ability.title).tag(ability)
                    }
                }
                Picker("Proficiency", selection: $proficiency) {
                    Text("None").tag(ProficiencyLevel.none)
                    Text("Proficient").tag(ProficiencyLevel.proficient)
                    Text("Expertise").tag(ProficiencyLevel.expertise)
                }
                Picker("Advantage", selection: $advantage) {
                    Text("Normal").tag(AdvantageState.normal)
                    Text("Advantage").tag(AdvantageState.advantage)
                    Text("Disadvantage").tag(AdvantageState.disadvantage)
                }
                Button("Roll") { rollCheck() }
            }
            Section("Damage") {
                TextField("2d6+3", text: $damageExpression)
                Toggle("Critical", isOn: $critical)
                Button("Roll Damage") { rollDamage() }
            }
            if !resultText.isEmpty {
                Section("Result") {
                    Text(resultText)
                }
            }
        }
        .navigationTitle("Rolls")
    }

    private func rollCheck() {
        guard let character else { resultText = "Select a character first"; return }
        var rng = SystemRandomNumberGenerator()
        let result = DiceEngine.abilityCheck(for: ability, character: character, proficiency: proficiency, advantage: advantage, rng: &rng)
        resultText = "Rolls: \(result.rolls) Total: \(result.total)"
    }

    private func rollDamage() {
        var rng = SystemRandomNumberGenerator()
        let result = DiceEngine.roll(expression: damageExpression, character: character, critical: critical, rng: &rng)
        resultText = "Rolls: \(result.rolls) Total: \(result.total)"
    }
}

#Preview {
    let c = Character(name: "Test", className: "Fighter")
    return RollsView(character: c)
}
