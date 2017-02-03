//
//  School.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class School: NSObject {
    
    // MARK: Properties
    var _id: String?
    var schoolName: String
    var typeOfSchool: [String]
    var pubOrPri: String
    var location: String
    var foreignLanguagesTaught: [String]?
    var rating: Int
    
    // MARK: Initialization
    init?(_id: String?, schoolName: String, typeOfSchool: [String], pubOrPri: String, location: String, foreignLanguagesTaught: [String]?, rating: Int) {
        // Initialize stored properties.
        if((_id) != nil) {
            self._id = _id
        }
        self.schoolName = schoolName
        self.typeOfSchool = typeOfSchool
        self.pubOrPri = pubOrPri
        self.location = location
        self.foreignLanguagesTaught = foreignLanguagesTaught
        self.rating = rating
        
        super.init()
        
        // Initialization should fail if there is no schoolName, typeOfSchool, pubOrPri, or location, or if the rating is negative.
        if schoolName.isEmpty || typeOfSchool.isEmpty || pubOrPri.isEmpty || location.isEmpty || rating < 0 {
            return nil
        }
    }
    
    init?(schoolName: String, typeOfSchool: [String], pubOrPri: String, location: String, foreignLanguagesTaught: [String]?, rating: Int) {
        // Initialize stored properties.
        self.schoolName = schoolName
        self.typeOfSchool = typeOfSchool
        self.pubOrPri = pubOrPri
        self.location = location
        self.foreignLanguagesTaught = foreignLanguagesTaught
        self.rating = rating
        
        super.init()
        
        // Initialization should fail if there is no schoolName, typeOfSchool, pubOrPri, or location, or if the rating is negative.
        if schoolName.isEmpty || typeOfSchool.isEmpty || pubOrPri.isEmpty || location.isEmpty || rating < 0 {
            return nil
        }
    }
    
    func toJSON() -> NSData {
        var data: NSDictionary = NSDictionary()
        if (self._id != nil) {
            data = ["_id": self._id!,
                    "schoolName": self.schoolName,
                    "typeOfSchool": self.typeOfSchool,
                    "pubOrPri": self.pubOrPri,
                    "location": self.location,
                    "foreignLanguagesTaught": self.foreignLanguagesTaught!,
                    "rating": self.rating]
        } else {
            data = ["schoolName": self.schoolName,
                    "typeOfSchool": self.typeOfSchool,
                    "pubOrPri": self.pubOrPri,
                    "location": self.location,
                    "foreignLanguagesTaught": self.foreignLanguagesTaught!,
                    "rating": self.rating]
        }
        do {
            return try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch {
            return NSData()
        }
    }
}