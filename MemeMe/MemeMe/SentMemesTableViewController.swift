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
    var memeViewController = MemeViewController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        showBottomTabBar()
        navigationController?.tabBarController?.tabBar.hidden = false
        tableView.rowHeight = 125
        
        // Access the shared model
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showBottomTabBar()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hideBottomTabBar()
        navigationController?.tabBarController?.tabBar.hidden = true
    }
    
    func hideBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = true
    }
    
    func showBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = false
    }
    
    
    /**
        Dismisses the image picker view controller.
        
        :param: sender The Cancel button on the nav bar
    */
    @IBAction func cancelImagePicker(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Even when empty, still enables the delete button upon swipe
        memes.removeAtIndex(indexPath.row)
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        applicationDelegate.memes.removeAtIndex(indexPath.row)
        tableView.reloadData()
    }
    
    /**
        Tells the data source to return the number of rows in a given section of a table view. (required)
    
        :param: tableView The table-view object requesting this information.
        :param: section An index number identifying a section in tableView.
        :returns: memes.count The number of rows in section.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    /**
        Asks the data source for a cell to insert in a particular location of the table view. (required)
    
        :param: tableView A table-view object requesting the cell.
        :param: indexPath An index path locating a row in tableView.
        :returns: cell An object inheriting from custom MemeTableViewCell that the table view can use for the specified row.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell") as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        // Set top/bottom text and original image
        cell.memeImageView.image = meme.memedImage
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText

        return cell
    }
    
    /**
        Tells the delegate that the specified row is now selected.
        Shows the selected meme's detail view.
    
        :param: tableView The current tableView
        :param: indexPath The specified row that is now selected
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = storyboard?.instantiateViewControllerWithIdentifier("SentMemesDetailViewController") as! SentMemesDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}