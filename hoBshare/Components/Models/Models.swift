//
//  Models.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 16/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import Foundation
import MapKit

extension Array {
    
    var allValuesAreHobbies: Bool {
        var returnValue = true
        
        for value in self {
            if value is Hobby == false {
                returnValue = false
            }
        }
        return returnValue
    }
    
    func toString() -> String {
        var returnString = ""
        
        if allValuesAreHobbies == true {
            for i in 0...self.count - 1 {
                let value = self[i] as! Hobby
                
                if i == 0 {
                    returnString += value.hobbyName!
                }
                else {
                    returnString += ", " + value.hobbyName!
                }
            }
        }
        return returnString
    }
}

class User: SFLBaseModel, JSONSerializable, MKAnnotation {
    var userId: String?
    var username: String?
    var latitude: Double?
    var longitude: Double?
    var hobbies = [Hobby]()
    var searchHobby: Hobby?
    
    override init() {
        super.init()
        self.delegate = self
    }
    
    init(username: String) {
        super.init()
        self.delegate = self
        self.username = username
    }
    
    convenience init(username: String, hobbies: [Hobby], lat: Double, long: Double) {
        self.init(username: username)
        self.latitude = lat
        self.longitude = long
        self.hobbies = hobbies
    }
    
    
    override func getJSONDictionary() -> NSDictionary {
        let dict = super.getJSONDictionary()
        
        if self.userId != nil {
            dict.setValue(self.userId, forKey: kUserId)
        }
        if self.username != nil {
            dict.setValue(self.username, forKey: kUsername)
        }
        if self.latitude != nil {
            dict.setValue(self.latitude, forKey: kLatitude)
        }
        if self.longitude != nil {
            dict.setValue(self.longitude, forKey: kLongitude)
        }
        
        var jsonSafeHobbiesArray = [String]()
        
        for hobby in self.hobbies {
            jsonSafeHobbiesArray.append(hobby.hobbyName!)
        }
        
        dict.setValue(jsonSafeHobbiesArray, forKey: kHobbies)
        
        if self.searchHobby != nil {
            dict.setValue(self.searchHobby!.hobbyName!, forKey: kHobbySearch)
        }
        
        return dict
    }
    
    override func readFromJSONDictionary(dict: NSDictionary) {
        super.readFromJSONDictionary(dict)
        
        self.userId = dict[kUserId] as? String
        self.username = dict[kUsername] as? String
        self.latitude = dict[kLatitude] as? Double
        self.longitude = dict[kLongitude] as? Double
        
        let returnedHobbies = dict[kHobbies] as? NSArray
        
        if let hobbies = returnedHobbies {
            self.hobbies = Hobby.deserializeHobbies(hobbies)
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:  self.latitude!, longitude: self.longitude!)
        }
    }
    
    var title: String? {
        get {
            return self.username
        }
    }
    
    var subtitle: String? {
        get {
            var hobbiesAsString = ""
            
            print(self.username! + ": " + hobbies.toString())
            
            hobbiesAsString = hobbies.toString()
            
            return hobbiesAsString
        }
    }
    
}

class ListOfUsers: SFLBaseModel, JSONSerializable {
    
    var users = [User]()
    
    override init() {
        super.init()
        self.delegate = self
    }
    
    override func readFromJSONDictionary(dict: NSDictionary) {
        super.readFromJSONDictionary(dict)
        
        if let returnedUsers = dict["ListOfUsers"] as? NSArray {
            
            for dict in returnedUsers {
                
                let user = User()
                user.readFromJSONDictionary(dict as! NSDictionary)
                self.users.append(user)
            }
        }
    }
    
    override func getJSONDictionary() -> NSDictionary {
        let dict = super.getJSONDictionary()
        return dict
    }
    
    override func getJSONDictionaryString() -> NSString {
        return super.getJSONDictionaryString()
    }
    
    
}

class Hobby: SFLBaseModel, NSCoding {
    
    var hobbyName:String?
    
    init(hobbyName: String) {
        super.init()
        self.hobbyName = hobbyName
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hobbyName = aDecoder.decodeObjectForKey(kHobbyName) as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.hobbyName, forKey: kHobbyName)
    }
    
    class func deserializeHobbies(hobbies: NSArray) -> Array<Hobby> {
        var returnArray = Array<Hobby>()
        
        for hobby in hobbies {
            if let hobbyName = hobby as? String {
                returnArray.append(Hobby(hobbyName: hobbyName))
            }
        }
        
        return returnArray
    }
    
}


