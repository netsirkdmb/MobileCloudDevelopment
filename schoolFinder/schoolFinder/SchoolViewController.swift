//
//  SchoolViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/21/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import CoreLocation

// These are global variables that can be accessed in any view controller
var globalTypeOfSchoolButton: UIButton = UIButton()
var globalForeignLanguagesTaughtButton: UIButton = UIButton()

class SchoolViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var typeOfSchoolButton: UIButton!
    @IBOutlet weak var pubOrPriSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var foreignLanguagesTaughtButton: UIButton!
    @IBOutlet weak var ratingPickerControl: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var locationButton: UIButton!
    /*
    This value is either passed by `SchoolTableViewController` in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new school.
    */
    var school: School?
    var pickerData: [Int] = [Int]()
    var pickerSelection: Int = 1
    var locationManager: CLLocationManager = CLLocationManager()
    var zip: String = "none"
    var defaultButtonTitleColor: UIColor = UIColor()
    var _id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        schoolNameTextField.delegate = self
        locationTextField.delegate = self
        
        // Connect data:
        self.ratingPickerControl.delegate = self
        self.ratingPickerControl.dataSource = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        globalTypeOfSchoolButton = typeOfSchoolButton
        globalForeignLanguagesTaughtButton = foreignLanguagesTaughtButton
        
        // Input data into picker array
        pickerData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        // Set up views if editing an existing School.
        if let school = school {
            navigationItem.title = school.schoolName
            schoolNameTextField.text = school.schoolName
            let typeOfSchoolString = school.typeOfSchool.joinWithSeparator(", ")
            typeOfSchoolButton.setTitle(typeOfSchoolString, forState: UIControlState.Normal)
            if(school.pubOrPri == "Public") {
                pubOrPriSegmentedControl.selectedSegmentIndex = 0
            } else {
                pubOrPriSegmentedControl.selectedSegmentIndex = 1
            }
            locationTextField.text = school.location
            let foreignLanguagesTaughtString = school.foreignLanguagesTaught?.joinWithSeparator(", ")
            foreignLanguagesTaughtButton.setTitle(foreignLanguagesTaughtString, forState: UIControlState.Normal)
            var defaultRowIndex = pickerData.indexOf(school.rating)
            if defaultRowIndex == nil {
                defaultRowIndex = 0
            }
            ratingPickerControl.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
            pickerSelection = school.rating
            _id = school._id!
        }
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(SchoolViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        // Enable the Save button only if the form has a valid School.
        isValidSchool()
        
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
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        pickerSelection = pickerData[row]
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        isValidSchool()
        if (textField == schoolNameTextField) {
            navigationItem.title = textField.text
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        let isPresentingInAddSchoolMode = presentingViewController is UITabBarController
        let isPresentingInEditSchoolMode = presentingViewController is UINavigationController
        
        if isPresentingInAddSchoolMode || isPresentingInEditSchoolMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func typeOfSchoolButton(sender: UIButton) {
        let vc = TypeOfSchoolViewController()
        navigationController?.showViewController(vc, sender: UIButton.self)
    }
    
    @IBAction func foreignLanguagesTaughtButton(sender: UIButton) {
        let vc = LanguagesViewController()
        navigationController?.showViewController(vc, sender: UIButton.self)
    }
    
    @IBAction func unwindToSchool(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? TypeOfSchoolViewController {
            let typeOfSchoolString: String = sourceViewController.typeOfSchoolString
            if(!typeOfSchoolString.isEmpty) {
                typeOfSchoolButton.setTitle(typeOfSchoolString, forState: UIControlState.Normal)
            } else {
                typeOfSchoolButton.setTitle("Choose Type(s) of School", forState: UIControlState.Normal)
            }
            isValidSchool()
        }
        if let sourceViewController = sender.sourceViewController as? LanguagesViewController {
            let foreignLanguagesTaughtString: String = sourceViewController.foreignLanguagesTaughtString
            if(!foreignLanguagesTaughtString.isEmpty) {
                foreignLanguagesTaughtButton.setTitle(foreignLanguagesTaughtString, forState: UIControlState.Normal)
            } else {
                foreignLanguagesTaughtButton.setTitle("Choose Foreign Language(s) Taught", forState: UIControlState.Normal)
            }
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let schoolName = schoolNameTextField.text ?? ""
            let typeOfSchool = typeOfSchoolButton.currentTitle!.componentsSeparatedByString(", ")
            var pubOrPri = ""
            if(pubOrPriSegmentedControl.selectedSegmentIndex == 0) {
                pubOrPri = "Public"
            } else {
                pubOrPri = "Private"
            }
            let location = locationTextField.text ?? ""
            let foreignLanguagesTaughtString = foreignLanguagesTaughtButton.currentTitle!
            var foreignLanguagesTaught: [String] = []
            if (foreignLanguagesTaughtString != "Choose Foreign Language(s) Taught") {
                foreignLanguagesTaught = foreignLanguagesTaughtButton.currentTitle!.componentsSeparatedByString(", ")
            }
            let rating = pickerSelection
            if(_id == "") {
                // Set the school to be passed to SchoolTableViewController after the unwind segue.
                school = School(schoolName: schoolName, typeOfSchool: typeOfSchool, pubOrPri: pubOrPri, location: location, foreignLanguagesTaught: foreignLanguagesTaught, rating: rating)
            } else {
                // Set the school to be passed to SchoolTableViewController after the unwind segue.
                school = School(_id: _id, schoolName: schoolName, typeOfSchool: typeOfSchool, pubOrPri: pubOrPri, location: location, foreignLanguagesTaught: foreignLanguagesTaught, rating: rating)
            }
        }
    }
    
    // MARK: Use Current Location Action
    @IBAction func getCurrentLocationButton(sender: UIButton) {
        self.defaultButtonTitleColor = locationButton.currentTitleColor
        self.locationManager.requestLocation()
        locationButton.setTitle("Getting Location...", forState: UIControlState.Normal)
        locationButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            break
        
        case .Restricted:
            print(".Restricted")
            break
            
        case .Denied:
            print(".Denied")
            break
        
        case .AuthorizedAlways:
            print(".AuthorizedAlways")
            break
        
        case .AuthorizedWhenInUse:
            print(".AuthorizedWhenInUse")
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        //finding address given the coordinates
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, e) -> Void in
            if e != nil {
                print("Error: \(e!.localizedDescription)")
            } else {
                let placemark = placemarks!.last! as CLPlacemark
                
                self.zip = placemark.postalCode!
                
                print("Location: \(self.zip)")
                
                self.locationTextField.text = self.zip
                self.locationButton.setTitle("Get Current Location", forState: UIControlState.Normal)
                self.locationButton.setTitleColor(self.defaultButtonTitleColor, forState: UIControlState.Normal)
                self.isValidSchool()
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    // MARK: School Validation
    func checkValidSchoolName() -> Bool {
        let text = schoolNameTextField.text ?? ""
        // returns true if the school has a name
        return !text.isEmpty
    }
    
    func checkValidTypeOfSchool() -> Bool {
        let title = typeOfSchoolButton.currentTitle ?? ""
        // returns true if the user has chosen a type of school
        return (title != "Choose Type(s) of School" && !title.isEmpty)
    }
    
    func checkValidLocation() -> Bool {
        let text: NSString = locationTextField.text ?? ""
        let validNumberCharacterSet = NSCharacterSet(charactersInString: "0123456789")
        let invalidNumberCharacterSet = validNumberCharacterSet.invertedSet
        let rangeOfInvalidCharacters = text.rangeOfCharacterFromSet(invalidNumberCharacterSet)
        let validZipCharacters = rangeOfInvalidCharacters.location == NSNotFound
        let validZip = validZipCharacters && (text.length == 5)
        // returns true if the location is 5 numerical digits long
        return validZip
    }
    
    func isValidSchool() {
        let validSchool = checkValidSchoolName() && checkValidTypeOfSchool() && checkValidLocation()
        saveButton.enabled = validSchool
    }
    
}

