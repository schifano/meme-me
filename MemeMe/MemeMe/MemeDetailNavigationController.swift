//
//  MemeDetailNavigationController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 9/1/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class MemeDetailNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MemeViewController().hideBottomTabBar()
    }
}