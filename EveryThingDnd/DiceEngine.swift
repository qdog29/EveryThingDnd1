import Foundation

struct RollResult {
    var rolls: [Int]
    var total: Int
    var formula: String
}

enum AdvantageState {
    case normal
    case advantage
    case disadvantage
}

struct DiceEngine {
    static func rollDie(_ sides: Int, rng: inout some RandomNumberGenerator) -> Int {
        Int.random(in: 1...sides, using: &rng)
    }

    static func abilityCheck(for ability: Ability, character: Character, proficiency: ProficiencyLevel, advantage: AdvantageState = .normal, rng: inout some RandomNumberGenerator) -> RollResult {
        var rolls: [Int] = []
        let first = rollDie(20, rng: &rng)
        rolls.append(first)
        var selected = first
        if advantage != .normal {
            let second = rollDie(20, rng: &rng)
            rolls.append(second)
            selected = advantage == .advantage ? max(first, second) : min(first, second)
        }
        let abilityMod = modifier(for: ability, character: character)
        let profBonus: Int
        switch proficiency {
        case .none: profBonus = 0
        case .proficient: profBonus = character.proficiencyBonus
        case .expertise: profBonus = character.proficiencyBonus * 2
        }
        let total = selected + abilityMod + profBonus
        return RollResult(rolls: rolls, total: total, formula: "1d20 + mods")
    }

    static func roll(expression: String, character: Character? = nil, critical: Bool = false, rng: inout some RandomNumberGenerator) -> RollResult {
        var total = 0
        var rolls: [Int] = []
        let tokens = expression.replacingOccurrences(of: " ", with: "").split(separator: "+")
        for token in tokens {
            if let range = token.firstIndex(of: "d") {
                let count = Int(token[..<range]) ?? 1
                let sidesToken = token[token.index(after: range)...]
                let sides = Int(sidesToken) ?? 20
                let diceCount = critical ? count * 2 : count
                for _ in 0..<diceCount {
                    let roll = rollDie(sides, rng: &rng)
                    rolls.append(roll)
                    total += roll
                }
            } else if token.uppercased() == "PB" {
                total += character?.proficiencyBonus ?? 0
            } else if let ability = Ability(rawValue: token.lowercased()) {
                if let character = character {
                    total += modifier(for: ability, character: character)
                }
            } else if let num = Int(token) {
                total += num
            }
        }
        return RollResult(rolls: rolls, total: total, formula: expression)
    }

    static func modifier(for ability: Ability, character: Character) -> Int {
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

/// Deterministic RNG for testing
struct FixedRNG: RandomNumberGenerator {
    var numbers: [UInt64]
    var index: Int = 0
    mutating func next() -> UInt64 {
        defer { index += 1 }
        return numbers[index % numbers.count]
    }
}
