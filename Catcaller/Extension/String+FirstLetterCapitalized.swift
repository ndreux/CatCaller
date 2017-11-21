//
//  String+FirstLetterCapitalized.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 18/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
