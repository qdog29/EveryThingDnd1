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

    @Test func checkAppliesProficiency() async throws {
        var rng = FixedRNG(numbers: [10])
        let character = Character(str: 16, level: 5)
        character.setProficiency(.proficient, for: .athletics)
        let result = DiceEngine.check(type: .skill(.athletics), character: character, rng: &rng)
        #expect(result.total == 10 + 3 + character.proficiencyBonus)
        #expect(result.proficient)
        #expect(!result.expertise)
    }

    @Test func checkAppliesExpertise() async throws {
        var rng = FixedRNG(numbers: [5])
        let character = Character(dex: 14, level: 5)
        character.setProficiency(.expertise, for: .stealth)
        let result = DiceEngine.check(type: .skill(.stealth), character: character, rng: &rng)
        #expect(result.total == 5 + 2 + character.proficiencyBonus * 2)
        #expect(result.expertise)
    }
}
