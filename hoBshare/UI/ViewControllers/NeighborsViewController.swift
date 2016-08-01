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
            mapView.removeAnnotation(users)
        }
        
        self.fetchUsersWithHobby(myHobbies![indexPath.row])
        
        let cell = collectionView.dataSource?.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! HobbyCollectionViewCell
        
        cell.backgroundColor = UIColor.redColor()
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
                        let me = User(name: "Me", hobbies: myHobbies!, lat: currentLocation!.coordinate.latitude, long: currentLocation!.coordinate.latitude)
                        
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

    
}
