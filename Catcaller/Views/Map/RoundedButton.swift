//
//  RoundedButton.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 07/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(hex: "020440")
        layer.cornerRadius = 0.5 * self.bounds.size.width
        clipsToBounds = true
    }
}
