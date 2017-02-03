//
//  PastSchoolsCheckboxViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/8/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import TNSwiftyCheckboxGroup

class PastSchoolsCheckboxViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Properties
    var checkboxVC: TNSwiftyCheckboxViewController!
    var pastSchoolsString: String = String()
    var student: Student?
    
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
            let pastSchoolsCheckboxModelArray: [TNSwiftyCheckboxModel] = checkboxVC.checkedModels!
            var pastSchoolsStringArray: [String] = [String]()
            for pastSchoolsCheckboxModel in pastSchoolsCheckboxModelArray {
                pastSchoolsStringArray.append(pastSchoolsCheckboxModel.name)
            }
            pastSchoolsString = pastSchoolsStringArray.joinWithSeparator(", ")
            
            globalIsReturningFromPastSchoolsCheckboxes = true
        }
        
        if (doneButton !== sender) {
            var checkboxModels: [TNSwiftyCheckboxModel] = []
            if let pastSchoolsButtonString: String = globalPastSchoolsButton.currentTitle {
                let pastSchools = pastSchoolsButtonString.componentsSeparatedByString(", ")
                for (key, _) in globalSchoolsDict {
                    checkboxModels.append(TNSwiftyCheckboxModel(name: key, checked: pastSchools.contains(key)))
                }
                
                checkboxVC = segue.destinationViewController as! TNSwiftyCheckboxViewController
                checkboxVC.type = .Image
                checkboxVC.checkboxModels = checkboxModels
            }
        }
        
    }
}