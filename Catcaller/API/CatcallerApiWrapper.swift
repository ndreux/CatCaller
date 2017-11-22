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
    var from: UIViewController? = nil
    var apiFormatter: CatcallerApiFormatter!

    var headers: HTTPHeaders = HTTPHeaders()

    init() {
        self.apiFormatter = CatcallerApiFormatter()
        self.headers["Authorization"] = "Bearer eyJhbGciOiJSUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwidXNlcm5hbWUiOiJ1c2VyQHRlc3QuY29tIiwiaWF0IjoxNTA5OTU2MTk1LCJleHAiOjE1NDE0OTIxOTV9.UaZCJEyWGwPzyg1JL6T6ocgOKr65Hn4x7vaDvtaLQd6YCeo9nPH9hWpOYV41CNUJ7cEqO6aywa4LYbZmgYdoug2-8B3csO2BawkBAOzY1GmwjIcPHyhaeBVTSXlhXTZiKz9Xpw5OgzXTYJZPuOO1fSC2qsEN7v0wTczeenseSTXdjtBZvjf1XnKlcIjWZ6ygV4qmryBZhYg8EcNRB0nn2kjE5ziqBd-RyGKtNksYWR2CxbH_war6vh64L8gNqrpKm3MIU8ow-D4Bn5MLstgZ73yDJmyLln-tw3gsBZjFW-dqmp45QXXblQjEHPlCJQPnrNOhszNhQC3hY-eCD_xYBGtHpohG6hdC2cVJVPEV6kWUv6vYNMJM7E2QG5JcDDOC2F9tSf3BeiW4x3IEaFnZcbaCryRruktya6STkFuyhSt5XnMSsTpBc6L0SU79RXwGKx6LkfKrwKjToeaVO6ZmJwYOrz4-yGJKK5Yk5IfNSmVN6n8CIc1-1DpvER1Q2bdnoSMsHY_aHLw2sWP5p14mcFjMr_kylYHgKWLjBABH8sw4XVXb7W4THXla_oRoTjpv4KlCnyVTP82fE6zQRdtEU1tkxMBkNdqWSFrOhDd4OEyXOq-90wGXOIUMu124Z4RRFEaDtcaD7-nDNaDDo-n0vD1yfu5dIgkgA9RTKtMAAE4"
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
                print("Success")
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                print("Error")
                print(error)
            }
        }
    }

    public func authenticate(email: String, password: String) {
        let url: String = self.baseURL + "login_check"
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Success")
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                print("Error")
                print(error)
            }
        }
    }

    /**
     Load the reports made to the
     */
    public func loadReportsInArea(minLat: CLLocationDegrees, minLong: CLLocationDegrees, maxLat: CLLocationDegrees, maxLong: CLLocationDegrees, harassmentTypes: [Int:HarassmentType]) {

        let url: String = self.baseURL + "reports"

        print("HarassmentKeys : \(Array(harassmentTypes.keys))")

        let parameters: Parameters = [
            "harassment.location.latitude[between]": "\(minLat)..\(maxLat)",
            "harassment.location.longitude[between]": "\(minLong)..\(maxLong)",
            "itemsPerPage": 500,
            "harassment.types.id": Array(harassmentTypes.keys)
        ]

        print("Load pins request parameters : \(parameters)")
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Success")
                let reports: [Report] = self.apiFormatter.formatJsonIntoReports(json: JSON(value))

                print("Reports :\(reports)")
                (self.from as! MapViewController).displayReports(reports: reports)
            case .failure(let error):
                print("Error")
                print(error)
            }
        }

    }

    public func loadHarassmentTypes() {

        let url: String = self.baseURL + "harassment_types"

        Alamofire.request(url, method: .get, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Success")
                let harassmentTypes: [HarassmentType] = self.apiFormatter.formatJsonIntoHarassmentTypes(json: JSON(value))
                print("Harassment types :\(harassmentTypes)")
                if let controller = self.from as? CreateReportTableController {
                    controller.harassmentTypes = harassmentTypes
                }
                if let controller = self.from as? MapViewController {
                    controller.updateHarassmentTypeList(harassmentTypes: harassmentTypes)
                }
            case .failure(let error):
                print("Error")
                print(error)
            }
        }

    }

    public func createReport(report: Report) {

        let url: String = self.baseURL + "reports"

        let jsonReport = self.apiFormatter.formatReportToJson(report: report)

        self.headers["Content-type"] = "application/json"

        Alamofire.request(url, method: .post, parameters: jsonReport.dictionaryObject!, encoding: JSONEncoding.default, headers: self.headers).validate().responseJSON { response in
            switch response.result {
            case .success( _):
                print("Success")
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

        print("JSON REPORT: \(jsonReport.dictionaryValue)")
    }
}
