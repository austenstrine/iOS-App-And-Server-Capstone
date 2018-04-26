//
//  ScheduledVisits.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Tuesday4/3/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct ScheduledVisit: Codable
{
    let user_id:Int
    let plan_id: Int
    let tech_id: Int
    let date: String
    let time: Int
    
    init (json: [String:Any])
    {
        user_id = json["user_id"] as? Int ?? -1
        plan_id = json["plan_id"] as? Int ?? -1
        tech_id = json["tech_id"] as? Int ?? -1
        date = json["date"] as? String ?? ""
        time = json ["time"] as? Int ?? -1
    }
}
