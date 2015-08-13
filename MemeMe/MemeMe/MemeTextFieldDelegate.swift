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
    
        :param: textField The current textfield being updated
        :param: range The range of the string which will be replaced by the current text
        :param: string The new string
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Get the new text
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        return true
    }
    
    /**
        Resets the text to a blank string once a user begins editing the textfield.
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    /**
        Enables the keyboard to return and resigns the textfield from being the first responder.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}