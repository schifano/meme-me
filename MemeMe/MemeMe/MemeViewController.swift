//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/10/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomTextVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var centerVerticalSpace: NSLayoutConstraint!
    
    // MARK: Declared Variables
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let imagePicker = UIImagePickerController()
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    var meme: Meme!

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable share button until an image is picked
        shareButton.enabled = false
        
        // Set the delegate of the current UIImagePickerController object to the view controller
        imagePicker.delegate = self
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
        transformIntoMemeText(topTextField, bottomText: bottomTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If a camera is not available, disable the camera button.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications() // Subscribe to keyboard
        subscribeToRotationNotifications() // Subscribe to rotation
        
        // Get the current meme to Edit
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

        if (applicationDelegate.editMode != nil && applicationDelegate.editMode == true) {
            meme = applicationDelegate.editorMeme
            // Redraw meme
            imageView.image = meme.originalImage
            // Apparently order of calling content mode matters
            imageView.contentMode = .ScaleAspectFit

            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            
            adjustTextFieldConstraints(calculateRectOfImage(imageView))
            
            shareButton.enabled = true
            applicationDelegate.editMode = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications() // Unsubscribe
    }
    
    /**
        Applies custom text attributes that imitates the common meme font "Impact" for editor and table cells. Why also the table cells? The Udacity example app displays textfields with these attributes on the table cell previews.
    
        :param: topText The text of the top text field.
        :param: bottomText The text of the bottom text field.
        :param: restorationID The restorationIdentifier associated with the calling view controller.
    */
    func transformIntoMemeText(topText: UITextField, bottomText: UITextField) {
        // Create dictionary of default attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: "-3.0" // Use negative value to allow stroke AND fill
        ]
        // Apply attributes
        topText.defaultTextAttributes = textAttributes
        bottomText.defaultTextAttributes = textAttributes
        // Center
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
    }
    
    // MARK: Image Picker Methods
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
            
            adjustTextFieldConstraints(calculateRectOfImage(imageView))
            
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
    
    /**
        Calculates the location of the image within the image view.
        This is used to determine what location the top and bottom textfields should be set.
        
        :param: imageView The current image view.
        :returns: imageRect The CGRect of the current image in the image view.
    */
    func calculateRectOfImage(imageView: UIImageView) -> CGRect {
        var imageViewSize: CGSize = imageView.frame.size // Get size of image view
        var imageSize: CGSize = imageView.image!.size // Get size of current image displayed
        
        // Calculate aspect with ScaleAspectFit
        var scaleWidth: CGFloat = imageViewSize.width / imageSize.width
        var scaleHeight: CGFloat = imageViewSize.height / imageSize.height
        // Find the min
        var aspect: CGFloat = fmin(scaleWidth, scaleHeight)
        
        // CGSize
        imageSize.width *= aspect
        imageSize.height *= aspect
        
        // CGPoint
        var imageOriginX = (imageViewSize.width - imageSize.width) / 2
        var imageOriginY = (imageViewSize.height - imageSize.height) / 2
        
        // Add image offset
        imageOriginX += imageView.frame.origin.x
        imageOriginY += imageView.frame.origin.y
        
        var imageRect = CGRectMake(imageOriginX, imageOriginY, imageSize.width, imageSize.height)
        return imageRect
    }
    
    /**
        Adjusts text field constraints so that the text is displayed within the image.
        
        :param: rect The CGRect of the image.
    */
        func adjustTextFieldConstraints(rect: CGRect) {
    
            // Checks what the current orientation is before reloading view
            if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                // Constraint of top text field should begin at the image rect origin y and account for textfield height (50pt) and padding (10pt) between top text and top of image
                topTextVerticalSpace.constant = rect.origin.y
                // Constraint of bottom text field is the value of the offsets (or gray gaps). Value is negative because the constraint is from the text field to the end of the image view.
                bottomTextVerticalSpace.constant = -(imageView.frame.size.height - rect.size.height) / 2
            } else {
                // Landscape orientation does not have offsets to account for - set constraints to 0.0
                topTextVerticalSpace.constant = 0.0
                bottomTextVerticalSpace.constant = 0.0
            }
        }
    
    // FIXME: Create method to check for orientation changes and adjust constraints
    // MARK: Incomplete code for adjusting constraints based on orientation
    func rotationWillChange() {
        //        println("rotation will change") // TEST
        //        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
        //                topTextVerticalSpace.constant = 0.0
        //                bottomTextVerticalSpace.constant = 0.0
        //            return "landscape"
        //        } else {
        //            // Constraint of top text field should begin at the image rect origin y and account for textfield height (50pt) and padding (10pt) between top text and top of image
        //            topTextVerticalSpace.constant = rect.origin.y - 60.0
        //            // Constraint of bottom text field is the value of the offsets (or gray gaps). Value is negative because the constraint is from the text field to the end of the image view.
        //            bottomTextVerticalSpace.constant = -(imageView.frame.size.height - rect.size.height) / 2
        //
        //            return "portrait"
        //        }
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
            view.frame.origin.y -= getKeyboardHeight(notification)
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
            view.frame.origin.y += getKeyboardHeight(notification)
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
    
    func subscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotationWillChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // MARK: Meme Generating and Sharing
    /**
        Shares the generated meme image by presenting an Activity View Controller.
        Connected to the share button on the navigation bar.
    */
    @IBAction func shareMemedImage(sender: AnyObject) {
        // Generate meme image
        var memedImage = generateMemedImage()
        // Define instance of Activity View Controller
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // Present View Controller
        presentViewController(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            // Save the meme
            self.saveMemedImage()
            // Dismiss View Controller - if you place this outside the handler, the activityController will dismiss too early
            self.performSegueWithIdentifier("unwindEdit", sender: nil)
        }
    }
    
    /**
        Save a generated meme object.
    */
    func saveMemedImage() {
        var memedImage = generateMemedImage()
        // Create meme
        var meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        // Add meme to the meme array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    /**
        Generate a meme object with the top text, bottom text, selected image.
    
        :returns: memedImage The final meme image designed by the user.
    */
    func generateMemedImage() -> UIImage {
        // Hide tool bar and nav bar
        hideBottomToolbar()
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Get CGRect of image in imageView
        var imageRect: CGRect = calculateRectOfImage(imageView)
        var imagePoint = CGPointMake(imageRect.origin.x, imageRect.origin.y)
        var imagePoint2 = CGPointMake(-50, -100)
        // Crop image
        UIGraphicsBeginImageContext(imageRect.size)
        memedImage.drawAtPoint(imagePoint2)
        var croppedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(croppedImage,nil, nil, nil);
        
        
        // Show tool bar and nav bar
        showBottomToolbar()
        
        return memedImage
    }
    
    /**
        Hides the bottom toolbar. The top navigation bar does not need to be hidden since we are currently only capturing an image of the underlying view.
    */
    func hideBottomToolbar() {
        bottomToolbar.hidden = true
    }
    
    /**
        Shows the bottom toolbar.
    */
    func showBottomToolbar() {
        bottomToolbar.hidden = false
    }
    
    func hideBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = true
        tabBarController?.tabBar.hidden = true
    }
    
    func showBottomTabBar() {
        navigationController?.tabBarController?.tabBar.hidden = false
        tabBarController?.tabBar.hidden = false
    }
}