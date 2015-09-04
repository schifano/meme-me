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
    
    // MARK: View Lifecycle Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.tabBarController?.tabBar.hidden = true
        
        if let image = meme.memedImage {
            detailImageView.image = image
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func supportedInterfaceOrientations() -> Int{
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    /**
        If the segue identifier "Edit" is passed, the method will segue to MemeNavigationViewController so the user can edit the selected meme.
    
        :param: segue The segue object containing information about the view controllers involved in the segue.
        :param: sender The object that initiated the segue.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Edit" {
            var navigationController = storyboard?.instantiateViewControllerWithIdentifier("MemeNavigationViewController") as! UINavigationController
            addChildViewController(navigationController)
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            // Update the editor meme to be re-displayed
            applicationDelegate.editorMeme = meme
            applicationDelegate.editMode = true
        }
    }
}