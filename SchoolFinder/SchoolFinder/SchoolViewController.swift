//
//  SchoolViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SchoolViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var typeOfSchoolControl: TypeOfSchoolControl!
    @IBOutlet weak var pubPriControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var foreighLanguagesControl: ForeignLanguagesTaughtControl!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by `SchoolTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new school.
     */
    var school: School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        schoolNameTextField.delegate = self
        
        // Set up views if editing an existing School.
        if let school = school {
            navigationItem.title = school.name
            schoolNameTextField.text = school.name
            // typeOfSchoolControl.?? = school.type[]???
            // pubPriControl.text = school.pubOrPri
            locationTextField.text = school.location
            // foreignLanguagesControl.?? = school.language[]???
            ratingControl.rating = school.rating
        }
        
        // Enable the Save button only if the school has a valid name, type, pub/pri, zip, and rating.
        checkValidSchool()
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
    
    func checkValidSchoolName() -> Bool {
        // Return true if the text field is not empty.
        let text = schoolNameTextField.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidSchoolType() -> Bool {
        // Return true if the type field is not empty.
        let type = typeOfSchoolControl.text ?? ""
        return !type.isEmpty
    }
    
    func checkValidSchoolPubPri() -> Bool {
        // Return true if the pub/pri field is not empty.
        let text = pubPriControl.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidSchoolLocation() -> Bool {
        // Return true if the location field is not empty.
        let text = locationTextField.text ?? ""
        return !text.isEmpty
    }
    
    func checkValidSchoolRating() -> Bool {
        // Return true if the rating field is not empty.
        let rating = ratingControl.rating ?? nil
        return !rating.isNil
    }
    
    func checkValidSchool() {
        let isValidSchool = checkValidSchoolName() && checkValidSchoolType() && checkValidSchoolPubPri() && checkValidSchoolLocation() && checkValidSchoolRating()
        
        saveButton.enabled = isValidSchool
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveButton.enabled = checkValidSchoolName()
        navigationItem.title = textField.text
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        let isPresentingInAddSchoolMode = presentingViewController is UINavigationController
        
        if isPresentingInAddSchoolMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = schoolNameTextField.text ?? ""
            // let type = typeOfSchoolControl.??
            // let pubOrPri = pubPriControl.text
            let location = locationTextField.text
            // let language = foreignLanguagesControl.???
            let rating = ratingControl.rating
            
            // Set the school to be passed to SchoolTableViewController after the unwind segue.
            school = School(name: name, type: type, pubOrPri: pubOrPri, location: location, language: language, rating: rating)
        }
    }

}