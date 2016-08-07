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
    
    var replaceEnabled: Bool = false {
        didSet {
            hobbiesCollectionView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.availableHobbiesCollectionView.delegate = self
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {   
        let cell: ReplaceableHobbyCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("HobbyCollectionViewCell", forIndexPath: indexPath) as! ReplaceableHobbyCollectionViewCell
        
        if collectionView == hobbiesCollectionView {
            let hobby = myHobbies![indexPath.item]
            cell.hobbyLabel.text = hobby.hobbyName
            if replaceEnabled == true {
                cell.replaceButton.hidden = false
            }
            else {
                cell.replaceButton.hidden = true
            }
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
            
            
            if myHobbies?.contains( { $0.hobbyName == hobby.hobbyName } ) == false {
                
                if myHobbies!.count < kMaxHobbies {
                    
                    myHobbies! += [hobby]
                    self.saveHobbies()
                    
                }
                else {
                    let alert = UIAlertController(title: kAppTitle, message: "You may only select up to \(kMaxHobbies) hobbies. Would you like to replace one of your hobbies?", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Replace", style: .Default, handler: { (action) in
                        self.replaceHobbie()
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        }
        else {
            
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
    }
    
    func replaceHobbie() {
        self.replaceEnabled = true
    }

}
