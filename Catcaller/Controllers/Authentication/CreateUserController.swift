//
//  CreateUserController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 26/10/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

protocol CreateUserControllerDelegate {
    func createUserSuccess()
}

extension CreateUserController: CatCallerApiCreateUserDelegate {
    func createUserSuccess() {
        self.createUserButton.hideLoading()
        self.delegate?.createUserSuccess()
        self.navigationController?.popToRootViewController(animated: true)
    }

    func createUserError(message: String) {
        self.createUserButton.hideLoading()
        self.formErrors["email"] = message
        self.displayErrorMessage()
    }
}

class CreateUserController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordVerification: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var createUserButton: LoadingButton!

    var formErrors: [String:String] = [String:String]()

    var apiWrapper: CatcallerApiWrapper!
    var delegate: CreateUserControllerDelegate?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateCreateUserButtonStatus()
        self.apiWrapper = CatcallerApiWrapper()
        self.apiWrapper.delegate = self

    }

    // MARK: Form validation
    @IBAction func valueChanged(_ sender: UITextField) {
        self.updateCreateUserButtonStatus()
    }

    @IBAction func passwordsChanged(_ sender: UITextField) {
        if !self.doPasswordsMatch() {
            self.formErrors["passwords"] = NSLocalizedString("form.create_account.error.password.no_match", comment: "")
        } else {
            self.formErrors.removeValue(forKey: "passwords")
        }

        self.displayErrorMessage()
    }

    @IBAction func emailEditDidEnd(_ sender: UITextField) {
        if !self.isEmailValid() {
            self.formErrors["email"] = NSLocalizedString("form.create_account.error.email.invalid", comment: "")
        } else {
            self.formErrors.removeValue(forKey: "email")
        }

        self.displayErrorMessage()
    }

    func updateCreateUserButtonStatus() {
        let fieldsFilled = !self.email.text!.isEmpty && !self.password.text!.isEmpty && !self.passwordVerification.text!.isEmpty

        self.createUserButton.isEnabled = fieldsFilled && self.errorLabel.text!.isEmpty
    }

    func doPasswordsMatch() -> Bool {
        return self.password.text! == self.passwordVerification.text!
    }

    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: self.email.text!)
    }

    func displayErrorMessage() {
        var errorMessage = ""
        for (_, error) in self.formErrors {
            errorMessage.append("\(error) ")
        }
        self.errorLabel.text = errorMessage
    }

    // MARK: Form submition

    @IBAction func createUser(_ sender: UIButton) {
        self.createUserButton.showLoading()
        self.apiWrapper.createUser(email: self.email.text!, password: self.password.text!)
    }
}
