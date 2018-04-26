//
//  Techs.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Tuesday4/3/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct Tech: Codable
{
    let id:Int
    let name:String
    
    init (json: [String:Any])
    {
        id = json["id"] as? Int ?? -1
        name = json["name"] as? String ?? ""
    }
}
