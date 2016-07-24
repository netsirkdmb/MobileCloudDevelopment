//
//  ParentViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var parentNameTextField: UITextField!
    @IBOutlet weak var studentsControl: StudentsControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by `ParentTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new parent.
     */
    var parent: Parent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        parentNameTextField.delegate = self
        
        // Set up views if editing an existing Parent.
        if let parent = parent {
            navigationItem.title = parent.name
            parentNameTextField.text = parent.name
            studentsControl.text = parent.students
        }
        
        // Enable the Save button only if the parent has a valid name.
        checkValidParent()
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
    
    func checkValidParentName() -> Bool {
        // Return true if the text field is not empty.
        let text = parentNameTextField.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidParent() {
        let isValidParent = checkValidParentName()
        
        saveButton.enabled = isValidParent
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveButton.enabled = checkValidParentName()
        navigationItem.title = textField.text
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        let isPresentingInAddParentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddParentMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = parentNameTextField.text ?? ""
            let students = studentsControl.text
            
            // Set the parent to be passed to ParentTableViewController after the unwind segue.
            parent = Parent(name: name, students: students)
        }
    }
    
}
