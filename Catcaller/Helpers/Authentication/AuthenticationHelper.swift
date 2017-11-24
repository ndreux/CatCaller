//
//  AuthenticationHelper.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 23/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation
import KeychainAccess
import JWTDecode

class AuthenticationHelper {

    let appName: String = Bundle.main.infoDictionary!["CFBundleName"] as! String

    var keychain: Keychain

    init() {
        self.keychain = Keychain(service: self.appName)
    }

    func logout() {
        try? self.keychain.remove("token")
    }

    func isUserAuthenticated() -> Bool {
        do {
            let token = try keychain.getString("token")
            return token != nil
        } catch {
            return false
        }
    }

    func storeUserToken(token: String) {
        self.keychain[string: "token"] = token
    }

    func getUserToken() -> String? {
        if !self.isUserAuthenticated() {
            return nil
        }

        return try! keychain.getString("token")
    }

    func getUserId() -> Int? {
        if !self.isUserAuthenticated() {
            return nil
        }

        do {
            let token = try keychain.getString("token")
            let jwt = try decode(jwt: token!)

            return jwt.body["uid"] as? Int
        } catch let error {
            print(error)
        }

        return nil
    }
}
