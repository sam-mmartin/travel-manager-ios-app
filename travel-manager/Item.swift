//
//  Item.swift
//  travel-manager
//
//  Created by Samuel on 18/10/26.
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
