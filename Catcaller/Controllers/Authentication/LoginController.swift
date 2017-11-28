//
//  LoginController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 27/10/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController, CatCallerApiAuthenticationDelegate {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var loginButton: LoadingButton!

    var apiWrapper: CatcallerApiWrapper!

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateLoginButtonStatus()
        self.apiWrapper = CatcallerApiWrapper()
        self.apiWrapper.delegate = self

    }

    @IBAction func valueChanged(_ sender: UITextField) {
        self.updateLoginButtonStatus()
    }

    @IBAction func authenticateUser(_ sender: UIButton) {
        self.loginButton.showLoading()
        let email: String = self.email.text!
        let password: String = self.password.text!

        apiWrapper.authenticate(email: email, password: password)
    }

    func authenticationSuccess() {
        self.loginButton.hideLoading()
        self.dismiss(animated: true, completion: nil)
    }

    func authenticationError(errorCode: Int?) {
        self.loginButton.hideLoading()
        if errorCode == 401 {
            self.errorLabel.text = "Login/password do not match"
        }
    }


    func updateLoginButtonStatus() {
        self.loginButton.isEnabled = !self.email.text!.isEmpty && !self.password.text!.isEmpty
    }
}
