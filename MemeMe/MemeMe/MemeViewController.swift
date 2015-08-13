//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/10/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit

// TODO: completionItemsHandler?
// TODO: Udacity Assets?

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let imagePicker = UIImagePickerController()
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable share button until an image is picked
        shareButton.enabled = false
        
        // Set the delegate of the current UIImagePickerController object to the view controller
        imagePicker.delegate = self
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
        // Create dictionary of default attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: "-3.0" // Use negative value to allow stroke AND fill
        ]
        topTextField.defaultTextAttributes = textAttributes
        bottomTextField.defaultTextAttributes = textAttributes
        
        // TODO: Can we center using a defaultTextAttribute?
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // If a camera is not available, disable the camera button.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications() // Subscribe
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications() // Unsubscribe
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
            
            // Show share button when image is selected
            shareButton.enabled = true
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
    
    // MARK: Notification Center Methods
    /**
        Keyboard will show when bottomTextField is the first responder. 
        Method adjusts the current view frame based on the y coordinate by subtracting
        the height of the keyboard. This ensures that they keyboard will not cover 
        the current text field.
    
        :param: notification The NSNotification
    */
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    /**
        Keyboard will hide when bottomTextField is the first responder.
        Method adjusts the current view frame based on the y coordinate by adding
        the height of the keyboard. This ensures that the view does not remain
        displaced on the screen when the keyboard hides.
    
        :param: notification The NSNotification
    */
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    /**
        Returns the keyboard height.
    
        :param: notification The NSNotification
    */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    /**
        Subscribes to keyboard notifications.
    */
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
        Unsubscribes to keyboard notifications.
    */
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Meme Generating and Sharings
    /**
        Save a generated meme object.
    */
    func save() {
        var memedImage = generateMemedImage()
        // Create meme
        var meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    /**
        Generate a meme object with the top text, bottom text, selected image.
    
        :returns: memedImage The final meme image designed by the user.
    */
    func generateMemedImage() -> UIImage {
        // Hide tool bar and nav bar
        self.hide()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show tool bar and nav bar
        self.show()
        
        return memedImage
    }
    
    /**
        Hides the top navigation bar and bottom toolbar.
        Ensures that the final meme image does not include either bar.
    */
    func hide() {
        self.navigationController?.navigationBarHidden = true
        self.bottomToolbar.hidden = true
    }
    
    /**
        Shows the top navigation bar and bottom toolbar.
    */
    func show() {
        self.navigationController?.navigationBarHidden = false
        self.bottomToolbar.hidden = false
    }
    
    /**
        Shares the generated meme image by presenting an Activity View Controller.
        Connected to the share button on the navigation bar.
    */
    @IBAction func share() {
        // Generate meme image
        var memedImage = self.generateMemedImage()
        // Define instance of Activity View Controller
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // Present View Controller
        self.presentViewController(activityController, animated: true, completion: nil)
        // Save the meme
        self.save()
        
        // TODO: What is the point of this even anyway
        activityController.completionWithItemsHandler = {
            (activity, success, items, error) in
            println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
        }
        // Dismiss View Controller
        dismissViewControllerAnimated(true, completion: nil)
    }
}