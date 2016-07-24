//
//  DataProviders.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 16/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import Foundation

let serverPath = "http://uci.smilefish.com/HBSRest-dev/api/"
let endpoint = "HobbyRest"

class UserDP: NSObject {
    
    func getAccountForUser(user: User, completion: (User) -> ()) {
        let requestUrlString = serverPath + endpoint
        let HTTPMethod = "CREATE_USER"
        let requestModel = user
        
        SFLConnection().ajax(requestUrlString, verb: HTTPMethod, requestBody: requestModel) { (returnJSONDict) in
            
            let dict = NSDictionary(dictionary: returnJSONDict)
            
            let returnedUser = User()
            returnedUser.readFromJSONDictionary(dict)
            
            completion(returnedUser)
        }
    }
}

class HobbyDP: NSObject {
    
    
    func fetchHobbies() -> [String : [Hobby]]
    {
        
        return ["Technology" : [Hobby(hobbyName:"Video Games"),
            Hobby(hobbyName:"Computers"),
            Hobby(hobbyName:"IDEs"),
            Hobby(hobbyName:"Smartphones"),
            Hobby(hobbyName:"Programming"),
            Hobby(hobbyName:"Electronics"),
            Hobby(hobbyName:"Gadgets"),
            Hobby(hobbyName:"Product Reviews"),
            Hobby(hobbyName:"Computer Repair"),
            Hobby(hobbyName:"Software"),
            Hobby(hobbyName:"Hardware"),
            Hobby(hobbyName:"Apple"),
            Hobby(hobbyName:"Google"),
            Hobby(hobbyName:"Microsoft")]]
        
    }
}