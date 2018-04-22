//
//  CalendarViewController.swift
//  FullServiceHouseCleaning
//
//  Created by Student on 3/19/18.
//  Copyright © 2018 Student. All rights reserved.
//  make calendar start on current date and grey out any days before and including current date
//  make cells still have user interaction, have function triggered by tap check color of cell,
//  if grey, give an alert that says the tech is not available on this date.
//  else, normal scheduling alert runs

import UIKit

class CalendarViewController: SocketedViewController
{
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var day1Label: UILabel!
    @IBOutlet weak var day2Label: UILabel!
    @IBOutlet weak var day3Label: UILabel!
    @IBOutlet weak var day4Label: UILabel!
    @IBOutlet weak var day5Label: UILabel!
    @IBOutlet weak var day6Label: UILabel!
    @IBOutlet weak var day7Label: UILabel!
    
    @IBOutlet weak var tech3Button: UIButton!
    @IBOutlet weak var tech2Button: UIButton!
    @IBOutlet weak var tech1Button: UIButton!
    @IBOutlet weak var currentPlanLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: CalendarCollectionView!
    
    var planSelected:String! = "Timeless"
    var selectedMonth:String! = "MARCH"
    var selectedYear = "2018"
    var selectedTech:String? = nil
    var userAddress:String! = "Loading Information..."
    var userID:String! = "1"
    var date:String! = ""
    var time:String! = ""
    var didUnwind:Bool! = false
    let currentDate = Date()
    let currentMonth = Calendar.current.component(.month, from:Date())
    let dm = DateMute()
    
    private var datesArray = [String]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        currentPlanLabel.text = "Current Plan: "+planSelected
        
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        let month = Calendar.current.component(.month, from: currentDate)
        selectedMonth = dm.convertMonthDigitsToName(monthDigit: month)
        currentPlanLabel.text = "Current Plan: "+planSelected
        setTechButtonTitles()
        if selectedTech == nil
        {
            tech1ButtonTapped(tech1Button)
        }
        print()
        getPlansTask().resume()
        getScheduledVisitsTask().resume()
        //getTechsTask().resume()
        validateUserInfoData(deferredUIUpdateFunc:
        {   () -> Void in
                self.userAddress = self.arrayOfUserInfo[0].street_address + self.arrayOfUserInfo[0].city_state_zip
                var planName:String?
                for plan in self.arrayOfPlans
                {
                    if plan.id == self.arrayOfUserInfo[0].plan_id
                    {
                        planName = plan.name
                        break
                    }
                }
                self.planSelected = planName
        })
        socket.on("scheduled_visits_updated")
        {
            data, ack in
            let task = self.getScheduledVisitsTask(deferredUIUpdateFunc: self.reloadCalendar)
            task.resume()
        }
        setMonthAndDays()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToCalendarView(sender: UIStoryboardSegue)
    {
        print("++++++++++")
        print("UNWIND TO CALENDAR")
        print("++++++++++")
        if let sourceViewController = sender.source as? PlansViewController
        {
            sourceViewController.didUnwind = true
            self.planSelected = sourceViewController.selectedPlanName!
            print("sourceViewController.selectedPlanName! == "+String(sourceViewController.selectedPlanName!))
            self.socket = sourceViewController.socket
            self.token = sourceViewController.token
            self.clientLock = sourceViewController.clientLock
        }
        //self.viewDidLoad()
    }
    
    @IBAction func changePlanTapped(_ sender: Any)
    {
        print("++++++++++")
        print("CHANGE PLAN TAPPED")
        print("++++++++++")
        if self.didUnwind == false
        {
            var doesNotHavePlansViewController:Bool! = true
            for vc in self.navigationController!.viewControllers
            {
                if vc is PlansViewController
                {
                    doesNotHavePlansViewController = false
                    break
                }
            }
            if doesNotHavePlansViewController
            {
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print("!!Plans View not found in Nav !!")
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print(self.navigationController!.viewControllers)
                let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "PlansViewController") as! PlansViewController
                nextViewController.selectedPlanName = self.planSelected
                nextViewController.socket = self.socket
                nextViewController.token = self.token
                nextViewController.clientLock = self.clientLock
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            else
            {
                self.performSegue(withIdentifier: "unwindToPlansView", sender: self)
            }
            
        }
        self.didUnwind = false//might be unnecessary
    }
    
