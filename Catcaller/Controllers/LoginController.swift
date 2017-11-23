//
//  LoginController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 27/10/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createUser(_ sender: UIButton) {

        let email: String = self.email.text!
        let password: String = self.password.text!

        print("Create user")
        print(email)
        print(password)

        let apiWrapper: CatcallerApiWrapper = CatcallerApiWrapper()
        apiWrapper.createUser(email: email, password: password)

    }
}
