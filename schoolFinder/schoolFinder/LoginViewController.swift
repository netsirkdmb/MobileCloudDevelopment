//
//  LoginViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/11/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

var globalUsername: String = String()
var globalPassword: String = String()

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field's user input through delegate callbacks.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Do any additional setup after loading the view.
        usernameTextField.text = ""
        passwordTextField.text = ""
        globalUsername = usernameTextField.text!
        globalPassword = passwordTextField.text!
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
        loginButton.enabled = false
        signupButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == usernameTextField {
            globalUsername = usernameTextField.text!
        } else if textField == passwordTextField {
            globalPassword = passwordTextField.text!
        }
        signupButton.enabled = true
        if !globalUsername.isEmpty && !globalPassword.isEmpty {
            loginButton.enabled = true
        }
    }

    // MARK: - Navigation
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
        // Logout of database
        usernameTextField.text = ""
        passwordTextField.text = ""
        globalUsername = usernameTextField.text!
        globalPassword = passwordTextField.text!
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
