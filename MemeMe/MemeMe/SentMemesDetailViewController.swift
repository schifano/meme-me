//
//  SentMemesDetailViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/17/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class SentMemesDetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!

    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = meme.memedImage {
            detailImageView.image = image
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Edit"{
            var navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeNavigationViewController") as! UINavigationController
            presentViewController(navigationController, animated: true, completion: nil)
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            // Update the editor meme to be re-displayed
            applicationDelegate.editorMeme = self.meme
        }
    }
}