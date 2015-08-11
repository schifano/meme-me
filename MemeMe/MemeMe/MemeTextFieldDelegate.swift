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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Get the new text
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}