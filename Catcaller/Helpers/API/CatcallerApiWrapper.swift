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

protocol CatCallerApiDelegate {}

protocol CatCallerApiGetHarassmentTypesDelegate: CatCallerApiDelegate {
    func getHarassmentTypesSuccess(harassmentTypes: [HarassmentType])
    func getHarassmentTypesError()
}

protocol CatCallerApiCreateUserDelegate: CatCallerApiDelegate {
    func createUserSuccess()
    func createUserError(message: String)
}

protocol CatCallerApiAuthenticationDelegate: CatCallerApiDelegate {
    func authenticationSuccess()
    func authenticationError(errorCode: Int?)
}

protocol CatCallerApiGetReportsDelegate: CatCallerApiDelegate {
    func getReportsSuccess(reports: [Report])
    func getReportsError(error: Error)
}

protocol CatCallerApiCreateReportDelegate: CatCallerApiDelegate {
    func createReportSuccess()
    func createReportError()
}

class CatcallerApiWrapper {

    let baseURL: String = "https://blooming-mesa-38452.herokuapp.com/"

    var apiFormatter: CatcallerApiFormatter!
    var authenticationHelper: AuthenticationHelper!
    var delegate: CatCallerApiDelegate?

    var headers: HTTPHeaders = HTTPHeaders()

    init() {
        self.apiFormatter = CatcallerApiFormatter()
        self.authenticationHelper = AuthenticationHelper()

        self.reloadUserAuthorization()
    }

    public func createUser(email: String, password: String) {

        let url: String = self.baseURL + "users"
        let parameters: Parameters = ["email": email,"plainPassword": password]

        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                if let controller = self.delegate as? CatCallerApiCreateUserDelegate {
                    controller.createUserSuccess()
                }
            case .failure(let error):
                print("Error - createUser: \(error)")
                if let controller = self.delegate as? CatCallerApiCreateUserDelegate {
                    var errorMessage = String()
                    if let data = response.data {
                        errorMessage = JSON(data)["hydra:description"].string!
                    }
                    controller.createUserError(message: errorMessage)
                }
            }
        }
    }

    public func authenticate(email: String, password: String) {

        let url: String = self.baseURL + "login_check"
        let parameters: Parameters = ["_username": email,"_password": password]
        
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):

                let token = JSON(value)["token"].string!
                self.authenticationHelper.storeUserToken(token: token)
                self.setAuthorizationHeader(token: token)

                if let controller = self.delegate as? CatCallerApiAuthenticationDelegate {
                    controller.authenticationSuccess()
                }

            case .failure(let error):
                if let controller = self.delegate as? CatCallerApiAuthenticationDelegate {
                    print("Error - authenticate: \(error)")
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
    public func getReports(minLat: CLLocationDegrees, minLong: CLLocationDegrees, maxLat: CLLocationDegrees, maxLong: CLLocationDegrees, harassmentTypes: [Int:HarassmentType], onlyMyReports: Bool) {

        self.reloadUserAuthorization()

        let url: String = self.baseURL + "reports"

        var parameters: Parameters = [
            "harassment.location.latitude[between]": "\(minLat)..\(maxLat)",
            "harassment.location.longitude[between]": "\(minLong)..\(maxLong)",
            "itemsPerPage": 500,
            "harassment.types.id": Array(harassmentTypes.keys)
        ]

        if onlyMyReports {
            parameters["reporter.id"] = self.authenticationHelper.getUserId()
        }
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let controller = self.delegate as? CatCallerApiGetReportsDelegate {
                    let reports: [Report] = self.apiFormatter.formatJsonIntoReports(json: JSON(value))
                    controller.getReportsSuccess(reports: reports)
                }
            case .failure(let error):
                print("Error - loadReportsInArea: \(error)")
                if let controller = self.delegate as? CatCallerApiGetReportsDelegate {
                    controller.getReportsError(error: error)
                }
            }
        }
    }

    public func getHarassmentTypes() {

        self.reloadUserAuthorization()

        let url: String = self.baseURL + "harassment_types"

        Alamofire.request(url, method: .get, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let controller = self.delegate as? CatCallerApiGetHarassmentTypesDelegate {
                    let harassmentTypes: [HarassmentType] = self.apiFormatter.formatJsonIntoHarassmentTypes(json: JSON(value))
                    controller.getHarassmentTypesSuccess(harassmentTypes: harassmentTypes)
                }
            case .failure(let error):
                print("Error - loadHarassmentTypes: \(error)")
                if let controller = self.delegate as? CatCallerApiGetHarassmentTypesDelegate {
                    controller.getHarassmentTypesError()
                }
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
                if let controller = self.delegate as? CatCallerApiCreateReportDelegate {
                    controller.createReportSuccess()
                }
            case .failure(let error):
                print("Error - createReport: \(error)")

                if let controller = self.delegate as? CatCallerApiCreateReportDelegate {
                    controller.createReportError()
                }
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
