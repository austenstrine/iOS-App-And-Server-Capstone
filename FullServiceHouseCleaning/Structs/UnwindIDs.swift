//
//  UnwindIDs.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/30/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct UnwindIDs
{
    static let nav = NavControllerIDs()
    static let error = ErrorControllerIDs()
    static let login = LoginControllerIDs()
    static let calendar = CalendarControllerIDs()
    static let contact = ContactControllerIDs()
    static let plans = PlansControllerIDs()
    static let profile = ProfileControllerIDs()
    static let home = HomeControllerIDs()
    
}

struct NavControllerIDs
{
    let noUnwinds = true
}
struct ErrorControllerIDs
{
    let unwindToHome = "unwindToHome"
}
struct LoginControllerIDs
{
    let unwindToHome = "unwindToHome"
}
struct CalendarControllerIDs
{
    let unwindToPlansView = "unwindToPlansView"
}
struct ContactControllerIDs
{
    let noUnwinds = true
}
struct PlansControllerIDs
{
    let unwindToProfileView = "unwindToProfileView"
    let unwindToCalendarView = "unwindToCalendarView"
}
struct ProfileControllerIDs
{
    let unwindToLoginPopupView = "unwindToLoginPopupView"
}
struct HomeControllerIDs
{
    let noUnwinds = true
}
