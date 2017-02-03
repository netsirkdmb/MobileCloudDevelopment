//
//  Student.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/8/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class Student: NSObject {
    
    // MARK: Properties
    var _id: String?
    var studentName: String
    var grade: String
    var currentSchoolName: String?
    var currentSchoolID: String?
    var pastSchoolsName: [String]?
    var pastSchoolsID: [String]?
    var pastSchoolsDict: [String: String] = [:]
    
    // MARK: Initialization
    init?(_id: String?, studentName: String, grade: String, currentSchoolName: String?, currentSchoolID: String?, pastSchoolsName: [String]?,
          pastSchoolsID: [String]?, pastSchoolsDict: [String: String]) {
        // Initialize stored properties.
        if((_id) != nil) {
            self._id = _id
        }
        self.studentName = studentName
        self.grade = grade
        self.currentSchoolName = currentSchoolName
        self.currentSchoolID = currentSchoolID
        self.pastSchoolsName = pastSchoolsName
        self.pastSchoolsID = pastSchoolsID
        self.pastSchoolsDict = pastSchoolsDict
        
        super.init()
        
        // Initialization should fail if there is no studentName or grade.
        if studentName.isEmpty || grade.isEmpty {
            return nil
        }
    }
    
    init?(studentName: String, grade: String, currentSchoolName: String?, currentSchoolID: String?, pastSchoolsName: [String]?,
          pastSchoolsID: [String]?, pastSchoolsDict: [String: String]) {
        // Initialize stored properties.
        self.studentName = studentName
        self.grade = grade
        self.currentSchoolName = currentSchoolName
        self.currentSchoolID = currentSchoolID
        self.pastSchoolsName = pastSchoolsName
        self.pastSchoolsID = pastSchoolsID
        self.pastSchoolsDict = pastSchoolsDict
        
        super.init()
        
        // Initialization should fail if there is no studentName, grade, currentSchool(Name or ID), or pastSchools(Name or ID).
        if studentName.isEmpty || grade.isEmpty || currentSchoolName!.isEmpty || currentSchoolID!.isEmpty || pastSchoolsName!.isEmpty ||
            pastSchoolsID!.isEmpty {
            return nil
        }
    }
    
    func toJSON() -> NSData {
        var data: NSDictionary = NSDictionary()
        if (self._id != nil) {
            data = ["_id": self._id!,
                    "studentName": self.studentName,
                    "grade": self.grade,
                    "currentSchoolName": self.currentSchoolName!,
                    "currentSchoolST": self.currentSchoolID!,
                    "pastSchoolsName": self.pastSchoolsName!,
                    "pastSchoolsST": self.pastSchoolsID!]
        } else {
            data = ["studentName": self.studentName,
                    "grade": self.grade,
                    "currentSchoolName": self.currentSchoolName!,
                    "currentSchoolST": self.currentSchoolID!,
                    "pastSchoolsName": self.pastSchoolsName!,
                    "pastSchoolsST": self.pastSchoolsID!]
        }
        do {
            return try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch {
            return NSData()
        }
    }
}