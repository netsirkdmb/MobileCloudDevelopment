//
//  TypeOfSchoolViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/6/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import TNSwiftyCheckboxGroup

class TypeOfSchoolViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Properties
    var checkboxVC: TNSwiftyCheckboxViewController!
    var typeOfSchoolString: String = String()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if doneButton === sender {
             let typeOfSchoolCheckboxModelArray: [TNSwiftyCheckboxModel] = checkboxVC.checkedModels!
             var typeOfSchoolStringArray: [String] = [String]()
             for typeOfSchoolCheckboxModel in typeOfSchoolCheckboxModelArray {
                typeOfSchoolStringArray.append(typeOfSchoolCheckboxModel.name)
             }
             typeOfSchoolString = typeOfSchoolStringArray.joinWithSeparator(", ")
        }
        
        if (doneButton !== sender) {
            var checkboxModels: [TNSwiftyCheckboxModel] = []
            if let typeOfSchoolButtonString: String = globalTypeOfSchoolButton.currentTitle {
                let typeOfSchool = typeOfSchoolButtonString.componentsSeparatedByString(", ")
                checkboxModels = [
                    
                    TNSwiftyCheckboxModel(name: "Daycare", checked: typeOfSchool.contains("Daycare")),
                    TNSwiftyCheckboxModel(name: "Preschool", checked: typeOfSchool.contains("Preschool")),
                    TNSwiftyCheckboxModel(name: "Elementary School (K-5)", checked: typeOfSchool.contains("Elementary School (K-5)")),
                    TNSwiftyCheckboxModel(name: "Middle School (6-8)", checked: typeOfSchool.contains("Middle School (6-8)")),
                    TNSwiftyCheckboxModel(name: "High School (9-12)", checked: typeOfSchool.contains("High School (9-12)"))
                    
                ]
                
                checkboxVC = segue.destinationViewController as! TNSwiftyCheckboxViewController
                checkboxVC.type = .Image
                checkboxVC.checkboxModels = checkboxModels
            }
        }
        
    }    
}