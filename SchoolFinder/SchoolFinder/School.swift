//
//  School.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class School: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String
    var type: [String]
    var pubOrPri: String
    var location: String
    var language: [String]?
    var rating: Int?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory,inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("schools")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let typeKey = "type"
        static let pubOrPriKey = "pubOrPri"
        static let locationKey = "location"
        static let languageKey = "language"
        static let ratingKey = "rating"
    }
    
    // MARK: Initialization
    init?(name: String, type: [String], pubOrPri: String, location: String, language: [String]?, rating: Int) {
        // Initialize stored properties.
        self.name = name
        self.type = type
        self.pubOrPri = pubOrPri
        self.location = location
        self.language = language
        self.rating = rating
        
        super.init()
        
        // Initialization should fail if there is no name, type, pubOrPri, location, or if the rating is negative.
        if name.isEmpty || type.isEmpty || pubOrPri.isEmpty || location.isEmpty || rating < 0 {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
        aCoder.encodeObject(pubOrPri, forKey: PropertyKey.pubOrPriKey)
        aCoder.encodeObject(location, forKey: PropertyKey.locationKey)
        aCoder.encodeObject(language, forKey: PropertyKey.languageKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let type = aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! [String]
        
        let pubOrPri = aDecoder.decodeObjectForKey(PropertyKey.pubOrPriKey) as! String
        
        let location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as! String
        
        // Because language is an optional property of School, use conditional cast.
        let language = aDecoder.decodeObjectForKey(PropertyKey.languageKey) as? [String]
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        // Must call designated initializer.
        self.init(name: name, type: type, pubOrPri: pubOrPri, location: location, language: language, rating: rating)
    }
}