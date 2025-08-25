import Foundation
import SwiftData

// MARK: - Enums

/// Ability scores used for checks and modifiers
enum Ability: String, CaseIterable, Identifiable, Codable {
    case str, dex, con, int, wis, cha
    var id: Self { self }
    var title: String {
        switch self {
        case .str: return "Strength"
        case .dex: return "Dexterity"
        case .con: return "Constitution"
        case .int: return "Intelligence"
        case .wis: return "Wisdom"
        case .cha: return "Charisma"
        }
    }
}

/// Skill proficiency levels
enum ProficiencyLevel: Int, Codable, CaseIterable {
    case none = 0
    case proficient = 1
    case expertise = 2
}

/// List of skills from the SRD
enum Skill: String, CaseIterable, Identifiable, Codable {
    case athletics, acrobatics, sleightOfHand, stealth
    case arcana, history, investigation, nature, religion
    case animalHandling, insight, medicine, perception, survival
    case deception, intimidation, performance, persuasion
    var id: Self { self }
    var ability: Ability {
        switch self {
        case .athletics: return .str
        case .acrobatics, .sleightOfHand, .stealth: return .dex
        case .arcana, .history, .investigation, .nature, .religion: return .int
        case .animalHandling, .insight, .medicine, .perception, .survival: return .wis
        case .deception, .intimidation, .performance, .persuasion: return .cha
        }
    }
    var title: String {
        switch self {
        case .sleightOfHand: return "Sleight of Hand"
        case .animalHandling: return "Animal Handling"
        default: return rawValue.capitalized
        }
    }
}

/// Represents either an ability or a skill for performing checks
enum CheckType: Hashable, Identifiable {
    case ability(Ability)
    case skill(Skill)

    var id: String {
        switch self {
        case .ability(let ability): return "ability-\(ability.rawValue)"
        case .skill(let skill): return "skill-\(skill.rawValue)"
        }
    }

    var title: String {
        switch self {
        case .ability(let ability): return ability.title
        case .skill(let skill): return skill.title
        }
    }

    static var allCases: [CheckType] {
        Ability.allCases.map { .ability($0) } + Skill.allCases.map { .skill($0) }
    }
}

// MARK: - Model objects

@Model
final class SkillEntry {
    var skillRaw: String
    var levelRaw: Int

    init(skill: Skill, level: ProficiencyLevel = .none) {
        self.skillRaw = skill.rawValue
        self.levelRaw = level.rawValue
    }

    var skill: Skill {
        get { Skill(rawValue: skillRaw) ?? .athletics }
        set { skillRaw = newValue.rawValue }
    }

    var level: ProficiencyLevel {
        get { ProficiencyLevel(rawValue: levelRaw) ?? .none }
        set { levelRaw = newValue.rawValue }
    }
}

@Model
final class AbilityEntry {
    var abilityRaw: String
    var levelRaw: Int

    init(ability: Ability, level: ProficiencyLevel = .none) {
        self.abilityRaw = ability.rawValue
        self.levelRaw = level.rawValue
    }

    var ability: Ability {
        get { Ability(rawValue: abilityRaw) ?? .str }
        set { abilityRaw = newValue.rawValue }
    }

    var level: ProficiencyLevel {
        get { ProficiencyLevel(rawValue: levelRaw) ?? .none }
        set { levelRaw = newValue.rawValue }
    }
}

@Model
final class Attack {
    var name: String
    var attackBonus: Int
    var damage: String
    var damageType: String

    init(name: String = "", attackBonus: Int = 0, damage: String = "", damageType: String = "") {
        self.name = name
        self.attackBonus = attackBonus
        self.damage = damage
        self.damageType = damageType
    }
}

@Model
final class InventoryItem {
    var name: String
    var qty: Int
    var weight: Double
    var notes: String

    init(name: String = "", qty: Int = 1, weight: Double = 0, notes: String = "") {
        self.name = name
        self.qty = qty
        self.weight = weight
        self.notes = notes
    }
}

@Model
final class RollLog {
    var timestamp: Date
    var expression: String
    var context: String
    var resultBreakdown: String

    init(timestamp: Date = .now, expression: String, context: String, resultBreakdown: String) {
        self.timestamp = timestamp
        self.expression = expression
        self.context = context
        self.resultBreakdown = resultBreakdown
    }
}

@Model
final class Character {
    // Identity
    var name: String
    var speciesOrRace: String
    var className: String
    var subclass: String?
    var level: Int
    var background: String
    var alignment: String
    var playerName: String
    var experiencePoints: Int

    // Core stats
    var str: Int
    var dex: Int
    var con: Int
    var intScore: Int
    var wis: Int
    var cha: Int

    // Combat & Inspiration
    var inspiration: Bool
    var ac: Int
    var initiative: Int
    var speed: Int

    // Hit points
    var maxHP: Int
    var currentHP: Int
    var tempHP: Int
    var hitDiceType: Int
    var hitDiceTotal: Int
    var hitDiceUsed: Int
    var deathSaveSuccesses: Int
    var deathSaveFailures: Int

    // Saving throw proficiencies
    var saveProfStr: Bool
    var saveProfDex: Bool
    var saveProfCon: Bool
    var saveProfInt: Bool
    var saveProfWis: Bool
    var saveProfCha: Bool

