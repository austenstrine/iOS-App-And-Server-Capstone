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
    let monday = "MONDAY"
    let tuesday = "TUESDAY"
    let wednesday = "WEDNESDAY"
    let thursday = "THURSDAY"
    let friday = "FRIDAY"
    let saturday = "SATURDAY"
    let sunday = "SUNDAY"
    
    private let dayAfterDict_caps = [
        "MONDAY":"TUESDAY",
        "TUESDAY" :"WEDNESDAY",
        "WEDNESDAY":"THURSDAY",
        "THURSDAY":"FRIDAY",
        "FRIDAY":"SATURDAY",
        "SATURDAY":"SUNDAY",
        "SUNDAY":"MONDAY"
    ]
    private let monthAfterDict_caps = [
        "JANUARY":"FEBRUARY",
        "FEBRUARY":"MARCH",
        "MARCH":"APRIL",
        "APRIL":"MAY",
        "MAY":"JUNE",
        "JUNE":"JULY",
        "JULY":"AUGUST",
        "AUGUST":"SEPTEMBER",
        "SEPTEMBER":"OCTOBER",
        "OCTOBER":"NOVEMBER",
        "NOVEMBER":"DECEMBER",
        "DECEMBER":"JANUARY"
    ]
    private let monthBeforeDict_caps = [
        "FEBRUARY":"JANUARY",
        "MARCH":"FEBRUARY",
        "APRIL":"MARCH",
        "MAY":"APRIL",
        "JUNE":"MAY",
        "JULY":"JUNE",
        "AUGUST":"JULY",
        "SEPTEMBER":"AUGUST",
        "OCTOBER":"SEPTEMBER",
        "NOVEMBER":"OCTOBER",
        "DECEMBER":"NOVEMBER",
        "JANUARY":"DECEMBER"
    ]
    private let monthNameDict_caps:[String:String] = [
        "JANUARY":"01",
        "FEBRUARY":"02",
        "MARCH":"03",
        "APRIL":"04",
        "MAY":"05",
        "JUNE":"06",
        "JULY":"07",
        "AUGUST":"08",
        "SEPTEMBER":"09",
        "OCTOBER":"10",
        "NOVEMBER":"11",
        "DECEMBER":"12"
    ]
    private let monthDigitDict_caps:[String:String] = [
        "1":"JANUARY",
        "01":"JANUARY",
        "2":"FEBRUARY",
        "02":"FEBRUARY",
        "3":"MARCH",
        "03":"MARCH",
        "4":"APRIL",
        "04":"APRIL",
        "5":"MAY",
        "05":"MAY",
        "6":"JUNE",
        "06":"JUNE",
        "7":"JULY",
        "07":"JULY",
        "8":"AUGUST",
        "08":"AUGUST",
        "9":"SEPTEMBER",
        "09":"SEPTEMBER",
        "10":"OCTOBER",
        "11":"NOVEMBER",
        "12":"DECEMBER"
    ]
    func theDayAfter(day:String) -> String!
    {
        return dayAfterDict_caps[day.uppercased()]
    }
    
    func convertMonthNameToDigits(monthName:String!) -> String
    {
        return self.monthNameDict_caps[monthName.uppercased()]!
    }
    
    func convertMonthDigitsToName(monthDigit:String) -> String
    {
        return self.monthDigitDict_caps[monthDigit]!
    }
    
    func convertMonthDigitsToName(monthDigit:Int) -> String
    {
        return self.monthDigitDict_caps[String(monthDigit)]!
    }
    
    func getDate(from YYYYMMDD:String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Calendar.current.component(Calendar.Component.timeZone, from: Date()))
        let date:Date = dateFormatter.date(from: YYYYMMDD)!
        return date
    }
    
    func dayOfWeekOfDate(YYYYMMDD:String) -> String
    {
        let date = self.getDate(from: YYYYMMDD)
        let weekday = Calendar.current.component(.weekday, from:date)
        return self.getWeekdayString(from: weekday)
    }
    
    func getWeekdayString(from intVal:Int) -> String
    {
        switch intVal
        {
        case 1:
            return self.sunday
        case 2:
            return self.monday
        case 3:
            return self.tuesday
        case 4:
            return self.wednesday
        case 5:
            return self.thursday
        case 6:
            return self.friday
        case 7:
            return self.saturday
        default:
            return "err"
        }
    }
    
    func getMonthRangeCount(YYYYMMDD:String) -> Int
    {
        let date = self.getDate(from: YYYYMMDD)
        return NSCalendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    func getMonthRangeCount(from date:Date) -> Int
    {
        return NSCalendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    func getTheMonthAfter(month:String) -> String
    {
        return self.monthAfterDict_caps[month.uppercased()]!
    }
    
    func getTheMonthAfter(monthDigit:String) -> String
    {
        let stringMonth = (self.convertMonthDigitsToName(monthDigit: monthDigit)).uppercased()
        return self.monthAfterDict_caps[stringMonth]!
    }
    
    func getTheMonthBefore(month:String) -> String
    {
        return self.monthBeforeDict_caps[month.uppercased()]!
    }
    
    func getTheMonthBefore(monthDigit:String) -> String
    {
        let stringMonth = (self.convertMonthDigitsToName(monthDigit: monthDigit)).uppercased()
        return self.monthBeforeDict_caps[stringMonth]!
    }
}

class YearData {
    
    var number = 2018
    var month = MonthDataSets().year[2018]
    
    func selectNewYear(newYear: Int)
    {
        self.number = newYear
        //change month data here as appropriate. Eventually, the month var will be assigned from a private array of all the different month info for each year. It would just be reassigned, like self.month = self.monthDataSets[String(newYear)]
    }
    
    struct MonthDataSets{
        let year =
            [
                2018:[
                    "JANUARY":["start":"MONDAY",
                               "days":"31",
                               "number":"01"],
                    "FEBRUARY":["start":"THURSDAY",
                                "days":"28",
                                "number":"02"],
                    "MARCH":["start":"FRIDAY",
                             "days":"31",
                             "number":"03"],
                    "APRIL":["start":"WEDNESDAY",
                             "days":"30",
                             "number":"04"],
                    "MAY":["start":"FRIDAY",
                           "days":"31",
                           "number":"05"],
                    "JUNE":["start":"MONDAY",
                            "days":"30",
                            "number":"06"],
                    "JULY":["start":"SUNDAY",
                            "days":"31",
                            "number":"07"],
                    "AUGUST":["start":"WEDNESDAY",
                              "days":"31",
                              "number":"08"],
                    "SEPTEMBER":["start":"SATURDAY",
                                 "days":"30",
                                 "number":"09"],
                    "OCTOBER":["start":"MONDAY",
                               "days":"31",
                               "number":"10"],
                    "NOVEMBER":["start":"THURSDAY",
                                "days":"30",
                                "number":"11"],
                    "DECEMBER":["start":"SATURDAY",
                                "days":"31",
                                "number":"12"]
                ],
                2019:[
                    "JANUARY":["start":"?",
                               "days":"31",
                               "number":"01"],
                    "FEBRUARY":["start":"?",
                                "days":"28",
                                "number":"02"],
                    "MARCH":["start":"?",
                             "days":"31",
                             "number":"03"],
                    "APRIL":["start":"?",
                             "days":"30",
                             "number":"04"],
                    "MAY":["start":"?",
                           "days":"31",
                           "number":"05"],
                    "JUNE":["start":"?",
                            "days":"30",
                            "number":"06"],
                    "JULY":["start":"?",
                            "days":"31",
                            "number":"07"],
                    "AUGUST":["start":"?",
                              "days":"31",
                              "number":"08"],
                    "SEPTEMBER":["start":"?",
                                 "days":"30",
                                 "number":"09"],
                    "OCTOBER":["start":"?",
                               "days":"31",
                               "number":"10"],
                    "NOVEMBER":["start":"?",
                                "days":"30",
                                "number":"11"],
                    "DECEMBER":["start":"?",
                                "days":"31",
                                "number":"12"]
                ]
        ]
    }
}
