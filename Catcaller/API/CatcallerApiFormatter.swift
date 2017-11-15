//
//  CatcallerApiFormatter.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 09/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation
import SwiftyJSON

class CatcallerApiFormatter {

    func formatJsonIntoReports(json: JSON) -> [Report] {
        print("formatJsonIntoReports - START")
        print("formatJsonIntoReports - JSON \(json)")
        var reports: [Report] = []

        print("JSON DICTIONNARY : \(json.dictionary!["hydra:member"]!)")

        for (_,subJson):(String, JSON) in json.dictionary!["hydra:member"]! {
            let report = self.formatJsonIntoReport(json: subJson)
            reports.append(report)
        }
        print("formatJsonIntoReports - END")
        return reports
    }

    func formatJsonIntoReport(json: JSON) -> Report {
        print("formatJsonIntoReport - START")
        print("formatJsonIntoReport - JSON \(json)")
        let report: Report = Report()
        report.harassment = self.formatJsonIntoHarassment(json: json["harassment"])
        report.type = self.formatReportTypeFromApiToModel(reportType: json["type"].int!)

        print("formatJsonIntoReport - END")
        return report
    }

    func formatJsonIntoHarassment(json: JSON) -> Harassment {

        print("formatJsonIntoHarassment - START")
        print("formatJsonIntoHarassment - JSON \(json)")

        var types: [HarassmentType] = []

        for (_,harassmentType):(String, JSON) in json["types"] {
            types.append(HarassmentType(label: harassmentType["label"].string!))
        }

        let harassment = Harassment()
        harassment.types = types
        harassment.location = self.formatJsonIntoLocation(json: json["location"])
        harassment.datetime = self.formatDateFromApiToModel(datetime: json["datetime"].string!)
        print("formatJsonIntoHarassment - END")

        return harassment
    }
    
    func formatJsonIntoLocation(json: JSON) -> Location {

        print("formatJsonIntoLocation - START")
        print("formatJsonIntoLocation - JSON \(json)")

        let latitude = json["latitude"].double!
        let longitude = json["longitude"].double!

        print("formatJsonIntoLocation - END")
        return Location(latitude: latitude, longitude: longitude)
    }

    func formatDateFromApiToModel(datetime: String) -> Date {

        print("formatJsonIntoLocation - START")


        // toto - Manage TimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        print("formatJsonIntoLocation - END")

        return dateFormatter.date(from: datetime)!

    }

    func formatReportTypeFromApiToModel(reportType: Int) -> String {
        switch reportType {
        case 1:
            return "Victim"
        case 2:
            return "Witness"
        default:
            return "Victim"
        }
    }

    func formatJsonIntoHarassmentTypes(json: JSON) -> [HarassmentType]{

        let harassmentTypes: [HarassmentType] = []

        return harassmentTypes
    }

}
