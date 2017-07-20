//
//  MemeTabBar.swift
//  MemeMe
//
//  Created by Rachel Schifano on 9/2/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class MemeTabBar: UITabBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 45
        
        return sizeThatFits
    }
}
