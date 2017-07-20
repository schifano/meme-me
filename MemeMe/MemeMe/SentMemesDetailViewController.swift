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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.tabBarController?.tabBar.isHidden = true
        
        if let image = meme.memedImage {
            detailImageView.image = image
        }
    }
        
    /**
        If the segue identifier "Edit" is passed, the method will segue to MemeNavigationViewController so the user can edit the selected meme.
    
        - parameter segue: The segue object containing information about the view controllers involved in the segue.
        - parameter sender: The object that initiated the segue.
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit" {

            let editNavigationController = storyboard?.instantiateViewController(withIdentifier: "MemeNavigationViewController") as! UINavigationController

            addChildViewController(editNavigationController)
            let applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
            // Update the editor meme to be re-displayed
            applicationDelegate.editorMeme = meme
            applicationDelegate.editMode = true
        }
    }
}
