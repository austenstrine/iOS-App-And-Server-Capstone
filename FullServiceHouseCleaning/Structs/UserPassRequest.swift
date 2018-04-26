//
//  UserPassRequest.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/23/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct UserPassRequest:Codable
{
    let user: String
    let pass: String
    
    init(json: [String:Any])
    {
        user = json["user"] as? String ?? ""
        pass = json["pass"] as? String ?? ""
    }
    
    init(user:String,pass:String)
    {
        self.user = user
        self.pass = pass
    }
}
