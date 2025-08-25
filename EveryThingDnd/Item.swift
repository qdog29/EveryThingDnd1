//
//  Item.swift
//  EveryThingDnd
//
//  Created by Quinlan Taylor on 2025-08-24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
