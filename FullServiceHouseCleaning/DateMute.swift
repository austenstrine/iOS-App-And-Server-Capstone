//
//  DateMute.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Wednesday4/11/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct DateMute
{
    static let MONDAY = "MONDAY"
    static let TUESDAY = "TUESDAY"
    static let WEDNESDAY = "WEDNESDAY"
    static let THURSDAY = "THURSDAY"
    static let FRIDAY = "FRIDAY"
    static let SATURDAY = "SATURDAY"
    static let SUNDAY = "SUNDAY"
    
    static let JANUARY = "JANUARY"
    static let janAs01 = "01"
    static let janAs1 = "1"
    static let FEBRUARY = "FEBRUARY"
    static let febAs02 = "02"
    static let febAs2 = "2"
    static let MARCH = "MARCH"
    static let marAs03 = "03"
    static let marAs3 = "3"
    static let APRIL = "APRIL"
    static let aprAs04 = "04"
    static let aprAs4 = "4"
    static let MAY = "MAY"
    static let mayAs05 = "05"
    static let mayAs5 = "5"
    static let JUNE = "JUNE"
    static let junAs06 = "06"
    static let junAs6 = "6"
    static let JULY = "JULY"
    static let julAs07 = "07"
    static let julAs7 = "7"
    static let AUGUST = "AUGUST"
    static let augAs08 = "08"
    static let augAs8 = "8"
    static let SEPTEMBER = "SEPTEMBER"
    static let sepAs09 = "09"
    static let sepAs9 = "9"
    static let OCTOBER = "OCTOBER"
    static let octAs10 = "10"
    static let NOVEMBER = "NOVEMBER"
    static let novAs11 = "11"
    static let DECEMBER = "DECEMBER"
    static let decAs12 = "12"
    
    private static let dayAfterDict_caps = [
        DateMute.MONDAY : DateMute.TUESDAY,
        DateMute.TUESDAY : DateMute.WEDNESDAY,
        DateMute.WEDNESDAY : DateMute.THURSDAY,
        DateMute.THURSDAY : DateMute.FRIDAY,
        DateMute.FRIDAY : DateMute.SATURDAY,
        DateMute.SATURDAY : DateMute.SUNDAY,
        DateMute.SUNDAY : DateMute.MONDAY
    ]
    private static let monthAfterDict_caps = [
        DateMute.JANUARY : DateMute.FEBRUARY,
        DateMute.FEBRUARY : DateMute.MARCH,
        DateMute.MARCH : DateMute.APRIL,
        DateMute.APRIL : DateMute.MAY,
        DateMute.MAY : DateMute.JUNE,
        DateMute.JUNE : DateMute.JULY,
        DateMute.JULY : DateMute.AUGUST,
        DateMute.AUGUST : DateMute.SEPTEMBER,
        DateMute.SEPTEMBER : DateMute.OCTOBER,
        DateMute.OCTOBER : DateMute.NOVEMBER,
        DateMute.NOVEMBER : DateMute.DECEMBER,
        DateMute.DECEMBER : DateMute.JANUARY
    ]
    private static let monthBeforeDict_caps = [
        DateMute.FEBRUARY : DateMute.JANUARY,
        DateMute.MARCH : DateMute.FEBRUARY,
        DateMute.APRIL : DateMute.MARCH,
        DateMute.MAY : DateMute.APRIL,
        DateMute.JUNE : DateMute.MAY,
        DateMute.JULY : DateMute.JUNE,
        DateMute.AUGUST : DateMute.JULY,
        DateMute.SEPTEMBER : DateMute.AUGUST,
        DateMute.OCTOBER : DateMute.SEPTEMBER,
        DateMute.NOVEMBER : DateMute.OCTOBER,
        DateMute.DECEMBER : DateMute.NOVEMBER,
        DateMute.JANUARY : DateMute.DECEMBER
    ]
    private static let monthNameDigitDict_caps:[String:String] = [
        DateMute.JANUARY : DateMute.janAs01,     DateMute.janAs1 : DateMute.JANUARY,      DateMute.janAs01 : DateMute.JANUARY,
        DateMute.FEBRUARY : DateMute.febAs02,    DateMute.febAs2 : DateMute.FEBRUARY,     DateMute.febAs02 : DateMute.FEBRUARY,
        DateMute.MARCH : DateMute.marAs03,       DateMute.marAs3 : DateMute.MARCH,        DateMute.marAs03 : DateMute.MARCH,
        DateMute.APRIL : DateMute.aprAs04,       DateMute.aprAs4 : DateMute.APRIL,        DateMute.aprAs04 : DateMute.APRIL,
        DateMute.MAY : DateMute.mayAs05,         DateMute.mayAs5 : DateMute.MAY,          DateMute.mayAs05 : DateMute.MAY,
        DateMute.JUNE : DateMute.junAs06,        DateMute.junAs6 : DateMute.JUNE,         DateMute.junAs06 : DateMute.JUNE,
        DateMute.JULY : DateMute.julAs07,        DateMute.julAs7 : DateMute.JULY,         DateMute.julAs07 : DateMute.JULY,
        DateMute.AUGUST : DateMute.augAs08,      DateMute.augAs8 : DateMute.AUGUST,       DateMute.augAs08 : DateMute.AUGUST,
        DateMute.SEPTEMBER : DateMute.sepAs09,   DateMute.sepAs9 : DateMute.SEPTEMBER,    DateMute.sepAs09 : DateMute.SEPTEMBER,
        DateMute.OCTOBER : DateMute.octAs10,     DateMute.octAs10 : DateMute.OCTOBER,
        DateMute.NOVEMBER : DateMute.novAs11,    DateMute.novAs11 : DateMute.NOVEMBER,
        DateMute.DECEMBER : DateMute.decAs12,    DateMute.decAs12 : DateMute.DECEMBER
    ]
    static func theDayAfter(day:String) -> String!
    {
        return dayAfterDict_caps[day.uppercased()]
    }
    
    static func convertMonthNameToDigits(monthName:String!) -> String
    {
        return DateMute.monthNameDigitDict_caps[monthName.uppercased()]!
    }
    
    static func convertMonthDigitsToName(monthDigit:String) -> String
    {
        return DateMute.monthNameDigitDict_caps[monthDigit]!
    }
    
    static func convertMonthDigitsToName(monthDigit:Int) -> String
    {
        return DateMute.monthNameDigitDict_caps[String(monthDigit)]!
    }
    static func digitToZeroSafeString(digit:Int) -> String
    {
        switch digit
        {
        case 1...9:
            return "0"+String(digit)
        default:
            return String(digit)
        }
    }
    
    static func getDate(from YYYYMMDD:String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: Calendar.current.component(Calendar.Component.timeZone, from: Date()))
        let date:Date = dateFormatter.date(from: YYYYMMDD)!
        return date
    }
    
    static func dayOfWeekOfDate(YYYYMMDD:String) -> String
    {
        let date = DateMute.getDate(from: YYYYMMDD)
        let weekday = Calendar.current.component(.weekday, from:date)
        return DateMute.getWeekdayString(from: weekday)
    }
    
    static func getWeekdayString(from intVal:Int) -> String
    {
        switch intVal
        {
        case 1:
            return DateMute.SUNDAY
        case 2:
            return DateMute.MONDAY
        case 3:
            return DateMute.TUESDAY
        case 4:
            return DateMute.WEDNESDAY
        case 5:
            return DateMute.THURSDAY
        case 6:
            return DateMute.FRIDAY
        case 7:
            return DateMute.SATURDAY
        default:
            return "err"
        }
    }
    
    static func getMonthRangeCount(YYYYMMDD:String) -> Int
    {
        let date = DateMute.getDate(from: YYYYMMDD)
        return NSCalendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    static func getMonthRangeCount(from date:Date) -> Int
    {
        return NSCalendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    static func getTheMonthAfter(month:String) -> String
    {
        return DateMute.monthAfterDict_caps[month.uppercased()]!
    }
    
    static func getTheMonthAfter(monthDigit:String) -> String
    {
        let stringMonth = (DateMute.convertMonthDigitsToName(monthDigit: monthDigit)).uppercased()
        return DateMute.monthAfterDict_caps[stringMonth]!
    }
    
    static func getTheMonthBefore(month:String) -> String
    {
        return DateMute.monthBeforeDict_caps[month.uppercased()]!
    }
    
    static func getTheMonthBefore(monthDigit:String) -> String
    {
        let stringMonth = (DateMute.convertMonthDigitsToName(monthDigit: monthDigit)).uppercased()
        return DateMute.monthBeforeDict_caps[stringMonth]!
    }
}
