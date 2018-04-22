//
//  Plans.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct Plan: Decodable, Equatable
{
    let id:Int;
    let name: String;
    let rate: Int;
    let description: String;
    let image: String;
    
    init (json: [String:Any])
    {
        id = json["id"] as? Int ?? -1;
        name = json["name"] as? String ?? "";
        rate = json["rate"] as? Int ?? -1;
        description = json["description"] as? String ?? "";
        image = json ["image"] as? String ?? "";
    };
    
}
