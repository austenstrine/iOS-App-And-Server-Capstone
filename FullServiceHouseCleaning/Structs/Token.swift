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
    init (json:[String:Any])
    {
        token = json["token"] as? String ?? ""
    }
}
