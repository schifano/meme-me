//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/17/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class SentMemesCollectionViewController: UICollectionViewController, UICollectionViewDataSource {
    
    // Create array of Meme objects
    var memes: [Meme]!
    var memeViewController = MemeViewController()
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        
        // Determine size of collection items for portrait and landscape
        // TODO: Put into helpher method?
        let dimension: CGFloat
        if UIDevice.currentDevice().orientation.isPortrait {
            dimension = (view.frame.size.width - (2 * space)) / 3.0
        } else {
            dimension = (view.frame.size.height - (2 * space)) / 3.0
        }
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showBottomTabBar()
        
        collectionView!.reloadData()
        
        // Access the shared model
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showBottomTabBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hideBottomTabBar()
    }

    /**
        Hide the tab bar associated with the current navigation controller.
    */
    func hideBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = true
    }

    /**
        Show the tab bar associated with the current navigation controller.
    */
    func showBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = false
    }
    
    /**
        Dismisses the image picker view controller.
        
        :param: sender The Cancel button on the nav bar
    */
    @IBAction func cancelImagePicker(segue: UIStoryboardSegue) {
    }
    
    // MARK: Collection View Data Source
    // TODO: Add better performance for adding and deleting items
    
    /**
        Asks the data source for the number of items in the specified section. (required)
    
        :param: collectionView An object representing the collection view requesting this information.
        :param: section An index number identifying a section in collectionView.
        :returns: memes.count The number of rows (memes) in section
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    /**
        Asks the data source for the cell that corresponds to the specified item in the collection view. (required)
    
        :param: collectionView An object representing the collection view requesting this information.
        :param: indexPath The index path that specifies the location of the item.
        :returns: cell A configured cell object.
    */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        // Set the image
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailController = storyboard?.instantiateViewControllerWithIdentifier("SentMemesDetailViewController") as! SentMemesDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}