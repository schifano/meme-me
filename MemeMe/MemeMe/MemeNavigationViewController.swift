//
//  MemeNavigationViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 9/1/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class MemeNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        MemeViewController().hideBottomTabBar()
    }
}