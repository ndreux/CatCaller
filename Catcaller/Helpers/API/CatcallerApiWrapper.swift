//
//  APIWrapper.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 26/10/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MapKit

class CatcallerApiWrapper {

    let baseURL: String = "https://blooming-mesa-38452.herokuapp.com/"

    var apiFormatter: CatcallerApiFormatter!
    var authenticationHelper: AuthenticationHelper!
    var from: UIViewController? = nil

    var headers: HTTPHeaders = HTTPHeaders()

    init() {
        self.apiFormatter = CatcallerApiFormatter()
        self.authenticationHelper = AuthenticationHelper()

        self.reloadUserAuthorization()
    }

    public func createUser(email: String, password: String) {

        let url: String = self.baseURL + "users"
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]

        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
            case .failure(let error):
                print("Error - createUser")
                print(error)
            }
        }
    }

    public func authenticate(email: String, password: String) {
        let url: String = self.baseURL + "login_check"

        let parameters: Parameters = [
            "_username": email,
            "_password": password
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):

                let token = JSON(value)["token"].string!
                self.authenticationHelper.storeUserToken(token: token)
                self.setAuthorizationHeader(token: token)

                if let controller = self.from as? LoginController {
                    controller.authenticationSuccess()
                }

            case .failure(let error):
                if let controller = self.from as? LoginController {
                    print("Error - authenticate")
                    print(error)
                    if let error = error as? AFError {
                        controller.authenticationError(errorCode: error.responseCode)
                    }


                }
            }
        }
    }

    /**
     Load the reports made to the
     */
    public func loadReportsInArea(minLat: CLLocationDegrees, minLong: CLLocationDegrees, maxLat: CLLocationDegrees, maxLong: CLLocationDegrees, harassmentTypes: [Int:HarassmentType], onlyMyReports: Bool) {

        self.reloadUserAuthorization()

        let url: String = self.baseURL + "reports"

        var parameters: Parameters = [
            "harassment.location.latitude[between]": "\(minLat)..\(maxLat)",
            "harassment.location.longitude[between]": "\(minLong)..\(maxLong)",
            "itemsPerPage": 500,
            "harassment.types.id": Array(harassmentTypes.keys)
        ]

        if onlyMyReports {
            print("Only my report")
            parameters["reporter.id"] = self.authenticationHelper.getUserId()
        }
        else {
            print("All reports")
        }
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let controller = self.from as? MapViewController {
                    let reports: [Report] = self.apiFormatter.formatJsonIntoReports(json: JSON(value))
                    controller.displayReports(reports: reports)
                }
            case .failure(let error):
                print("Error - loadReportsInArea")
                print(error)
            }
        }

    }

    public func loadHarassmentTypes() {

        self.reloadUserAuthorization()

        let url: String = self.baseURL + "harassment_types"

        Alamofire.request(url, method: .get, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let harassmentTypes: [HarassmentType] = self.apiFormatter.formatJsonIntoHarassmentTypes(json: JSON(value))
                if let controller = self.from as? CreateReportTableController {
                    controller.harassmentTypes = harassmentTypes
                }
                if let controller = self.from as? MapViewController {
                    controller.updateHarassmentTypeList(harassmentTypes: harassmentTypes)
                }
            case .failure(let error):
                print("Error - loadHarassmentTypes")
                print(error)
            }
        }
    }

    public func createReport(report: Report) {

        self.reloadUserAuthorization()

        let url: String = self.baseURL + "reports"

        let jsonReport = self.apiFormatter.formatReportToJson(report: report)

        Alamofire.request(url, method: .post, parameters: jsonReport.dictionaryObject!, encoding: JSONEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success( _):
                if let controller = self.from as? CreateReportTableController {
                    controller.saveReportSuccess()
                }
            case .failure(let error):
                print("Error")
                if let controller = self.from as? CreateReportTableController {
                    controller.saveReportError()
                }
                print(error)
            }
        }
    }

    private func reloadUserAuthorization() {
        self.setAuthorizationHeader(token: self.authenticationHelper.getUserToken())
    }

    private func setAuthorizationHeader(token: String?) {
        if token != nil {
            self.headers["Authorization"] = "Bearer \(token!)"
        }
    }
}
