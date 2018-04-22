//
//  ScheduledVisitsAPIStruct.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Tuesday4/3/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

typealias VisitsArray = [ScheduledVisit]

struct ScheduledVisitsAPIStruct: Decodable
{
    let scheduled_visits:VisitsArray
}
