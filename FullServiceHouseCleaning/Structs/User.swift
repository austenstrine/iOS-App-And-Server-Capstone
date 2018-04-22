//
//  UserInfo.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Sunday4/8/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct User: Decodable, Equatable
{
    let id:Int
    let first_name: String
    let last_name: String
    let plan_id: Int
    let street_address: String
    let city_state_zip: String
    let active: Int
    let number: String
    let username: String
    
    init (json: [String:Any])
    {
        id = json["id"] as? Int ?? -1
        first_name = json["first_name"] as? String ?? ""
        last_name = json["last_name"] as? String ?? ""
        plan_id = json["plan_id"] as? Int ?? -1
        street_address = json["street_address"] as? String ?? ""
        city_state_zip = json["city_state_zip"] as? String ?? ""
        active = json["active"] as? Int ?? -1
        number = json["number"] as? String ?? ""
        username = json["username"] as? String ?? ""
    }
}
