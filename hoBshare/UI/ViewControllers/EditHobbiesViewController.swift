//
//  EditHobbiesViewController.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 12/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import UIKit

class EditHobbiesViewController: HoBshareViewController {
    
    @IBOutlet weak var availableHobbiesCollectionView: UICollectionView!
    
    var replaceEnabled: Bool = false
    var selectedHobbyName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLongPress()
        self.availableHobbiesCollectionView.delegate = self
        hobbiesCollectionView.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:HobbyCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("HobbyCollectionViewCell", forIndexPath: indexPath) as! HobbyCollectionViewCell
        
        if collectionView == hobbiesCollectionView {
            let hobby = myHobbies![indexPath.item]
            cell.hobbyLabel.text = hobby.hobbyName
        }
        else {
            let key = Array(availableHobbies.keys)[indexPath.section]
            let hobbies = availableHobbies[key]
            let hobby = hobbies![indexPath.item]
            cell.hobbyLabel.text = hobby.hobbyName
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HobbyCategoryHeader", forIndexPath: indexPath)
        (reusableView as! HobbiesCollectionViewHeader).categoryLabel.text = Array(availableHobbies.keys)[indexPath.section]
        return reusableView
    }
    
    func saveHobbies() {
        let requestUser = User()
        
        requestUser.userId = NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String
        
        if let myHobbies = self.myHobbies {
            requestUser.hobbies = myHobbies
        }
        
        HobbyDP().saveHobbiesForUser(requestUser) { (returnedUser) -> () in
            
            if returnedUser.status.code == 0 {
                self.saveHobbiesToUserDefaults()
                self.hobbiesCollectionView.reloadData()
            }
            else {
                self.showError(returnedUser.status.statusDescription!)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView == availableHobbiesCollectionView {
            let key = Array(availableHobbies.keys)[indexPath.section]
            let hobbies = availableHobbies[key]
            let hobby = hobbies![indexPath.item]
            
            if replaceEnabled == false {
                if myHobbies?.contains( { $0.hobbyName == hobby.hobbyName } ) == false {
                    
                    if myHobbies!.count < kMaxHobbies {
                        
                        myHobbies! += [hobby]
                        self.saveHobbies()
                    }
                    else {
                        let alert = UIAlertController(title: kAppTitle, message: "You may only select up to \(kMaxHobbies) hobbies. Press and hold an available hobby to choose a hobby to replace!", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        })
                        
                        alert.addAction(cancelAction)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            
        }
        else {
            if (replaceEnabled == false) {
                let alert = UIAlertController(title: kAppTitle, message: "Would you like to delete this hobby?", preferredStyle: .Alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
                    
                    self.myHobbies!.removeAtIndex(indexPath.item)
                    self.saveHobbies()
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.myHobbies![indexPath.item].hobbyName = selectedHobbyName
                replaceEnabled = false
                self.saveHobbies()
                
                
                let availableHobbiesCellsIndexPath = self.availableHobbiesCollectionView.indexPathsForVisibleItems()
                
                for indexPath in availableHobbiesCellsIndexPath {
                    let cell = self.availableHobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    if (cell.tag == 1) {
                        UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                            cell.view.backgroundColor = UIColor.darkGrayColor()
                            cell.hobbyLabel.textColor = UIColor.whiteColor()
                            }, completion: { (finished) in
                                cell.tag = 0
                        })
                    }
                }
                
                let myHobbiesCellsIndexPath = self.hobbiesCollectionView.indexPathsForVisibleItems()
                
                for indexPath in myHobbiesCellsIndexPath {
                    let cell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        cell.view.backgroundColor = UIColor.darkGrayColor()
                        }, completion: { (finished) in
                    })
                }
                
                

            }
        }
    }
    
}

extension EditHobbiesViewController: UIGestureRecognizerDelegate {
    
    func setUpLongPress() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.availableHobbiesCollectionView.addGestureRecognizer(lpgr)
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Ended {
            return
        }
        
        let point = gestureRecognizer.locationInView(self.availableHobbiesCollectionView)
        let indexPath = self.availableHobbiesCollectionView.indexPathForItemAtPoint(point)
        
        if let index = indexPath {
            let cell = self.availableHobbiesCollectionView.cellForItemAtIndexPath(index) as! HobbyCollectionViewCell
            
            var availableHobbiesCellsIndexPath = self.availableHobbiesCollectionView.indexPathsForVisibleItems()
            availableHobbiesCellsIndexPath.removeAtIndex(indexPath!.item)
            
            for indexPath in availableHobbiesCellsIndexPath {
                let cell = self.availableHobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                if cell.tag == 1 {
                    UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: { 
                            cell.view.backgroundColor = UIColor.darkGrayColor()
                            cell.hobbyLabel.textColor = UIColor.whiteColor()
                        })
                        }, completion: { (finished) in
                            cell.tag = 0
                    })
                    self.replaceEnabled = true
                }
            }
            
            if myHobbies?.contains( { $0.hobbyName == cell.hobbyLabel.text } ) == false {
                if cell.tag != 1 {
                    UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: {
                            cell.view.backgroundColor = UIColor(red: 69/255.0, green: 139/255.0, blue: 116/255.0, alpha: 1.0)
                            cell.hobbyLabel.textColor = UIColor.blackColor()
                        })
                        }, completion: { (finished) in
                            cell.tag = 1
                            self.selectedHobbyName = cell.hobbyLabel.text!
                    })
                    self.replaceEnabled = true
                }
                else {
                    UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: {
                            cell.view.backgroundColor = UIColor.darkGrayColor()
                            cell.hobbyLabel.textColor = UIColor.whiteColor()
                        })
                        }, completion: { (finished) in
                            cell.tag = 0
                    })
                    self.replaceEnabled = false
                }
            }
            
            let myHobbiesCellsIndexPath = self.hobbiesCollectionView.indexPathsForVisibleItems()
            
            for indexPath in myHobbiesCellsIndexPath {
                if myHobbies?.contains( { $0.hobbyName == cell.hobbyLabel.text } ) == false {
                    if cell.tag == 0 {
                        let cell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                        UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                            cell.view.backgroundColor = UIColor(red: 238/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
                            }, completion: { (finished) in
                                cell.tag = 1
                        })
                    }
                }
                else {
                    let myCell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    if myCell.hobbyLabel.text == cell.hobbyLabel.text {
                        let animation = CABasicAnimation(keyPath: "position")
                        animation.duration = 0.07
                        animation.repeatCount = 4
                        animation.autoreverses = true
                        animation.fromValue = NSValue(CGPoint: CGPointMake(cell.view.center.x - 10, cell.view.center.y))
                        animation.toValue = NSValue(CGPoint: CGPointMake(cell.view.center.x + 10, cell.view.center.y))
                        cell.view.layer.addAnimation(animation, forKey: "position")
                        myCell.view.layer.addAnimation(animation, forKey: "position")
                    }
                }
                if cell.tag == 1{
                    let cell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        cell.view.backgroundColor = UIColor.darkGrayColor()
                        }, completion: { (finished) in
                            cell.tag = 0
                    })
                }
            }
        }
    }
    
}
