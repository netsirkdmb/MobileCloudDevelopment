//
//  LanguagesViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/6/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import TNSwiftyCheckboxGroup

class LanguagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Properties
    var checkboxVC: TNSwiftyCheckboxViewController!
    var foreignLanguagesTaughtString: String = String()
    
    // MARK: - Initializers methods
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if doneButton === sender {
            let foreignLanguagesTaughtCheckboxModelArray: [TNSwiftyCheckboxModel] = checkboxVC.checkedModels!
            var foreignLanguagesTaughtStringArray: [String] = [String]()
            for foreignLanguagesTaughtCheckboxModel in foreignLanguagesTaughtCheckboxModelArray {
                foreignLanguagesTaughtStringArray.append(foreignLanguagesTaughtCheckboxModel.name)
            }
            foreignLanguagesTaughtString = foreignLanguagesTaughtStringArray.joinWithSeparator(", ")
        }
        
        if (doneButton !== sender) {
            var checkboxModels: [TNSwiftyCheckboxModel] = []
            if let foreignLanguagesTaughtButtonString: String = globalForeignLanguagesTaughtButton.currentTitle {
                let foreignLanguagesTaught = foreignLanguagesTaughtButtonString.componentsSeparatedByString(", ")
                checkboxModels = [
                        
                    TNSwiftyCheckboxModel(name: "Spanish", checked: foreignLanguagesTaught.contains("Spanish")),
                    TNSwiftyCheckboxModel(name: "French", checked: foreignLanguagesTaught.contains("French")),
                    TNSwiftyCheckboxModel(name: "German", checked: foreignLanguagesTaught.contains("German")),
                    TNSwiftyCheckboxModel(name: "Japanese", checked: foreignLanguagesTaught.contains("Japanese")),
                    TNSwiftyCheckboxModel(name: "Mandarin", checked: foreignLanguagesTaught.contains("Mandarin"))
                    
                ]
                
                checkboxVC = segue.destinationViewController as! TNSwiftyCheckboxViewController
                checkboxVC.type = .Image
                checkboxVC.checkboxModels = checkboxModels
            }
        }
        
    }
    
}