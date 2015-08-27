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
        
        
        println("nav bar height: \(self.navigationController?.navigationBar.frame.size.height)") // TEST
        
        // Disable share button until an image is picked
        shareButton.enabled = false
        
        // Set the delegate of the current UIImagePickerController object to the view controller
        imagePicker.delegate = self
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
        transformIntoMemeText(topTextField, bottomText: bottomTextField, className: "MemeViewController")
    
    }
    
    internal func transformIntoMemeText(topText: UITextField, bottomText: UITextField, className: String) {
        
        var MAX_FONT_SIZE: CGFloat = 0.0
        // Check if textField is applied to a custom view cell
        if className == "MemeViewController"{
            MAX_FONT_SIZE = 50.0
        } else {
            MAX_FONT_SIZE = 25.0
        }
        
        // Create dictionary of default attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: MAX_FONT_SIZE)!,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: "-3.0" // Use negative value to allow stroke AND fill
        ]
        topText.defaultTextAttributes = textAttributes
        bottomText.defaultTextAttributes = textAttributes
        
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If a camera is not available, disable the camera button.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications() // Subscribe
        
        // Get the current meme to Edit
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

        if (applicationDelegate.editMode != nil && applicationDelegate.editMode == true) {
            self.meme = applicationDelegate.editorMeme
            // Redraw meme
            imageView.image = meme.originalImage
            // Apparently order of calling content mode matters
            imageView.contentMode = .ScaleAspectFit

            drawTextInRect(calculateRectOfImage(self.imageView)) // TEST
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            
            // TEST
            imageView.setNeedsDisplay()
            imageView.setNeedsLayout()
            imageView.setNeedsUpdateConstraints()
            
            shareButton.enabled = true
            applicationDelegate.editMode = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications() // Unsubscribe
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

    // FIXME: Is there a way to find the bottom right point of an image, not just top left? Or, check orientation to recalculate the drawing of the textfield
    /**
        Calculates the location of the image within the image view.
        This is used to determine what location the top and bottom textfields should be set.
        
        :param: imageView The current image view
        :returns: imageRect The CGRect of the current image in the image view
    */
    func calculateRectOfImage(imageView: UIImageView) -> CGRect {
        println("calculateRectOfImage") // TEST
        
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
        
//        // TEST
//        println("imageOrigin X: \(imageOriginX)")
//        println("imageOrigin Y: \(imageOriginY)")
//        println("imageSize.width: \(imageSize.width)")
//        println("imageSize.height: \(imageSize.height)")
        
        return imageRect
    }
    
    // Adjust text based on image location - new func?
    // FIXME: This does not override drawTextInRect - may want to call something else?
    func drawTextInRect(rect: CGRect) {
        
        println("##############################") // TEST
        // ALWAYS 80, BC CONSTRAINT STARTS AT 80
//        println("top before: \(topTextVerticalSpace.constant)") // TEST
//        println("bottom before: \(bottomTextVerticalSpace.constant)") // TEST
        println("origin Y: \(rect.origin.y)") // TEST
        

        
        if UIDevice.currentDevice().orientation.isPortrait {
            // larger the value, closer to bottom
            topTextVerticalSpace.constant = rect.origin.y - 60.0
            // smaller the value, the closer to bottom
            // higher number, closer to top
            bottomTextVerticalSpace.constant = -(imageView.frame.size.height - rect.size.height) / 2
        } else {
            topTextVerticalSpace.constant = 0.0
            bottomTextVerticalSpace.constant = 0.0
        }
//        centerVerticalSpace.constant = rect.size.height - 110.0
        
//        topTextField.backgroundColor = UIColor.blueColor()
        
        println("view height: \(self.imageView.frame.size.height)")
        println("rect height: \(rect.size.height)") // TEST
        println("vertical center: \(centerVerticalSpace.constant)")
//        println("rect width: \(rect.size.width)") // TEST
        println("top AFTER: \(topTextVerticalSpace.constant)") // TEST
//        println("bottom AFTER: \(bottomTextVerticalSpace.constant)") // TEST
        
//        println("drawTextInRect") // TEST
//        topTextField.frame = CGRect(x: rect.origin.x, y: rect.origin.y + 500, width: 500, height: 100)
//        topTextField.backgroundColor = UIColor.blueColor()
//        self.imageView.addSubview(topTextField)
//        
//        // I just wasn't changing it enough, 10 pts is really small, apparently
//        var y: CGFloat = (rect.origin.y - 50.0)
//        
//        // TEST - DOES THIS EVEN PUT A THING ANYWHERE
//        var testTopTextField: UITextField = UITextField(frame: CGRect(x: rect.origin.x + 10, y: y, width: 300.0, height: 50.0))
//        testTopTextField.text = "KITTENS"
//        testTopTextField.backgroundColor = UIColor.greenColor()
//        self.imageView.addSubview(testTopTextField)
//        
//        var testBottomTextField: UITextField = UITextField(frame: CGRect(x: rect.origin.x, y: rect.origin.y + (rect.size.height / 2), width: 300.0, height: 50.0))
//        testBottomTextField.text = "R SO CEWT"
//        testBottomTextField.backgroundColor = UIColor.purpleColor()
//        self.imageView.addSubview(testBottomTextField)
//        
//        // TEST
//        println("drawText - rect.origin.x: \(rect.origin.x)")
//        println("drawText - rect.origin.y: \(rect.origin.y)")
//        println("y: \(y)") // TEST
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
            
            // MARK: drawTextInRect
            drawTextInRect(calculateRectOfImage(self.imageView)) // TEST
            
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
    
    // MARK: Meme Generating and Sharing
    /**
        Save a generated meme object.
    */
    func save() {
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
        self.hide()
        
        var rectOfImage: CGRect = calculateRectOfImage(self.imageView)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
//        UIGraphicsBeginImageContext(rectOfImage.size)
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
//        self.navigationController?.navigationBarHidden = true
        self.bottomToolbar.hidden = true
    }
    
    /**
        Shows the top navigation bar and bottom toolbar.
    */
    func show() {
//        self.navigationController?.navigationBarHidden = false
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
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            // Save the meme
            self.save()
            // Dismiss View Controller - if you place this outside the handler, the activityController will dismiss too early
            self.performSegueWithIdentifier("unwindEdit", sender: nil)
        }
    }
}