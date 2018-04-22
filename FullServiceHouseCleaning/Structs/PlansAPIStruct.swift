//
//  dataAPIStruct.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

typealias PlansArray = [Plan]

struct PlansAPIStruct: Decodable
{
    let plans:PlansArray
}
