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
        
        var reports: [Report] = []

        for (_,subJson):(String, JSON) in json.dictionary!["hydra:member"]! {
            let report = self.formatJsonIntoReport(json: subJson)
            reports.append(report)
        }

        return reports
    }

    func formatJsonIntoReport(json: JSON) -> Report {

        let reporterId = Int(json["reporter"].string!.replacingOccurrences(of: "/users/", with: ""))
        let report: Report = Report(reporter: reporterId!)
        report.harassment = self.formatJsonIntoHarassment(json: json["harassment"])
        report.type = self.formatReportTypeFromApiToModel(reportType: json["type"].int!)
        report.id = json["id"].int!

        return report
    }

    func formatJsonIntoHarassment(json: JSON) -> Harassment {

        var types: [HarassmentType] = []

        for (_,harassmentType):(String, JSON) in json["types"] {
            types.append(HarassmentType(label: harassmentType["label"].string!))
        }

        let harassment = Harassment()
        harassment.types = types
        harassment.location = self.formatJsonIntoLocation(json: json["location"])
        harassment.datetime = self.formatDateFromApiToModel(datetime: json["datetime"].string!)

        return harassment
    }
    
    func formatJsonIntoLocation(json: JSON) -> Location {
        let latitude = json["latitude"].double!
        let longitude = json["longitude"].double!

        return Location(latitude: latitude, longitude: longitude)
    }

    func formatDateFromApiToModel(datetime: String) -> String {
        return self.UTCToLocal(date: datetime)
    }

    func UTCToLocal(date:String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dateUTC = dateFormatter.date(from: date)

        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: dateUTC!)
    }

    func formatDateFromModelToJson(date: String) -> String {
        return self.localToUTC(date: date)
    }

    func localToUTC(date:String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current

        let dateLocal = dateFormatter.date(from: date)

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.string(from: dateLocal!)
    }

    func formatReportTypeFromApiToModel(reportType: Int) -> ReportType {
        switch reportType {
        case 1:
            return ReportType.Victim
        case 2:
            return ReportType.Witness
        default:
            return ReportType.Victim
        }
    }

    func formatJsonIntoHarassmentTypes(json: JSON) -> [HarassmentType]{

        var harassmentTypes: [HarassmentType] = []

        for (_,subJson):(String, JSON) in json.dictionary!["hydra:member"]! {
            let harassmentType: HarassmentType = self.formatJsonIntoHarassmentType(json: subJson)
            harassmentTypes.append(harassmentType)
        }

        return harassmentTypes
    }

    func formatJsonIntoHarassmentType(json: JSON) -> HarassmentType{
        return HarassmentType(id: json["id"].int!, label: json["label"].string!)
    }

    func formatReportToJson(report: Report) -> JSON {

        var json: JSON = JSON()

        json["reporter"].string = "/users/\(report.reporter)"
        json["type"].int = report.type?.rawValue
        json["harassment"] = self.formatHarassmentToJson(harassment: report.harassment)

        return json
    }

    func formatHarassmentToJson(harassment: Harassment) -> JSON {
        var json = JSON()

        json["datetime"].string = self.formatDateFromModelToJson(date: harassment.datetime!)
        json["location"] = self.formatLocationToJson(location: harassment.location)
        json["types"].arrayObject = self.formatHarassmentTypesToJson(harassmentTypes: harassment.types)

        if harassment.note != nil {
            json["note"].string = harassment.note
        }

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
