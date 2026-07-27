//
//  Item.swift
//  Estafet
//
//  Created by Takhiyuddin on 27/07/26.
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
