//
//  ViewController.swift
//  Filterer
//
//  Created by Delivery Resource on 05/02/16.
//  Copyright © 2016 Felipe Marino. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var filteredImage: UIImage?
    var originalImage: UIImage?
    var mountainImage: UIImage?
    var vikingImage: UIImage?
    var rubyImage: UIImage?

    var timer: NSTimer?
    
    var i=0;
    
    var tap = UILongPressGestureRecognizer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var sliderView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var originalLabel: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var mountainFilterButton: UIButton!
    @IBOutlet weak var vikingFilterButton: UIButton!
    @IBOutlet weak var rubyFilterButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        originalImage = UIImage(imageLiteral: "wow")
        
        compareButton.enabled = false;
        originalLabel.alpha = 1
        
        imagePressedEvent()
        
        mountainImage = returnFilteredImage(2, redOperator: "multiply", greenMultiplier: 2, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "multiply")
        
        vikingImage = returnFilteredImage(2, redOperator: "multiply", greenMultiplier: 2, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "divide")
        
        rubyImage = returnFilteredImage(2, redOperator: "multiply", greenMultiplier: 1, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "divide")
        
        editButton.enabled = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onFilter(sender: UIButton) {
        mountainFilterButton.enabled = true
        vikingFilterButton.enabled = true
        rubyFilterButton.enabled = true
        hideSliderView()
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        }
        else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    //  secondary menu show and hide funcs
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1
            
        }
    }
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    
    // slider view show and hide functions
    func showSliderView() {
        view.addSubview(sliderView)
        
        let bottomConstraint = sliderView.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = sliderView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = sliderView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = sliderView.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.sliderView.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.sliderView.alpha = 1
            
        }
    }
    
    func hideSliderView() {
        UIView.animateWithDuration(0.4, animations: {
            self.sliderView.alpha = 0
            }) { completed in
                if completed == true {
                    self.sliderView.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onShare(sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func onNewPhoto(sender: UIButton) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    
    //  Compare action
    @IBAction func onCompare(sender: UIButton) {
        
        if (imageView.image != originalImage) {
            
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions .TransitionCrossDissolve, animations: { () -> Void in
                self.imageView.image = self.originalImage
                self.originalLabel.alpha = 1
                self.hideSecondaryMenu()
                self.hideSliderView()
                self.filterButton.selected = false
                self.editButton.enabled = false;
                }
                , completion: nil)
        }
    }
    
    
    //  To edit the filtered image
    @IBAction func editAction(sender: UIButton) {
        intensitySlider.value = 1
        if (sender.selected) {
            hideSliderView()
            sender.selected = false
        }
        else {
            if (secondaryMenu.isDescendantOfView(view) == true) {
                UIView.animateWithDuration(0.4) {
                    self.hideSecondaryMenu()
                }
                hideSecondaryMenu()
                showSliderView()
                sender.selected = true
            }
        }
    }
    
    @IBAction func onFilterIntensity(sender: UISlider) {
        if (vikingFilterButton.enabled == false) {
            makefilter(2*Int(sender.value), redOperator: "multiply", greenMultiplier: 2*Int(sender.value), greenOperator: "multiply", blueMultiplier: 2*Int(sender.value), blueOperator: "divide")
        }
        
        if (mountainFilterButton.enabled == false) {
            makefilter(2*Int(sender.value), redOperator: "multiply", greenMultiplier: 2*Int(sender.value), greenOperator: "multiply", blueMultiplier: 2*Int(sender.value), blueOperator: "multiply")
        }
        if (rubyFilterButton.enabled == false){
            makefilter(2*Int(sender.value), redOperator: "multiply", greenMultiplier: 1*Int(sender.value), greenOperator: "multiply", blueMultiplier: 2*Int(sender.value), blueOperator:  "divide")
        }
    }
    
    //  Filters actions
    @IBAction func onMountainFilter(sender: UIButton) {
        makefilter(2, redOperator: "multiply", greenMultiplier: 2, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "multiply")
        mountainFilterButton.enabled = false
        vikingFilterButton.enabled = true
        rubyFilterButton.enabled = true
    }
    
    @IBAction func onVikingFilter(sender: UIButton) {
        makefilter(2, redOperator: "multiply", greenMultiplier: 2, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "divide")
        vikingFilterButton.enabled = false
        mountainFilterButton.enabled = true
        rubyFilterButton.enabled = true
    }
    
    @IBAction func onRubyFilter(sender: UIButton) {
       makefilter(2, redOperator: "multiply", greenMultiplier: 1, greenOperator: "multiply", blueMultiplier: 2, blueOperator: "divide")
        rubyFilterButton.enabled = false
        vikingFilterButton.enabled = true
        mountainFilterButton.enabled = true
    }

    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePressedEvent() {
        tap = UILongPressGestureRecognizer(target: self, action: "handleImagePress")
        tap.minimumPressDuration = 2.0
        imageView.addGestureRecognizer(tap)
    }
   
    //  image Tap
    func handleImagePress() {
        if (tap.state != UIGestureRecognizerState .Ended) {
            
            timer = NSTimer(timeInterval: 2.5, target: self, selector: "viewTransition", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
        else {
            timer?.invalidate()
            
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions .TransitionCrossDissolve, animations: { () -> Void in
                self.imageView.image = self.originalImage
                }
                , completion: nil)
            
            imageView.image = originalImage
            originalLabel.alpha = 1
        }
    }
    
    func nextImage() -> UIImage?{
        var images = [UIImage] (arrayLiteral: mountainImage!, vikingImage!, rubyImage!, originalImage!)
        i++;
        print("pressed")
            originalLabel.alpha = 0


        
        if (i == 4) {
            i = 0;
        }
        
        if (images[i] == originalImage) {
            originalLabel.alpha = 1
        }
        
        return images[i]
    }
    
    func viewTransition() {
        UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions .TransitionCrossDissolve, animations: { () -> Void in
            self.imageView.image = self.nextImage()
            }
            , completion: nil)
    }
    
    
    // This will receive values and make filter on just one method. On button events there's only a call to this.
    func makefilter(redMultiplier: Int, redOperator: String, greenMultiplier: Int, greenOperator: String, blueMultiplier: Int, blueOperator: String){
        let rgbaImage = RGBAImage(image: originalImage!)
        let avgRed = 59
        let avgGreen = 78
        let avgBlue = 77
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let index = y * rgbaImage!.width + x
                var pixel = rgbaImage?.pixels[index]
                let redDiff = Int(pixel!.red) - avgRed
                let greenDiff = Int(pixel!.green) - avgGreen
                let blueDiff = Int(pixel!.blue) - avgBlue
                if (redDiff > 0) {
                    if (redOperator == "multiply") {
                        pixel!.red = UInt8( max(0, min(255, avgRed + redDiff * redMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (redOperator == "divide"){
                        pixel!.red = UInt8( max(0, min(255, avgRed + redDiff / redMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
                if (greenDiff > 0) {
                    if (greenOperator == "multiply") {
                        pixel!.green = UInt8( max(0, min(255, avgGreen + greenDiff * greenMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (greenOperator == "divide") {
                        pixel!.green = UInt8( max(0, min(255, avgGreen + greenDiff / greenMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
                if (blueDiff > 0) {
                    if (blueOperator == "multiply") {
                        pixel!.blue = UInt8( max(0, min(255, avgBlue + blueDiff * blueMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (blueOperator == "divide") {
                        pixel!.blue = UInt8( max(0, min(255, avgBlue + blueDiff / blueMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
            }
        }
        let redImage = rgbaImage?.toUIImage()
        
        UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions .TransitionCrossDissolve, animations: { () -> Void in
            self.imageView.image = redImage
            self.compareButton.enabled = true
            self.originalLabel.alpha = 0
            self.editButton.enabled = true
            }
            , completion: nil)

    }
    
    func returnFilteredImage(redMultiplier: Int, redOperator: String, greenMultiplier: Int, greenOperator: String, blueMultiplier: Int, blueOperator: String) -> UIImage{
        let rgbaImage = RGBAImage(image: originalImage!)
        let avgRed = 59
        let avgGreen = 78
        let avgBlue = 77
        
        for y in 0..<rgbaImage!.height {
            for x in 0..<rgbaImage!.width {
                let index = y * rgbaImage!.width + x
                var pixel = rgbaImage?.pixels[index]
                let redDiff = Int(pixel!.red) - avgRed
                let greenDiff = Int(pixel!.green) - avgGreen
                let blueDiff = Int(pixel!.blue) - avgBlue
                if (redDiff > 0) {
                    if (redOperator == "multiply") {
                        pixel!.red = UInt8( max(0, min(255, avgRed + redDiff * redMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (redOperator == "divide"){
                        pixel!.red = UInt8( max(0, min(255, avgRed + redDiff / redMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
                if (greenDiff > 0) {
                    if (greenOperator == "multiply") {
                        pixel!.green = UInt8( max(0, min(255, avgGreen + greenDiff * greenMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (greenOperator == "divide") {
                        pixel!.green = UInt8( max(0, min(255, avgGreen + greenDiff / greenMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
                if (blueDiff > 0) {
                    if (blueOperator == "multiply") {
                        pixel!.blue = UInt8( max(0, min(255, avgBlue + blueDiff * blueMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                    else if (blueOperator == "divide") {
                        pixel!.blue = UInt8( max(0, min(255, avgBlue + blueDiff / blueMultiplier)))
                        rgbaImage?.pixels[index] = pixel!
                    }
                }
            }
        }
        let redImage = rgbaImage?.toUIImage()
        
        return redImage!
    }
    
}

