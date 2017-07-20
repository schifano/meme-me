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
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
}
