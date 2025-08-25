import SwiftUI

struct RollsView: View {
    var character: Character
    @State private var check: CheckType = .ability(.str)
    @State private var damageExpression: String = "1d6"
    @State private var critical: Bool = false
    @State private var resultText: String = ""

    var body: some View {
        Form {
            Section("Check") {
                Picker("Check Type", selection: $check) {
                    ForEach(CheckType.allCases, id: \.self) { ct in
                        Text(ct.title).tag(ct)
                    }
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
        var rng = SystemRandomNumberGenerator()
        let result = DiceEngine.check(type: check, character: character, rng: &rng)
        var parts: [String] = ["d20: \(result.d20)", "ability: \(result.abilityMod)"]
        if result.expertise {
            parts.append("expertise: \(result.proficiencyBonus * 2)")
        } else if result.proficient {
            parts.append("proficiency: \(result.proficiencyBonus)")
        }
        resultText = parts.joined(separator: " + ") + " = \(result.total)"
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