    // Relationships
    @Relationship(deleteRule: .cascade) var skills: [SkillEntry] = []
    @Relationship(deleteRule: .cascade) var abilityFlags: [AbilityEntry] = []
    @Relationship(deleteRule: .cascade) var attacks: [Attack] = []
    @Relationship(deleteRule: .cascade) var inventory: [InventoryItem] = []
    @Relationship(deleteRule: .cascade) var rollLogs: [RollLog] = []

    // Roleplay fields
    var features: String
    var proficiencies: String
    var languages: String

    // Bio fields
    var age: String
    var height: String
    var weight: String
    var eyes: String
    var skin: String
    var hair: String
    var appearance: String
    var allies: String
    var backstory: String
    var treasure: String

    init(name: String = "New Character", speciesOrRace: String = "", className: String = "", subclass: String? = nil, level: Int = 1, background: String = "", alignment: String = "", playerName: String = "", experiencePoints: Int = 0, str: Int = 10, dex: Int = 10, con: Int = 10, intScore: Int = 10, wis: Int = 10, cha: Int = 10, inspiration: Bool = false, ac: Int = 10, initiative: Int = 0, speed: Int = 30, maxHP: Int = 10, currentHP: Int = 10, tempHP: Int = 0, hitDiceType: Int = 6, hitDiceTotal: Int = 1, hitDiceUsed: Int = 0, deathSaveSuccesses: Int = 0, deathSaveFailures: Int = 0, saveProfStr: Bool = false, saveProfDex: Bool = false, saveProfCon: Bool = false, saveProfInt: Bool = false, saveProfWis: Bool = false, saveProfCha: Bool = false, features: String = "", proficiencies: String = "", languages: String = "", age: String = "", height: String = "", weight: String = "", eyes: String = "", skin: String = "", hair: String = "", appearance: String = "", allies: String = "", backstory: String = "", treasure: String = "") {
        self.name = name
        self.speciesOrRace = speciesOrRace
        self.className = className
        self.subclass = subclass
        self.level = level
        self.background = background
        self.alignment = alignment
        self.playerName = playerName
        self.experiencePoints = experiencePoints
        self.str = str
        self.dex = dex
        self.con = con
        self.intScore = intScore
        self.wis = wis
        self.cha = cha
        self.inspiration = inspiration
        self.ac = ac
        self.initiative = initiative
        self.speed = speed
        self.maxHP = maxHP
        self.currentHP = currentHP
        self.tempHP = tempHP
        self.hitDiceType = hitDiceType
        self.hitDiceTotal = hitDiceTotal
        self.hitDiceUsed = hitDiceUsed
        self.deathSaveSuccesses = deathSaveSuccesses
        self.deathSaveFailures = deathSaveFailures
        self.saveProfStr = saveProfStr
        self.saveProfDex = saveProfDex
        self.saveProfCon = saveProfCon
        self.saveProfInt = saveProfInt
        self.saveProfWis = saveProfWis
        self.saveProfCha = saveProfCha
        self.features = features
        self.proficiencies = proficiencies
        self.languages = languages
        self.age = age
        self.height = height
        self.weight = weight
        self.eyes = eyes
        self.skin = skin
        self.hair = hair
        self.appearance = appearance
        self.allies = allies
        self.backstory = backstory
        self.treasure = treasure
    }

    // MARK: - Computed helpers
    private func modifier(for score: Int) -> Int { (score - 10) / 2 }

    var strMod: Int { modifier(for: str) }
    var dexMod: Int { modifier(for: dex) }
    var conMod: Int { modifier(for: con) }
    var intMod: Int { modifier(for: intScore) }
    var wisMod: Int { modifier(for: wis) }
    var chaMod: Int { modifier(for: cha) }

    var proficiencyBonus: Int { (level - 1) / 4 + 2 }

    func proficiency(for skill: Skill) -> ProficiencyLevel {
        skills.first(where: { $0.skill == skill })?.level ?? .none
    }

    func setProficiency(_ level: ProficiencyLevel, for skill: Skill) {
        if let entry = skills.first(where: { $0.skill == skill }) {
            entry.level = level
        } else {
            skills.append(SkillEntry(skill: skill, level: level))
        }
    }

    func abilityProficiency(for ability: Ability) -> ProficiencyLevel {
        abilityFlags.first(where: { $0.ability == ability })?.level ?? .none
    }

    func setAbilityProficiency(_ level: ProficiencyLevel, for ability: Ability) {
        if let entry = abilityFlags.first(where: { $0.ability == ability }) {
            entry.level = level
        } else {
            abilityFlags.append(AbilityEntry(ability: ability, level: level))
        }
    }

    var passivePerception: Int {
        let prof = proficiency(for: .perception)
        let bonus = prof == .none ? 0 : proficiencyBonus * (prof == .expertise ? 2 : 1)
        return 10 + wisMod + bonus
    }
}

// MARK: - Versioned Schema

enum DnDSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Character.self, Attack.self, InventoryItem.self, SkillEntry.self, AbilityEntry.self, RollLog.self]
    }
    static var versionIdentifier = Schema.Version(1, 0, 0)
}

typealias DnDSchema = DnDSchemaV1
