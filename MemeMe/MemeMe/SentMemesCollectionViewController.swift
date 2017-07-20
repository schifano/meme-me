//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/17/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Create array of Meme objects
    var memes: [Meme]!
    var memeViewController = MemeViewController()
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        
        // Determine size of collection items for portrait and landscape
        // TODO: Put into helpher method?
        let dimension: CGFloat
        if UIDevice.current.orientation.isPortrait {
            dimension = (view.frame.size.width - (2 * space)) / 3.0
        } else {
            dimension = (view.frame.size.height - (2 * space)) / 3.0
        }
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showBottomTabBar()
        
        collectionView!.reloadData()
        
        // Access the shared model
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    
    // MARK: Collection View Data Source
    // TODO: Add better performance for adding and deleting items
    
    /**
        Asks the data source for the number of items in the specified section. (required)
    
        - parameter collectionView: An object representing the collection view requesting this information.
        - parameter section: An index number identifying a section in collectionView.
        - returns: memes.count The number of rows (memes) in section
    */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    /**
        Asks the data source for the cell that corresponds to the specified item in the collection view. (required)
    
        - parameter collectionView: An object representing the collection view requesting this information.
        - parameter indexPath: The index path that specifies the location of the item.
        - returns: cell A configured cell object.
    */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        // Set the image
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = storyboard?.instantiateViewController(withIdentifier: "SentMemesDetailViewController") as! SentMemesDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}
