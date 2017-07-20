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
            initialViewRect = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageView.frame.size.width, height: imageView.frame.size.height)
            firstLoad = false
        }
        
        // Disable share button until an image is picked
        shareButton.isEnabled = false
        
        // Set the delegate of the current UIImagePickerController object to the view controller
        imagePicker.delegate = self
        topTextField.delegate = memeTextFieldDelegate
        bottomTextField.delegate = memeTextFieldDelegate
        
        transformIntoMemeText(topTextField, bottomText: bottomTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If a camera is not available, disable the camera button.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications() // Subscribe to keyboard
        subscribeToRotationNotifications() // Subscribe to rotation
        
        // Get the current meme to Edit
        let applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)

        if (applicationDelegate.editMode != nil && applicationDelegate.editMode == true) {
//            println("EDIT MODE") // TEST
            meme = applicationDelegate.editorMeme
            // Redraw meme
            
            view.setNeedsLayout()
            imageView.setNeedsLayout()
            
            view.contentMode = .scaleToFill
//            view.autoresizingMask = UIViewAutoresizing.None
//            imageView.autoresizingMask = UIViewAutoresizing.None
            
            imageView.contentMode = .scaleAspectFit
            
            // But why do I have to reset this to make these imageViews match? Why does it change?
//            var testRect: CGRect = CGRectMake(-1, 64, 377, 558)
//            imageView.frame = initialViewRect
            imageView.image = meme.originalImage
            
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            
            transformIntoMemeText(topTextField, bottomText: bottomTextField)
            adjustContraintsForOrientationChange()
            
            
            imageView.setNeedsDisplay()
            
            shareButton.isEnabled = true
            applicationDelegate.editMode = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications() // Unsubscribe to keyboard
        unsubscribeToRotationNotifications() // Unsubscribe to rotation
    }
    
    /**
        Applies custom text attributes that imitates the common meme font "Impact" for editor and table cells. Why also the table cells? The Udacity example app displays textfields with these attributes on the table cell previews.
    
        - parameter topText: The text of the top text field.
        - parameter bottomText: The text of the bottom text field.
        - parameter restorationID: The restorationIdentifier associated with the calling view controller.
    */
    func transformIntoMemeText(_ topText: UITextField, bottomText: UITextField) {
        // Create dictionary of default attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50.0)!,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: "-3.0" // Use negative value to allow stroke AND fill
        ] as [String : Any]
        // Apply attributes
        topText.defaultTextAttributes = textAttributes
        bottomText.defaultTextAttributes = textAttributes
        // Center
        topText.textAlignment = .center
        bottomText.textAlignment = .center
    }
    
    // MARK: Image Picker Methods
    /**
        Allows user to select a photo from the PhotoLibrary when the Album button is tapped.
    
        - parameter sender: The toolbar Album button
    */
    @IBAction func imagePickerAlbumButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        // Present the image picker VC
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
        Allows user to take a photo using either a front or rear camera.
    
        - parameter sender: The toolbar camera button
    */
    @IBAction func imagePickerCameraButtonTapped(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        
        // Check if the device camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)  {
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .front
                
                present(imagePicker, animated: true, completion: nil)

            } else {
                // Rear camera available
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .rear
                
                present(imagePicker, animated: true, completion: nil)
            }
        } else {
            // Alert View deprecated in iOS 8, use Alert Controller
            let alert = UIAlertController(title: "No camera found", message: "Did not find a camera on your current device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction) in print("Foo")}))
            present(alert, animated: true, completion: nil)
        }
    }
    
    /**
        Sets the picked image to the image view.
    
        - parameter picker: The current UIImagePickerController
        - parameter info: The dictionary which takes a key and returns the original image picked
    */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Set the picked image in the UIImageView
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            
            adjustContraintsForOrientationChange()
            
            // Show share button when image is selected
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    /**
        Dismisses the current view controller.
    
        - parameter picker: The current UIImagePickerController
    */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
        Calculates the location of the image within the image view.
        This is used to determine what location the top and bottom textfields should be set.
        
        - parameter imageView: The current image view.
        - returns: imageRect The CGRect of the current image in the image view.
    */
    func calculateRectOfImage(_ imageView: UIImageView) -> CGRect {
        let imageViewSize: CGSize = imageView.frame.size // Get size of image view
        var imageSize: CGSize = imageView.image!.size // Get size of current image displayed
        
        // Calculate aspect with ScaleAspectFit
        let scaleWidth: CGFloat = imageViewSize.width / imageSize.width
        let scaleHeight: CGFloat = imageViewSize.height / imageSize.height
        // Find the min
        let aspect: CGFloat = fmin(scaleWidth, scaleHeight)
        
        // CGSize
        imageSize.width *= aspect
        imageSize.height *= aspect
        
        // CGPoint
        var imageOriginX = (imageViewSize.width - imageSize.width) / 2
        var imageOriginY = (imageViewSize.height - imageSize.height) / 2
        
        // Add image offset
        imageOriginX += imageView.frame.origin.x
        imageOriginY += imageView.frame.origin.y
        
        let imageRect = CGRect(x: imageOriginX, y: imageOriginY, width: imageSize.width, height: imageSize.height)
        return imageRect
    }
    
    /**
        Adjusts text field constraints depending on orientation so that the text is displayed within the image.
    */
    func adjustContraintsForOrientationChange() {
        
        let orientation = UIDevice.current.orientation
        if imageView.image != nil {
            let rect: CGRect = calculateRectOfImage(imageView)
            
            switch (orientation) {
            case .portrait, .portraitUpsideDown:
//                println("Image View: \(imageView)") // TEST
//                println("Portrait rect.origin.y: \(rect.origin.y)") // TEST
//                println("Portrait topTextVerticalSpace: \(rect.origin.y - 65)") // TEST
//                println("Portrait bottomTextVerticalSpace: \(-(imageView.frame.size.height - rect.size.height) / 2)") // TEST
                
//                view.setNeedsDisplay()
                topTextVerticalSpace.constant = rect.origin.y - 65
                bottomTextVerticalSpace.constant = -(imageView.frame.size.height - rect.size.height) / 2
                imageView.setNeedsUpdateConstraints()
            case .landscapeLeft, .landscapeRight:
//                view.setNeedsDisplay()
                topTextVerticalSpace.constant = 0.0
                bottomTextVerticalSpace.constant = 0.0
                imageView.setNeedsUpdateConstraints()
            default: break; }
        }
    }
    
    // MARK: Notification Center Methods
    /**
        Keyboard will show when bottomTextField is the first responder. 
        Method adjusts the current view frame based on the y coordinate by subtracting
        the height of the keyboard. This ensures that they keyboard will not cover 
        the current text field.
    
        - parameter notification: The NSNotification
    */
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    /**
        Keyboard will hide when bottomTextField is the first responder.
        Method adjusts the current view frame based on the y coordinate by adding
        the height of the keyboard. This ensures that the view does not remain
        displaced on the screen when the keyboard hides.
    
        - parameter notification: The NSNotification
    */
    func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    /**
        Returns the keyboard height.
    
        - parameter notification: The NSNotification
    */
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    /**
        Subscribes to keyboard notifications.
    */
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
        Unsubscribes to keyboard notifications.
    */
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
        Subscribes to rotation notifications.
    */
    func subscribeToRotationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.adjustContraintsForOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /**
        Unsubscribes to rotation notifications.
    */
    func unsubscribeToRotationNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // MARK: Meme Generating and Sharing
    /**
        Shares the generated meme image by presenting an Activity View Controller.
        Connected to the share button on the navigation bar.
    */
    @IBAction func shareMemedImage(_ sender: AnyObject) {
        // Generate meme image
        let memedImage = generateMemedImage()
        // Define instance of Activity View Controller
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // Present View Controller
        present(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            print("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            // Save the meme
            self.saveMemedImage()
            // Dismiss View Controller - if you place this outside the handler, the activityController will dismiss too early
            self.performSegue(withIdentifier: "unwindEdit", sender: nil)
        }
    }
    
    /**
        Save a generated meme object.
    */
    func saveMemedImage() {
        let memedImage = generateMemedImage()
        // Create meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        // Add meme to the meme array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    /**
        Generate a meme object with the top text, bottom text, selected image.
    
        - returns: memedImage The final meme image designed by the user.
    */
    func generateMemedImage() -> UIImage {
        // Hide tool bar and nav bar
        hideBottomToolbar()
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Get CGRect of image in imageView
        let cropRect: CGRect = calculateRectOfImage(imageView)
        // Draw new image in current image context
        let croppedImage: CGImage = memedImage.cgImage!.cropping(to: cropRect)!
        // Create new cropped UIImage
        let croppedMemedImage: UIImage = UIImage(cgImage: croppedImage)

        // Show tool bar and nav bar
        showBottomToolbar()
        
        return croppedMemedImage
    }
    
    /**
        Hides the bottom toolbar. The top navigation bar does not need to be hidden since we are currently only capturing an image of the underlying view.
    */
    func hideBottomToolbar() {
        bottomToolbar.isHidden = true
    }
    
    /**
        Shows the bottom toolbar.
    */
    func showBottomToolbar() {
        bottomToolbar.isHidden = false
    }
}
