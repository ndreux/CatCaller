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
        report.id = json["id"].int!

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

        // TODO: Manage TimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        print("formatJsonIntoLocation - END")

        return dateFormatter.date(from: datetime)!
    }

    func formatDateFromModelToJson(date: Date) -> String {

        // TODO: Manage TimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        print("formatJsonIntoLocation - END")

        return dateFormatter.string(from: date)
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

        print("formatJsonIntoHarassmentTypes - START")
        print("formatJsonIntoHarassmentTypes - JSON \(json)")
        var harassmentTypes: [HarassmentType] = []

        for (_,subJson):(String, JSON) in json.dictionary!["hydra:member"]! {
            let harassmentType: HarassmentType = self.formatJsonIntoHarassmentType(json: subJson)
            harassmentTypes.append(harassmentType)
        }
        print("formatJsonIntoHarassmentTypes - END")

        return harassmentTypes
    }

    func formatJsonIntoHarassmentType(json: JSON) -> HarassmentType{

        print("formatJsonIntoHarassmentType - START")
        print("formatJsonIntoHarassmentType - JSON \(json)")

        let harassmentType: HarassmentType = HarassmentType(id: json["id"].int!, label: json["label"].string!)
        print("formatJsonIntoHarassmentType - END")

        return harassmentType
    }

    func formatReportToJson(report: Report) -> JSON {

        var json: JSON = JSON()

        json["reporter"].string = "/users/1"
        json["type"].int = report.type == "Victim" ? 1 : 2
        json["harassment"] = self.formatHarassmentToJson(harassment: report.harassment)

        return json
    }

    func formatHarassmentToJson(harassment: Harassment) -> JSON {
        var json = JSON()

        json["datetime"].string = self.formatDateFromModelToJson(date: harassment.datetime)
        json["location"] = self.formatLocationToJson(location: harassment.location)
        json["types"].arrayObject = self.formatHarassmentTypesToJson(harassmentTypes: harassment.types)
        json["note"].string = harassment.note

        return json
    }

    func formatLocationToJson(location: Location) -> JSON {

        var json: JSON = JSON()
        json["latitude"].string = String(location.latitude)
        json["longitude"].string = String(location.longitude)

        return json
    }

    func formatHarassmentTypesToJson(harassmentTypes: [HarassmentType]) -> [String] {
        let harassmentTypeUrl: String = "/harassment_types"
        var harassmentTypesArray: [String] = [String]()

        for harassmentType in harassmentTypes {
            harassmentTypesArray.append("\(harassmentTypeUrl)/\(harassmentType.id!)")
        }

        return harassmentTypesArray
    }
}
