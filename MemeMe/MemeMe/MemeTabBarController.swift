//
//  MemeTabBarController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 9/4/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class MemeTabBarController: UITabBarController {
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}