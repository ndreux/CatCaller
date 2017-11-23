//
//  HarassmentType+Printable.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

extension HarassmentType: CustomStringConvertible {
    var description: String {
        return "\(self.label)"
    }
}
