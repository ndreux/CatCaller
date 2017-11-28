//
//  SummaryBar.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 09/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class SummaryBar: UIView {

    @IBOutlet weak var summaryText: UILabel!
    @IBOutlet var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {

        Bundle.main.loadNibNamed("SummaryBar", owner: self, options: nil)

        contentView.backgroundColor = UIColor(hex: "020440")

        summaryText.textColor = .white
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(contentView)
    }

}
