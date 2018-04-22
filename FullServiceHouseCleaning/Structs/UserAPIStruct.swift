//
//  UserAPIStruct.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/9/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

typealias UsersArray = [User]

struct UserAPIStruct: Decodable
{
    let user:UsersArray
}
