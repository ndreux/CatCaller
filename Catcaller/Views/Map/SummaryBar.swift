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

    private func commonInit() {

        Bundle.main.loadNibNamed("SummaryBar", owner: self, options: nil)

        contentView.backgroundColor = UIColor(hex: "020440")
        summaryText.textColor = .white
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(contentView)
    }

    func updateSummary(reportsCount: Int?) {
        switch reportsCount {
        case nil:
            self.summaryText.text = NSLocalizedString("summary_bar.area_too_big", comment: "")
        case 0?:
            self.summaryText.text = NSLocalizedString("summary_bar.report.zero", comment: "")
        case 1?:
            self.summaryText.text = NSLocalizedString("summary_bar.report.one", comment: "")
        default:
            self.summaryText.text = String(format: NSLocalizedString("summary_bar.report.more", comment: ""), reportsCount!)
        }
    }

}
