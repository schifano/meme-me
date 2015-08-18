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
        
        // Access the shared model
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    // MARK: Table View Data Source
    /**
        Tells the data source to return the number of rows in a given section of a table view. (required)
    
        :param: tableView The table-view object requesting this information.
        :param: section An index number identifying a section in tableView.
        :returns: self.memes.count The number of rows in section.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    /**
        Asks the data source for a cell to insert in a particular location of the table view. (required)
    
        :param: tableView A table-view object requesting the cell.
        :param: indexPath An index path locating a row in tableView.
        :returns: cell An object inheriting from custom MemeTableViewCell that the table view can use for the specified row.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell") as! MemeTableViewCell
        let meme = self.memes[indexPath.row]
        
        // Set top/bottom text and memed image
        cell.imageView?.image = meme.memedImage
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText
        
        return cell
    }
    
    /**
        Helper method for refreshing the data on the main thread displayed in the table view.
    */
    func refreshUI() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        });
    }
}