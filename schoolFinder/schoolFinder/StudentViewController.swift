//
//  StudentViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/8/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

// These are global variables that can be accessed in any view controller
var globalCurrentSchoolString: String = String()
var globalPastSchoolsButton: UIButton = UIButton()
var globalPastSchoolsDict: [String: String] = [:]
var globalIsReturningFromPastSchoolsCheckboxes: Bool = Bool()

class StudentViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var pastSchoolsButton: UIButton!
    @IBOutlet weak var gradePickerControl: UIPickerView!
    @IBOutlet weak var currentSchoolPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by `StudentDetailViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new student.
     */
    var student: Student?
    var gradePickerData: [String] = [String]()
    var gradePickerSelection: String = "Daycare"
    var currentSchoolPickerData: [String] = [String]()
    var _id: String = ""
    var currentSchoolID: String = ""
    var pastSchoolsID: [String] = [String]()
    var pastSchoolsDict: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        studentNameTextField.delegate = self
        
        // Connect data:
        self.gradePickerControl.delegate = self
        self.gradePickerControl.dataSource = self
        self.currentSchoolPicker.delegate = self
        self.currentSchoolPicker.dataSource = self
        
        globalIsReturningFromPastSchoolsCheckboxes = false
        
        // Input data into picker array
        gradePickerData = ["Daycare", "Preschool", "K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        
        // Enable the Save button only if the form has a valid Student.
        isValidStudent()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load data about schools every time you change to this view to reflect changes to school data
        globalPastSchoolsButton = pastSchoolsButton
        globalPastSchoolsDict = pastSchoolsDict
        
        if !globalIsReturningFromPastSchoolsCheckboxes {
            currentSchoolPickerData = Array(globalSchoolsDict.keys)
            globalCurrentSchoolString = currentSchoolPickerData[0]
            currentSchoolID = globalSchoolsDict[globalCurrentSchoolString]!
            
            // Set up views if editing an existing Student.
            if let student = student {
                navigationItem.title = student.studentName
                studentNameTextField.text = student.studentName
                var currentSchoolDefaultRowIndex = currentSchoolPickerData.indexOf(student.currentSchoolName!)
                if currentSchoolDefaultRowIndex == nil {
                    currentSchoolDefaultRowIndex = 0
                    currentSchoolID = globalSchoolsDict[currentSchoolPickerData[0]]!
                } else {
                    currentSchoolID = student.currentSchoolID!
                }
                currentSchoolPicker.selectRow(currentSchoolDefaultRowIndex!, inComponent: 0, animated: false)
                globalCurrentSchoolString = currentSchoolPickerData[currentSchoolDefaultRowIndex!]
                if student.pastSchoolsName! == [] {
                    pastSchoolsButton.setTitle("Choose Past School(s)", forState: UIControlState.Normal)
                } else {
                    let pastSchoolsNameString = student.pastSchoolsName!.joinWithSeparator(", ")
                    pastSchoolsButton.setTitle(pastSchoolsNameString, forState: UIControlState.Normal)
                }
                pastSchoolsID = student.pastSchoolsID!
                var gradeDefaultRowIndex = gradePickerData.indexOf(student.grade)
                if gradeDefaultRowIndex == nil {
                    gradeDefaultRowIndex = 0
                }
                gradePickerControl.selectRow(gradeDefaultRowIndex!, inComponent: 0, animated: false)
                gradePickerSelection = student.grade
                _id = student._id!
            }
        }
        
        // Enable the Save button only if the form has a valid Student.
        isValidStudent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK UIPickerViewDelegate
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count: Int = Int()
        if pickerView == gradePickerControl {
            count = gradePickerData.count
        } else if pickerView == currentSchoolPicker {
            count = currentSchoolPickerData.count
        }
        return count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerData: String = String()
        if pickerView == gradePickerControl {
            pickerData = String(gradePickerData[row])
        } else if pickerView == currentSchoolPicker {
            pickerData = String(currentSchoolPickerData[row])
        }
        return pickerData
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if pickerView == gradePickerControl {
            gradePickerSelection = gradePickerData[row]
        } else if pickerView == currentSchoolPicker {
            globalCurrentSchoolString = currentSchoolPickerData[row]
            currentSchoolID = globalSchoolsDict[globalCurrentSchoolString]!
        }
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        isValidStudent()
        navigationItem.title = textField.text
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        let isPresentingInAddStudentMode = presentingViewController is UITabBarController
        let isPresentingInEditStudentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddStudentMode || isPresentingInEditStudentMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func pastSchoolsButton(sender: UIButton) {
        let vc = PastSchoolsCheckboxViewController()
        navigationController?.showViewController(vc, sender: UIButton.self)
    }
    
    @IBAction func unwindToStudent(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PastSchoolsCheckboxViewController {
            let pastSchoolsString: String = sourceViewController.pastSchoolsString
            if(!pastSchoolsString.isEmpty && pastSchoolsString != "Choose Past School(s)") {
                pastSchoolsButton.setTitle(pastSchoolsString, forState: UIControlState.Normal)
                let pastSchoolsNameArray = pastSchoolsString.componentsSeparatedByString(", ")
                self.pastSchoolsID.removeAll()
                self.pastSchoolsDict.removeAll()
                for pastSchool in pastSchoolsNameArray {
                    self.pastSchoolsID.append(globalSchoolsDict[pastSchool]!)
                    self.pastSchoolsDict[pastSchool] = globalSchoolsDict[pastSchool]
                }
            } else {
                pastSchoolsButton.setTitle("Choose Past School(s)", forState: UIControlState.Normal)
                self.pastSchoolsID = []
                self.pastSchoolsDict.removeAll()
            }
        }
        isValidStudent()
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let studentName = studentNameTextField.text ?? ""
            let grade = gradePickerSelection
            let currentSchoolName = globalCurrentSchoolString
            let currentSchoolID = self.currentSchoolID
            let pastSchoolsName = pastSchoolsButton.currentTitle!.componentsSeparatedByString(", ")
            let pastSchoolsID = self.pastSchoolsID
            let pastSchoolsDict = self.pastSchoolsDict
            if(_id == "") {
                // Set the student to be passed to StudentTableViewController after the unwind segue.
                student = Student(studentName: studentName, grade: grade, currentSchoolName: currentSchoolName, currentSchoolID: currentSchoolID, pastSchoolsName: pastSchoolsName,
                                  pastSchoolsID: pastSchoolsID, pastSchoolsDict: pastSchoolsDict)
            } else {
                // Set the school to be passed to StudentTableViewController after the unwind segue.
                student = Student(_id: _id, studentName: studentName, grade: grade, currentSchoolName: currentSchoolName, currentSchoolID: currentSchoolID, pastSchoolsName: pastSchoolsName,
                                pastSchoolsID: pastSchoolsID, pastSchoolsDict: pastSchoolsDict)
            }
            globalIsReturningFromPastSchoolsCheckboxes = false
        }
        
    }
    
    // MARK: Student Validation
    func checkValidStudentName() -> Bool {
        let text = studentNameTextField.text ?? ""
        // returns true if the student has a name
        return !text.isEmpty
    }
    
    func checkValidPastSchools() -> Bool {
        let title = pastSchoolsButton.currentTitle ?? ""
        // returns true if the user has chosen past schools
        return (title != "Choose Past School(s)" && !title.isEmpty)
    }
    
    func isValidStudent() {
        let validStudent = checkValidStudentName() && checkValidPastSchools()
        saveButton.enabled = validStudent
    }
    
}
