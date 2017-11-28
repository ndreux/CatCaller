//
//  BottomPanel.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 28/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class BottomPanel: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var harassmentDate: UILabel!
    @IBOutlet weak var reportType: UILabel!
    @IBOutlet weak var harassmentTypes: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("BottomPanel", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        layer.cornerRadius = 10
        clipsToBounds = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