    @IBAction func tech1ButtonTapped(_ sender: Any)
    {
        self.selectedTech = self.tech1Button.titleLabel!.text
        calendarCollectionView.backgroundColor = tech1Button.backgroundColor
        calendarCollectionView.reloadData()
    }
    @IBAction func tech2ButtonTapped(_ sender: Any)
    {
        self.selectedTech = self.tech2Button.titleLabel!.text
        self.calendarCollectionView.backgroundColor = tech2Button.backgroundColor
        self.calendarCollectionView.reloadData()
    }
    @IBAction func tech3ButtonTapped(_ sender: Any)
    {
        self.selectedTech = self.tech3Button.titleLabel!.text
        self.calendarCollectionView.backgroundColor = tech3Button.backgroundColor
        self.calendarCollectionView.reloadData()
    }
    @IBAction func monthLeftTapped(_ sender: Any)
    {
        self.selectedMonth = self.dm.getTheMonthBefore(month: self.selectedMonth)
        self.setMonthAndDays()
        self.calendarCollectionView.reloadData()
    }
    @IBAction func monthRightTapped(_ sender: Any)
    {
        self.selectedMonth = self.dm.getTheMonthAfter(month: self.selectedMonth)
        self.setMonthAndDays()
        self.calendarCollectionView.reloadData()
    }
    
    func reloadCalendar()
    {
        self.calendarCollectionView.reloadData()
        switch self.selectedTech!
        {
        case self.tech1Button.titleLabel!.text!:
            self.tech1ButtonTapped(tech1Button)
        case self.tech2Button.titleLabel!.text!:
            self.tech2ButtonTapped(tech2Button)
        case self.tech3Button.titleLabel!.text!:
            self.tech3ButtonTapped(tech3Button)
        default:
            self.tech1ButtonTapped(tech1Button)
        }
    }
    
    func dertermineAvailability(for cell:CalendarCollectionViewCell) -> CalendarCollectionViewCell
    {
        cell.dayButton.backgroundColor = .white
        cell.dayButton.isUserInteractionEnabled = true
        
        let date = cell.dayButton.ID
        var dateArray = date!.split(separator: "-")//remove dashes from cell date
        for i in 0...(dateArray.count-1)
        {
            let string = dateArray[i]
            if string[string.startIndex] == "0"
            {
                dateArray[i].remove(at:string.startIndex)
            }
        }
        var thisCellDateString:String! = ""
        for string in dateArray
        {
            thisCellDateString.insert(contentsOf:string, at: thisCellDateString.endIndex)
        }
        //print("thisCellDateString:"+thisCellDateString)
        
        var techs = self.arrayOfTechs
        //self.getScheduledVisitsData()
        for scheduledVisit in self.arrayOfScheduledVisits
        {
            let tech = techs[scheduledVisit.tech_id-1]
            if self.selectedTech! == tech.name
            {
                var arrayOfVisitDateSubscripts = scheduledVisit.date.split(separator: "-")
                for i in 0...(arrayOfVisitDateSubscripts.count-1)
                {
                    let string = arrayOfVisitDateSubscripts[i]
                    if string[string.startIndex] == "0" //if the first char is a 0, delete it
                    {
                        arrayOfVisitDateSubscripts[i].remove(at:string.startIndex)
                    }
                }
                var foundVisitDateString:String! = ""
                for string in arrayOfVisitDateSubscripts
                {
                    foundVisitDateString.insert(contentsOf:string, at: foundVisitDateString.endIndex)
                }
                //print("foundVisitDateString:"+foundVisitDateString)
                
                if foundVisitDateString == thisCellDateString
                {
                    cell.dayButton.backgroundColor = .darkGray
                    cell.dayButton.isUserInteractionEnabled = false
                    break//break for loop
                }
                
            }//end if tech name matches
        }//end for scheduled visit in array of visits
        return cell
    }
    
    func setTechButtonTitles()
    {
        func setTitles()
        {
            for anyTech in self.arrayOfTechs
            {
                self.arrayOfTechs.append(anyTech)
            }
            self.tech1Button.setTitle(self.arrayOfTechs[0].name, for: .normal)
            self.tech2Button.setTitle(self.arrayOfTechs[1].name, for: .normal)
            self.tech3Button.setTitle(self.arrayOfTechs[2].name, for: .normal)
        }
        
        //print("&&& TechButton Titles Setting &&&")
        if self.arrayOfTechs.isEmpty
        {
            let task = self.getTechsTask(deferredUIUpdateFunc: setTitles)
            task.resume()
        }
        //print(self.arrayOfTechs)
    }
    
