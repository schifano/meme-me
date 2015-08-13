//
//  Meme.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/12/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    
    /**
        Initializer for a new Meme object.
    */
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}