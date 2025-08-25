import Foundation

struct RollResult {
    var rolls: [Int]
    var total: Int
    var formula: String
}

struct CheckRollResult {
    var d20: Int
    var abilityMod: Int
    var proficiencyBonus: Int
    var proficient: Bool
    var expertise: Bool
    var total: Int
}

struct DiceEngine {
    static func rollDie(_ sides: Int, rng: inout some RandomNumberGenerator) -> Int {
        Int.random(in: 1...sides, using: &rng)
    }

    static func check(type: CheckType, character: Character, rng: inout some RandomNumberGenerator) -> CheckRollResult {
        let d20 = rollDie(20, rng: &rng)
        let ability: Ability
        let level: ProficiencyLevel
        switch type {
        case .ability(let a):
            ability = a
            level = character.abilityProficiency(for: a)
        case .skill(let s):
            ability = s.ability
            level = character.proficiency(for: s)
        }
        let abilityMod = modifier(for: ability, character: character)
        let pb = character.proficiencyBonus
        let proficient = level != .none
        let expertise = level == .expertise
        let profComponent = proficiencyComponent(level: level, pb: pb)
        let total = d20 + abilityMod + profComponent
        return CheckRollResult(d20: d20, abilityMod: abilityMod, proficiencyBonus: pb, proficient: proficient, expertise: expertise, total: total)
    }

    private static func proficiencyComponent(level: ProficiencyLevel, pb: Int) -> Int {
        switch level {
        case .none: return 0
        case .proficient: return pb
        case .expertise: return pb * 2
        }
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
