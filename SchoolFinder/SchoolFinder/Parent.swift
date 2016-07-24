//
//  Parent.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class Parent: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String
    var students: [String]?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory,inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("parents")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let studentsKey = "students"
    }
    
    // MARK: Initialization
    init?(name: String, students: [String]?) {
        // Initialize stored properties.
        self.name = name
        self.students = students
        
        super.init()
        
        // Initialization should fail if there is no name.
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(students, forKey: PropertyKey.studentsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because students is an optional property of Parent, use conditional cast.
        let students = aDecoder.decodeObjectForKey(PropertyKey.studentsKey) as? [String]
        
        // Must call designated initializer.
        self.init(name: name, students: students)
    }
}