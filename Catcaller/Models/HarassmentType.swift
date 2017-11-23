//
//  HarassmentType.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class HarassmentType {
    
    var id: Int!
    var label: String

    init(label: String) {
        self.label = label
    }

    init(id: Int, label: String) {
        self.label = label
        self.id = id
    }
}
