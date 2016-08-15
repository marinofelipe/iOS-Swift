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
                
                doHobbyReplaceAnimationFor(self.availableHobbiesCollectionView)
                doHobbyReplaceAnimationFor(self.hobbiesCollectionView)
            }
        }
    }
    
    func doHobbyReplaceAnimationFor(collectionView: UICollectionView) {
        let indexPathOfAvailableHobbiesCells = collectionView.indexPathsForVisibleItems()
        
        for indexPath in indexPathOfAvailableHobbiesCells {
            let hobbyCell = collectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
            if (hobbyCell.tag == 1) {
                UIView.transitionWithView(hobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                    hobbyCell.view.backgroundColor = UIColor.darkGrayColor()
                    
                    if collectionView == self.availableHobbiesCollectionView {
                        hobbyCell.hobbyLabel.textColor = UIColor.whiteColor()
                    }
                    }, completion: { (finished) in
                        if collectionView == self.availableHobbiesCollectionView {
                            hobbyCell.tag = 0
                        }
                })
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
            let clickedAvailableHobbyCell = self.availableHobbiesCollectionView.cellForItemAtIndexPath(index) as! HobbyCollectionViewCell
            
            var indexPathOfAvailableHobbiesCells = self.availableHobbiesCollectionView.indexPathsForVisibleItems()
            indexPathOfAvailableHobbiesCells.removeAtIndex(index.item)
            
            for indexPath in indexPathOfAvailableHobbiesCells {
                let availableHobbyCell = self.availableHobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                if availableHobbyCell.tag == 1 {
                    UIView.transitionWithView(availableHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: { 
                            availableHobbyCell.view.backgroundColor = UIColor.darkGrayColor()
                            availableHobbyCell.hobbyLabel.textColor = UIColor.whiteColor()
                        })
                        }, completion: { (finished) in
                            availableHobbyCell.tag = 0
                    })
                    self.replaceEnabled = true
                }
            }
            
            if myHobbies?.contains( { $0.hobbyName == clickedAvailableHobbyCell.hobbyLabel.text } ) == false {
                if clickedAvailableHobbyCell.tag != 1 {
                    UIView.transitionWithView(clickedAvailableHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: {
                            clickedAvailableHobbyCell.view.backgroundColor = UIColor(red: 69/255.0, green: 139/255.0, blue: 116/255.0, alpha: 1.0)
                            clickedAvailableHobbyCell.hobbyLabel.textColor = UIColor.blackColor()
                        })
                        }, completion: { (finished) in
                            clickedAvailableHobbyCell.tag = 1
                            self.selectedHobbyName = clickedAvailableHobbyCell.hobbyLabel.text!
                    })
                    self.replaceEnabled = true
                }
                else {
                    UIView.transitionWithView(clickedAvailableHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: {
                            clickedAvailableHobbyCell.view.backgroundColor = UIColor.darkGrayColor()
                            clickedAvailableHobbyCell.hobbyLabel.textColor = UIColor.whiteColor()
                        })
                        }, completion: { (finished) in
                            clickedAvailableHobbyCell.tag = 0
                    })
                    self.replaceEnabled = false
                }
            }
            
            
            let indexPathOfMyHobbiesCells = self.hobbiesCollectionView.indexPathsForVisibleItems()
            
            for indexPath in indexPathOfMyHobbiesCells {
                if myHobbies?.contains( { $0.hobbyName == clickedAvailableHobbyCell.hobbyLabel.text } ) == false {
                    if clickedAvailableHobbyCell.tag == 0 {
                        let myHobbyCell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                        UIView.transitionWithView(myHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                            myHobbyCell.view.backgroundColor = UIColor(red: 238/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
                            }, completion: { (finished) in
                                myHobbyCell.tag = 1
                        })
                    }
                }
                else {
                    let myHobbyCell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    if myHobbyCell.hobbyLabel.text == clickedAvailableHobbyCell.hobbyLabel.text {
                        clickedAvailableHobbyCell.view.shake()
                        myHobbyCell.view.shake()
                    }
                }
                if clickedAvailableHobbyCell.tag == 1{
                    let myHobbyCell = self.hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
                    UIView.transitionWithView(myHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        myHobbyCell.view.backgroundColor = UIColor.darkGrayColor()
                        }, completion: { (finished) in
                            myHobbyCell.tag = 0
                    })
                }
            }
        }
    }
    
}
