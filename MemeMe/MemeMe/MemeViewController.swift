//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Rachel Schifano on 8/10/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Declared Variables
    @IBOutlet weak var topTextVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomTextVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var centerVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    var meme: Meme!
    var firstLoad: Bool = true // TEST
    var initialViewRect: CGRect! // TEST

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Garbage
        if firstLoad {
            initialViewRect = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)
            firstLoad = false
        }
        
        // Disable share button until an image is picked
        shareButton.enabled = false
        
        // Set the delegate of the current UIImagePickerController object to the view controller
        imagePicker.delegate = self
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
        transformIntoMemeText(topTextField, bottomText: bottomTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If a camera is not available, disable the camera button.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications() // Subscribe to keyboard
        subscribeToRotationNotifications() // Subscribe to rotation
        
        // Get the current meme to Edit
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

        if (applicationDelegate.editMode != nil && applicationDelegate.editMode == true) {
            println("EDIT MODE") // TEST
            meme = applicationDelegate.editorMeme
            // Redraw meme
            view.contentMode = .ScaleToFill
            imageView.contentMode = .ScaleAspectFit
            
            // But why do I have to reset this to make these imageViews match? Why does it change?
//            var testRect: CGRect = CGRectMake(-1, 64, 377, 558)
//            imageView.frame = initialViewRect
            imageView.image = meme.originalImage

            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            adjustContraintsForOrientationChange()
            
            view.setNeedsDisplay()
            
            shareButton.enabled = true
            applicationDelegate.editMode = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications() // Unsubscribe to keyboard
        unsubscribeToRotationNotifications() // Unsubscribe to rotation
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
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
            
            adjustContraintsForOrientationChange()
            
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
        Adjusts text field constraints depending on orientation so that the text is displayed within the image.
    */
    func adjustContraintsForOrientationChange() {
        
        var orientation = UIDevice.currentDevice().orientation
        if imageView.image != nil {
            var rect: CGRect = calculateRectOfImage(imageView)
            
            switch (orientation) {
            case .Portrait, .PortraitUpsideDown:
                println("Image View: \(imageView)") // TEST
                println("Portrait rect.origin.y: \(rect.origin.y)") // TEST
                println("Portrait topTextVerticalSpace: \(rect.origin.y - 65)") // TEST
                println("Portrait bottomTextVerticalSpace: \(-(imageView.frame.size.height - rect.size.height) / 2)") // TEST
                
//                view.setNeedsDisplay()
                topTextVerticalSpace.constant = rect.origin.y - 65
                bottomTextVerticalSpace.constant = -(imageView.frame.size.height - rect.size.height) / 2
                view.setNeedsUpdateConstraints()
            case .LandscapeLeft, .LandscapeRight:
//                view.setNeedsDisplay()
                topTextVerticalSpace.constant = 0.0
                bottomTextVerticalSpace.constant = 0.0
                view.setNeedsUpdateConstraints()
            default: break; }
        }
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
    
    /**
        Subscribes to rotation notifications.
    */
    func subscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "adjustContraintsForOrientationChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    /**
        Unsubscribes to rotation notifications.
    */
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
        var cropRect: CGRect = calculateRectOfImage(imageView)
        // Draw new image in current image context
        var croppedImage: CGImage = CGImageCreateWithImageInRect(memedImage.CGImage, cropRect)
        // Create new cropped UIImage
        var croppedMemedImage: UIImage = UIImage(CGImage: croppedImage)!

        // Show tool bar and nav bar
        showBottomToolbar()
        
        return croppedMemedImage
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
}