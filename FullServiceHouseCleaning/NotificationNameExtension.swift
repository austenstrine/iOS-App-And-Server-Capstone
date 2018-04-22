//
//  NotificationNameExtension.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/16/18.
//  Copyright © 2018 Student. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let gotNewToken = Notification.Name(rawValue: "gotNewToken")
    static let needsNewToken = Notification.Name(rawValue: "needsNewToken")
}
