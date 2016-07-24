//
//  StudentViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class StudentViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var gradeControl: GradeControl!
    @IBOutlet weak var currentSchoolControl: CurrentSchoolControl!
    @IBOutlet weak var pastSchoolsControl: PastSchoolsControl!
    @IBOutlet weak var parentsControl: ParentsControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by `StudentTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new student.
     */
    var student: Student?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        studentNameTextField.delegate = self
        
        // Set up views if editing an existing Student.
        if let student = student {
            navigationItem.title = student.name
            studentNameTextField.text = student.name
            gradeControl.text = student.grade
            currentSchoolControl.text = student.currentSchool
            pastSchoolsControl.text = student.pastSchools
            parentsControl.text = student.parents
        }
        
        // Enable the Save button only if the student has a valid name, grade, currentSchool, and pastSchools.
        checkValidStudent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidStudentName() -> Bool {
        // Return true if the text field is not empty.
        let text = studentNameTextField.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidStudentGrade() -> Bool {
        // Return true if the grade field is not empty.
        let grade = gradeControl.text ?? ""
        return !grade.isEmpty
    }
    
    func checkValidStudentCurrentSchool() -> Bool {
        // Return true if the currentSchool field is not empty.
        let text = currentSchoolControl.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidStudentPastSchools() -> Bool {
        // Return true if the pastSchools field is not empty.
        let text = pastSchoolsControl.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidStudent() {
        let isValidStudent = checkValidStudentName() && checkValidStudentGrade() && checkValidStudentCurrentSchool() && checkValidStudentPastSchools()
        
        saveButton.enabled = isValidStudent
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveButton.enabled = checkValidStudentName()
        navigationItem.title = textField.text
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        let isPresentingInAddStudentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddStudentMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = studentNameTextField.text ?? ""
            let grade = gradeControl.text
            let currentSchool = currentSchoolControl.text
            let pastSchools = pastSchoolsControl.text
            let parents = parentsControl.text
            
            // Set the student to be passed to StudentTableViewController after the unwind segue.
            student = Student(name: name, grade: grade, currentSchool: currentSchool, pastSchools: pastSchools, parents: parents)
        }
    }

}

