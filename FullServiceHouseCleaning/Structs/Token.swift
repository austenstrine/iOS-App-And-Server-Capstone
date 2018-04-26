//
//  Token.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/9/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct Token: Decodable
{
    let token:String
    let id:Int
    init (json:[String:Any])
    {
        token = json["token"] as? String ?? ""
        id = json["id"] as? Int ?? -1
    }
}
