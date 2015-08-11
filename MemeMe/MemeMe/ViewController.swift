//
//  ViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/10/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewWillAppear(animated: Bool) {
        // If a camera is not available, disable the camera button.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the delegate of the current UIImagePickerController object to the view controller this is written in.
        imagePicker.delegate = self
    }

    /**
        Allows user to select a photo from the PhotoLibrary when the Album button is tapped.
    
        :param: sender The toolbar Album button
    */
    @IBAction func imagePickerAlbumButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        // Present the image picker VC
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /**
        Allows user to take a photo using either a front or rear camera.
    
        :param: sender The toolbar camera button
    */
    @IBAction func imagePickerCameraButtonTapped(sender: AnyObject) {
        imagePicker.allowsEditing = false
        
        // Check if the device camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {

            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)  {
                imagePicker.sourceType = .Camera
                imagePicker.cameraDevice = .Front
                
                presentViewController(imagePicker, animated: true, completion: nil)

            } else {
                // Rear camera available
                imagePicker.sourceType = .Camera
                imagePicker.cameraDevice = .Rear
                
                presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        } else {
            // Alert View deprecated in iOS 8, use Alert Controller
            let alert = UIAlertController(title: "No camera found", message: "Did not find a camera on your current device", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) in println("Foo")}))
            presentViewController(alert, animated: true, completion: nil)
        }
        // TODO: Figure out if I need to dismissViewController here
    }
    
    /**
        Sets the picked image to the image view.
    
        :param: picker The current UIImagePickerController
        :param: info The dictionary which takes a key and returns the original image picked
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Set the picked image in the UIImageView
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        Dismisses the current view controller.
    
        :param: picker The current UIImagePickerController
    */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}