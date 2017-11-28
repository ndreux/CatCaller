//
//  BottomPanelView.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 09/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation
import UIKit

class BottomPanelView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(white: 1, alpha: 0.9)
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
}
