//
//  HarassmentType.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class HarassmentType: NSObject, NSCoding {

    var id: Int!
    var label: String

    init(label: String) {
        self.label = label
    }

    init(id: Int, label: String) {
        self.label = label
        self.id = id
    }

    required init?(coder aDecoder: NSCoder) {
        self.label = aDecoder.decodeObject(forKey: "label") as! String
        self.id = aDecoder.decodeObject(forKey: "id") as! Int

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: "label")
        aCoder.encode(id, forKey: "id")
    }
}
