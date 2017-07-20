//
//  MemeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/11/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    /**
        Allows the textfield to update with new text.
    
        - parameter textField: The current textfield being updated
        - parameter range: The range of the string which will be replaced by the current text
        - parameter string: The new string
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the new text
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        return true
    }
    
    /**
        Resets the text to a blank string once a user begins editing the textfield.
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    /**
        Enables the keyboard to return and resigns the textfield from being the first responder.
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
