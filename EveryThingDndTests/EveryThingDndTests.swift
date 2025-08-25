//
//  EveryThingDndTests.swift
//  EveryThingDndTests
//
//  Created by Quinlan Taylor on 2025-08-24.
//

import Testing
@testable import EveryThingDnd

struct DiceEngineTests {
    @Test func expressionRoll() async throws {
        var rng = FixedRNG(numbers: [3, 4])
        let character = Character()
        let result = DiceEngine.roll(expression: "2d6+3", character: character, rng: &rng)
        #expect(result.total == 10)
        #expect(result.rolls == [3,4])
    }

    @Test func abilityCheck() async throws {
        var rng = FixedRNG(numbers: [10])
        let character = Character(str: 16, level: 5)
        let result = DiceEngine.abilityCheck(for: .str, character: character, proficiency: .proficient, advantage: .normal, rng: &rng)
        #expect(result.total == 10 + 3 + character.proficiencyBonus)
    }
}
