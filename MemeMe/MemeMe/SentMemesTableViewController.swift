//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/18/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class SentMemesTableViewController: UITableViewController {

    // Create array of Meme objects
    var memes: [Meme]!
    var memeViewController = MemeViewController()
    
    // MARK: View Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showBottomTabBar()
        tableView.rowHeight = 125
        
        // Access the shared model
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomTabBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideBottomTabBar()
    }

    /**
        Hide the tab bar associated with the current navigation controller.
    */
    func hideBottomTabBar() {
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    /**
        Show the tab bar associated with the current navigation controller.
    */
    func showBottomTabBar() {
        navigationController?.tabBarController?.tabBar.isHidden = false
    }

    /**
        Dismisses the image picker view controller.
        
        - parameter sender: The Cancel button on the nav bar
    */
    @IBAction func cancelImagePicker(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Even when empty, still enables the delete button upon swipe
        memes.remove(at: indexPath.row)
        let applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
        applicationDelegate.memes.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    /**
        Tells the data source to return the number of rows in a given section of a table view. (required)
    
        - parameter tableView: The table-view object requesting this information.
        - parameter section: An index number identifying a section in tableView.
        - returns: memes.count The number of rows in section.
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    /**
        Asks the data source for a cell to insert in a particular location of the table view. (required)
    
        - parameter tableView: A table-view object requesting the cell.
        - parameter indexPath: An index path locating a row in tableView.
        - returns: cell An object inheriting from custom MemeTableViewCell that the table view can use for the specified row.
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell") as! MemeTableViewCell
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
    
        - parameter tableView: The current tableView
        - parameter indexPath: The specified row that is now selected
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = storyboard?.instantiateViewController(withIdentifier: "SentMemesDetailViewController") as! SentMemesDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}
