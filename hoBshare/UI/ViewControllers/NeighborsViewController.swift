
//
//  NeighborsViewController.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 12/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import UIKit
import MapKit

class NeighborsViewController: HoBshareViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var users: [User]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let indexPathOfMyHobbiesCells = hobbiesCollectionView.indexPathsForVisibleItems()
        for index in indexPathOfMyHobbiesCells {
            let cell = hobbiesCollectionView.cellForItemAtIndexPath(index) as! HobbyCollectionViewCell
            if cell.tag != 0 {
                cell.view.backgroundColor = UIColor.darkGrayColor()
                cell.hobbyLabel.textColor = UIColor.whiteColor()
            }
        }
    }


    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last!
        locationManager.stopUpdatingLocation()
        self.centerMapOnCurrentLocation()
    }
    
    func centerMapOnCurrentLocation() {
        
        guard currentLocation != nil else {
            print("Current location unavailable.")
            return
        }
        
        mapView.setCenterCoordinate(currentLocation!.coordinate, animated: true)
        
        let currentRegion = mapView.regionThatFits(MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude), MKCoordinateSpanMake(0.5, 0.5)))
        mapView.setRegion(currentRegion, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let users = self.users {
            mapView.removeAnnotations(users)
        }
        
        self.fetchUsersWithHobby(myHobbies![indexPath.row])
        
        let cell = hobbiesCollectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
        
        let indexPathOfMyHobbiesCells = hobbiesCollectionView.indexPathsForVisibleItems()
        let indexPathsOfClickedItems = hobbiesCollectionView.indexPathsForSelectedItems()
        let indexPathOfClickedItem = indexPathsOfClickedItems![0]
        
        for index in indexPathOfMyHobbiesCells {
            let myHobbyCell = self.hobbiesCollectionView.cellForItemAtIndexPath(index) as! HobbyCollectionViewCell
            if index != indexPathOfClickedItem {
                if myHobbyCell.tag == 1 {
                    UIView.transitionWithView(myHobbyCell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                        UIView.animateWithDuration(0.9, animations: {
                            myHobbyCell.view.backgroundColor = UIColor.darkGrayColor()
                            myHobbyCell.hobbyLabel.textColor = UIColor.whiteColor()
                        })
                        }, completion: { (finished) in
                            myHobbyCell.tag = 0
                    })
                }
            }

        }
        if cell.tag == 0 {
            UIView.transitionWithView(cell.contentView, duration: 0.9, options: .TransitionFlipFromLeft, animations: {
                UIView.animateWithDuration(0.9, animations: {
                    cell.view.backgroundColor = UIColor(red: 69/255.0, green: 139/255.0, blue: 116/255.0, alpha: 1.0)
                    cell.hobbyLabel.textColor = UIColor.blackColor()
                })
                }, completion: { (finished) in
                    cell.tag = 1
            })
        }
        else {
            shakeAnimationForCell(cell)
        }
    }
    
    
    func fetchUsersWithHobby(hobby: Hobby) {
        
        guard (NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String)!.characters.count > 0 else {
            let alert = UIAlertController(title: kAppTitle, message: "Please login before selecting a hobby.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        //make REST call
        
        let requestUser = User()
        
        requestUser.userId = NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String
        requestUser.latitude = currentLocation?.coordinate.latitude
        requestUser.longitude = currentLocation?.coordinate.longitude
        
        UserDP().fetchUsersForHobby(requestUser, hobby: hobby) { (returnedListOfUsers) in
            
            if returnedListOfUsers.status.code == 0 {
                self.users = returnedListOfUsers.users
                
                //  remove users annotations from last hobby
                if let users = self.users {
                    self.mapView.removeAnnotations(users)
                    
                    // create a pin for each user and add it to the map
                    for user in users {
                        self.mapView.addAnnotation(user)
                    }
                    
                    //  zoom to show the nearest users in relation to the user's current position
                    if self.currentLocation != nil {
                        let me = User(username: "Me", hobbies: self.myHobbies!, lat: self.currentLocation!.coordinate.latitude, long: self.currentLocation!.coordinate.latitude)
                        
                        self.mapView.addAnnotation(me)
                        
                        let neighborsAndMe = users + [me]
                        
                        self.mapView.showAnnotations(neighborsAndMe, animated: true)
                    }
                    else {
                        self.mapView.showAnnotations(users, animated: true)
                    }
                }
            }
            else {
                self.showError(returnedListOfUsers.status.statusDescription!)
            }
        }
    }
    
    func shakeAnimationForCell(clickedCell: HobbyCollectionViewCell) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(clickedCell.view.center.x - 10, clickedCell.view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(clickedCell.view.center.x + 10, clickedCell.view.center.y))
        clickedCell.view.layer.addAnimation(animation, forKey: "position")
    }

}
