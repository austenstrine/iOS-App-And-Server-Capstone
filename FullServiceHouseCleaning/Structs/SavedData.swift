//
//  SavedData.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/30/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct SavedData
{
    static let NAME = "name"
    static let SURNAME = "surname"
    static let STREET_ADDRESS = "streetAddress"
    static let CSZ = "csz"
    static let NUMBER = "number"
    static let USERNAME = "username"
    static let PASSWORD = "password"
    static let PLAN = "plan"
    static let USER_VISITS = "userVisits"
    static let USER_VISITS_STRINGS = "userVisitsStrings"
    
    let name:String
    let surname:String
    let streetAddress:String
    let csz:String
    let number:String
    let username:String
    let password:String
    var plan:String
    let userVisits:VisitsArray
    let userVisitsStrings:[[String]]
    
    init(dict:[String:Any])
    {
        name = dict[SavedData.NAME] as? String ?? ""
        surname = dict[SavedData.SURNAME] as? String ?? ""
        streetAddress = dict[SavedData.STREET_ADDRESS] as? String ?? ""
        csz = dict[SavedData.CSZ] as? String ?? ""
        number = dict[SavedData.NUMBER] as? String ?? ""
        username = dict[SavedData.USERNAME] as? String ?? ""
        password = dict[SavedData.PASSWORD] as? String ?? ""
        plan = dict[SavedData.PLAN] as? String ?? ""
        userVisits = dict[SavedData.USER_VISITS] as? VisitsArray ?? VisitsArray()
        userVisitsStrings = dict[SavedData.USER_VISITS_STRINGS] as? [[String]] ?? [[String]]()
    }

}
