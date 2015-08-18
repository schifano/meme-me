//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/18/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class SentMemesTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Create array of Meme objects
    var memes: [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshUI()
        self.tabBarController?.tabBar.hidden = false // TODO: WAT

        // Access the shared model
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell") as! MemeTableViewCell
        let meme = self.memes[indexPath.row]
        
        // Set top/bottom text and memed image
        cell.imageView?.image = meme.memedImage
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText
        
        return cell
    }
    
    func refreshUI() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        });
    }
}