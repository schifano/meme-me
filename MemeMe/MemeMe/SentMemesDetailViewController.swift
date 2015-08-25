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
        println("DETAIL VIEW PREPARE FOR SEGUE") // TEST
//        var navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeNavigationViewController") as! UINavigationController
//            +        // Present the view controller
//            +        self.presentViewController(navigationController, animated: false, completion: nil)
//        
//        if segue.identifier == "Edit" {
            if let a = segue.destinationViewController as? MemeViewController {
                println("segue to MemeViewController") // TEST
                let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                applicationDelegate.editorMeme = self.meme // the editor meme is updated so when we go back to Editor View we display the selected meme to edit
            }
//        }
    }
}