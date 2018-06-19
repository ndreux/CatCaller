//
//  Report.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 08/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

enum ReportType: Int {
    case Victim = 1
    case Witness = 2
}

class Report {

    var id: Int?
    var harassment: Harassment
    var type: ReportType?
    var reporter: Int

    init(reporter: Int) {
        self.reporter = reporter
        self.harassment = Harassment()
    }
}
