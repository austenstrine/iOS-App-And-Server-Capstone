//
//  UserInfo.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Sunday4/8/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct User: Codable
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
        id = json[UserStrings.id] as? Int ?? -1
        first_name = json[UserStrings.first_name] as? String ?? ""
        last_name = json[UserStrings.last_name] as? String ?? ""
        plan_id = json[UserStrings.plan_id] as? Int ?? -1
        street_address = json[UserStrings.street_address] as? String ?? ""
        city_state_zip = json[UserStrings.city_state_zip] as? String ?? ""
        active = json[UserStrings.active] as? Int ?? -1
        number = json[UserStrings.number] as? String ?? ""
        username = json[UserStrings.username] as? String ?? ""
    }
}

struct UserStrings
{
    static let id = "id"
    static let first_name = "first_name"
    static let last_name = "last_name"
    static let plan_id = "plan_id"
    static let street_address = "street_address"
    static let city_state_zip = "city_state_zip"
    static let active = "active"
    static let number = "number"
    static let username = "username"
}
