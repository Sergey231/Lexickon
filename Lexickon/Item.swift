//
//  Item.swift
//  Lexickon
//
//  Created by Sergey Borovikov on 20.05.2026.
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
