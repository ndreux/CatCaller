//
//  Report.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 08/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class Report {

    static let typeVictim: Int = 1
    static let typeWitness: Int = 2

    var harassment: Harassment
    var type: String!

    init() {
        self.harassment = Harassment()
    }
}
