//
//  AuthenticationNavigationController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 23/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class AuthenticationController: UIViewController, CreateUserControllerDelegate {

    @IBOutlet weak var flashMessage: UILabel!

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func createUserSuccess() {
        self.flashMessage.text = "Your account has successefuly been created. You can now log in."
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.resetFlashMessage()
        if let destinationController = segue.destination as? CreateUserController {
            destinationController.delegate = self
        }
    }

    func resetFlashMessage() {
        self.flashMessage.text = String()
    }
}
