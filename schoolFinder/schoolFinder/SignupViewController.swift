//
//  SignupViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/11/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var signupUsernameTextField: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        signupUsernameTextField.delegate = self
        signupPasswordTextField.delegate = self
        
        // Do any additional setup after loading the view.
        signupUsernameTextField.text = ""
        signupPasswordTextField.text = ""
        globalUsername = signupUsernameTextField.text!
        globalPassword = signupPasswordTextField.text!
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
        signupButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == signupUsernameTextField {
            globalUsername = signupUsernameTextField.text!
        } else if textField == signupPasswordTextField {
            globalPassword = signupPasswordTextField.text!
        }
        if !globalUsername.isEmpty && !globalPassword.isEmpty {
            signupButton.enabled = true
        }
    }
    
    // MARK: - Navigation
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        createAccount(globalUsername, password: globalPassword)
    }
    
    // MARK: - API: Create Account
    func createAccount(username: String, password: String) {
        // check that URL is valid and setup URL request
        let createAccountEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/createAccount"
        guard let url = NSURL(string: createAccountEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        
        var user: NSDictionary = NSDictionary()
        user = ["username": username, "password": password]
        do {
            let jsonUser = try NSJSONSerialization.dataWithJSONObject(user, options: [])
            urlRequest.HTTPBody = jsonUser
            urlRequest.allHTTPHeaderFields!["Content-Type"] = "application/json"
        } catch {
            return
        }
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            
            // check for any errors
            guard message == nil else {
                print("error calling POST on /createAccount")
                print(message)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let userJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the userJSON object is a dictionary
                if (userJSON["message"] != "Account successfully created.") {
                    print("error trying to create account")
                    return
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
}
