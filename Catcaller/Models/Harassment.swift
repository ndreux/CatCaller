//
//  Harassment.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 08/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class Harassment {
    
    var types: [HarassmentType]!
    var location: Location!
    var datetime: String?
    var note: String?

    init() {
        self.types = []
    }
}