    func setMonthAndDays()
    {
        self.monthLabel.text! = self.selectedMonth
        var day = self.dm.dayOfWeekOfDate(YYYYMMDD: self.selectedYear+self.dm.convertMonthNameToDigits(monthName: self.selectedMonth)+"01")
        self.day1Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day2Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day3Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day4Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day5Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day6Label.text = day
        day = self.dm.theDayAfter(day: day)
        self.day7Label.text = day
        self.reloadCalendar()
    }
    
    @objc func calendarCellButtonTapped(withSender sender:IDButton)
    {
        self.date = sender.ID
        var message = "You are about to schedule a "+self.planSelected+" visit on "
        message = message+self.date+" from "+self.selectedTech!
        message = message+" at "+self.userAddress+". Does everything look correct?"
        let alert = UIAlertController(title: "Schedule Visit?", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {action in self.uploadAppointmentToDatabase()}))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        
        self.time = "10"
        self.present(alert, animated: true, completion: nil)
    }
    
    struct Appointment: Codable
    {
        let tech_id:Int
        let date:String
        let user_id:Int
        let time:Int
        let plan_id:Int
    }
    
    func uploadAppointmentToDatabase()
    {
        func validateDataAndRunTask()//chains through to running the upload taskx
        {
            //check tech array
            if self.arrayOfTechs.isEmpty
            {
                let task = self.getTechsTask(deferredUIUpdateFunc: checkUserInfo)
                task.resume()
            }
            else
            {
                checkUserInfo()
            }
        }
        
        func checkUserInfo()
        {
            if self.arrayOfUserInfo.isEmpty
            {
                let task = self.getUserInfoTask(deferredUIUpdateFunc: uploadAppointment)
                task.resume()
            }
            else
            {
                uploadAppointment()
            }
        }
        
        func uploadAppointment()
        {
            var tech_id:Int? = nil
            for tech in self.arrayOfTechs
            {
                if tech.name == self.selectedTech
                {
                    tech_id = tech.id
                    break
                }
            }
            let appointment = Appointment(
                                          tech_id: tech_id!,
                                          date: self.date,
                                          user_id: (self.arrayOfUserInfo[0]).id,
                                          time: Int(self.time)!,
                                          plan_id: 1)
            guard let uploadData = try? JSONEncoder().encode(appointment) else
            {
                return
            }
            let url = URL(string: "http://localhost:3000/scheduled_visits")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.uploadTask(with: request, from: uploadData)
            {
                data, response, error in
                if let error = error
                {
                    print ("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                else
                {
                        print ("server error")
                        return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                }
            }
            task.resume()
        }//end upload appointment
        
        validateDataAndRunTask()
    }//end uploadAppointmentToDatabase

}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.selectedTech == nil
        {
            self.setTechButtonTitles()
            self.tech1ButtonTapped(self)
        }
        print("numberOfItemsInSection start")
        let numOfDays:Int! = self.dm.getMonthRangeCount(YYYYMMDD: self.selectedYear+self.dm.convertMonthNameToDigits(monthName: self.selectedMonth)+"01")
        var cgHeight = CGFloat(5*75+10)
        if numOfDays == 28
        {
            cgHeight = CGFloat(4*75+10)
        }
        self.calendarCollectionView.frame = CGRect(x: self.calendarCollectionView.frame.minX, y: self.calendarCollectionView.frame.minY, width: self.calendarCollectionView.frame.width, height:cgHeight)
        return numOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.dayButton.setTitle(String(indexPath.row+1), for: UIControlState.normal)
        cell.dayButton.ID = String(self.selectedYear)+"-"+String(self.dm.convertMonthNameToDigits(monthName: self.selectedMonth))+"-"+String(indexPath.row+1)
        let newCell:CalendarCollectionViewCell = self.dertermineAvailability(for: cell)
        if newCell.dayButton.isEnabled
        {
            newCell.dayButton.addTarget(self, action: #selector(calendarCellButtonTapped(withSender:)), for: .touchUpInside)
        }
        
        return newCell
    }
    
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
