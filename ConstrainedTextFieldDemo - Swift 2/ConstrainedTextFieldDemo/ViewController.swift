//
//  ViewController.swift
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

  // MARK: Outlets
  
  @IBOutlet weak var vowelsOnlyTextField: UITextField!
  @IBOutlet weak var noVowelsTextField: UITextField!
  @IBOutlet weak var digitsOnlyTextField: UITextField!
  @IBOutlet weak var numericOnlyTextField: UITextField!
  @IBOutlet weak var positiveIntegersOnlyTextField: UITextField!
  
  
  // MARK: View events and related methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeTextFields()
  }

  // Designate this class as the text fields' delegate
  // and set their keyboards while we're at it.
  func initializeTextFields() {
    vowelsOnlyTextField.delegate = self
    vowelsOnlyTextField.keyboardType = UIKeyboardType.ASCIICapable

    noVowelsTextField.delegate = self
    noVowelsTextField.keyboardType = UIKeyboardType.ASCIICapable
    
    digitsOnlyTextField.delegate = self
    digitsOnlyTextField.keyboardType = UIKeyboardType.NumberPad
    
    numericOnlyTextField.delegate = self
    numericOnlyTextField.keyboardType = UIKeyboardType.NumbersAndPunctuation
    
    positiveIntegersOnlyTextField.delegate = self
    positiveIntegersOnlyTextField.keyboardType = UIKeyboardType.DecimalPad
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // Tap outside a text field to dismiss the keyboard
  // ------------------------------------------------
  // By changing the underlying class of the view from UIView to UIControl,
  // the view can respond to events, including Touch Down, which is
  // wired to this method.
  @IBAction func userTappedBackground(sender: AnyObject) {
    view.endEditing(true)
  }
  
  
  // MARK: UITextFieldDelegate events and related methods
  
  func textField(textField: UITextField,
                 shouldChangeCharactersInRange range: NSRange,
                 replacementString string: String)
       -> Bool
  {
    // We ignore any change that doesn't add characters to the text field.
    // These changes are things like character deletions and cuts, as well
    // as moving the insertion point.
    //
    // We still return true to allow the change to take place.
    if string.characters.count == 0 {
      return true
    }
    
    // Check to see if the text field's contents still fit the constraints
    // with the new content added to it.
    // If the contents still fit the constraints, allow the change
    // by returning true; otherwise disallow the change by returning false.
    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
  
    switch textField {
    
      // Allow only upper- and lower-case vowels in this field,
      // and limit its contents to a maximum of 6 characters.
      case vowelsOnlyTextField:
        return prospectiveText.containsOnlyCharactersIn("aeiouAEIOU") &&
               prospectiveText.characters.count <= 6

      // Allow any characters EXCEPT upper- and lower-case vowels in this field,
      // and limit its contents to a maximum of 8 characters.
      case noVowelsTextField:
        return prospectiveText.doesNotContainCharactersIn("aeiouAEIOU") &&
               prospectiveText.characters.count <= 8
        
      // Allow only digits in this field, 
      // and limit its contents to a maximum of 3 characters.
      case digitsOnlyTextField:
        return prospectiveText.containsOnlyCharactersIn("0123456789") &&
               prospectiveText.characters.count <= 3
        
      // Allow only values that evaluate to proper numeric values in this field,
      // and limit its contents to a maximum of 7 characters.
      case numericOnlyTextField:
        return prospectiveText.isNumeric() &&
               prospectiveText.characters.count <= 7
        
      // In this field, allow only values that evalulate to proper numeric values and
      // do not contain the "-" and "e" characters, nor the decimal separator character
      // for the current locale. Limit its contents to a maximum of 5 characters.
      case positiveIntegersOnlyTextField:
        let decimalSeparator = NSLocale.currentLocale().objectForKey(NSLocaleDecimalSeparator) as! String
        return prospectiveText.isNumeric() &&
               prospectiveText.doesNotContainCharactersIn("-e" + decimalSeparator) &&
               prospectiveText.characters.count <= 5
        
      // Do not put constraints on any other text field in this view
      // that uses this class as its delegate.
      default:
        return true
    }
    
  }
  
  // Dismiss the keyboard when the user taps the "Return" key or its equivalent
  // while editing a text field.
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true;
  }
  
}