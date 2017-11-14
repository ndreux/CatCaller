//
//  CreateReportController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 09/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class CreateReportController: UIViewController {

    let reportTypes = ["Victim", "Witness"]
    // toto (ndreux - 2017-11-09) Get from API
    let harassmentTypes = ["Immigration Status", "Age", "Gender", "Race", "Religious Beliefs", "Sexual Orientation", "Marital Status", "Political Beliefs", "Veteran Status", "Mental Disabilities", "Physical Disabilities", "Gender Identification"]

    @IBOutlet weak var reportTypeButton: UIButton!
    @IBOutlet weak var harassmentDateButton: UIButton!
    @IBOutlet weak var harassmentLocationButton: UIButton!
    @IBOutlet weak var harassmentTypesButton: UIButton!
    @IBOutlet weak var reportNoteTextView: UITextView!


    override func viewDidLoad() {
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        view.layoutIfNeeded()
        self.reportTypeButton.disclosureButton(baseColor: view.tintColor)
    }
}
