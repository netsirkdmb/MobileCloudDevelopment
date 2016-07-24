//
//  Student.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class Student: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String
    var grade: String
    var currentSchool: String
    var pastSchools: [String]
    var parents: [String]?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory,inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("students")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let gradeKey = "grade"
        static let currentSchoolKey = "currentSchool"
        static let pastSchoolsKey = "pastSchools"
        static let parentsKey = "parent"
    }
    
    // MARK: Initialization
    init?(name: String, grade: String, currentSchool: String, pastSchools: [String], parents: [String]?) {
        // Initialize stored properties.
        self.name = name
        self.grade = grade
        self.currentSchool = currentSchool
        self.pastSchools = pastSchools
        self.parents = parents
        
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || grade.isEmpty || currentSchool.isEmpty || pastSchools.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(grade, forKey: PropertyKey.gradeKey)
        aCoder.encodeObject(currentSchool, forKey: PropertyKey.currentSchoolKey)
        aCoder.encodeObject(pastSchools, forKey: PropertyKey.pastSchoolsKey)
        aCoder.encodeObject(parents, forKey: PropertyKey.parentsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let grade = aDecoder.decodeObjectForKey(PropertyKey.gradeKey) as! String
        
        let currentSchool = aDecoder.decodeObjectForKey(PropertyKey.currentSchoolKey) as! String
        
        let pastSchools = aDecoder.decodeObjectForKey(PropertyKey.pastSchoolsKey) as! [String]
        
        // Because parents is an optional property of Student, use conditional cast.
        let parents = aDecoder.decodeObjectForKey(PropertyKey.parentsKey) as? [String]
        
        // Must call designated initializer.
        self.init(name: name, grade: grade, currentSchool: currentSchool, pastSchools: pastSchools, parents: parents)
    }
}