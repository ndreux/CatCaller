//
//  Report.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 08/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class Report {

    var harassment: Harassment
    var type: String

    init() {
        self.type = String()
        self.harassment = Harassment()
    }
}
