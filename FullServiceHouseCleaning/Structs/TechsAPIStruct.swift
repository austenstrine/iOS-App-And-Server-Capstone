//
//  TechsAPIStruct.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Tuesday4/3/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

typealias TechsArray = [Tech]

struct TechsAPIStruct: Decodable
{
    let techs:TechsArray
}
