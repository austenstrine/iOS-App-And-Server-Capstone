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

typealias CVC = CalendarViewController

class CalendarViewController: DelegatedViewController
{
    static var selectedMonth:String = String(Calendar.current.component(.month, from:Date()))
    static var selectedYear = String(Calendar.current.component(.year, from:Date()))
    
    @IBOutlet weak var fillView: UIView!
    @IBOutlet weak var monthTitleView: UIView!
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
    var loadingLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var planSelected:String = Placeholders.loading
    var selectedTech:String = Placeholders.loading
    var userAddress:String = Placeholders.loading
    var userID:String = Placeholders.loading
    var date:String = Placeholders.loading
    var time:String = Placeholders.loading
    var unwindToPlans:Bool = false
    var newPlanNeeded:Bool = true
    let currentDate = Date()
    let currentMonth = Calendar.current.component(.month, from:Date())
    let dm = DateMute()
    
    private var datesArray = [String]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        print("\n", self.classForCoder, Thread.current, "\noverride func viewWillAppear\n")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("!!   CALENDAR VIEW DID LOAD   !!")
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("\n", self.classForCoder, Thread.current, "\noverride func viewDidLoad\n")
        planSelected = self.delegate.arrayOfPlans[self.delegate.arrayOfUserInfo[0].plan_id].name
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        let month = Calendar.current.component(.month, from: currentDate)
        CVC.selectedMonth = DateMute.convertMonthDigitsToName(monthDigit: month)
        self.calendarCollectionView.alpha = 0
        self.monthTitleView.alpha = 0
        self.loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        loadingLabel.text = "Loading..."
        self.fillView.addSubview(loadingLabel)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        print("\n", self.classForCoder, Thread.current, "\noverride func viewDidAppear\n")
        self.validateAndUpdateUI()
        currentPlanLabel.text = "Selected Plan: "+planSelected
        
    }
    
    func setDefaultUserData()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc setDefaultUserData\n")
        if self.newPlanNeeded
        {
            self.newPlanNeeded = false
            self.userAddress = self.delegate.arrayOfUserInfo[0].street_address + self.delegate.arrayOfUserInfo[0].city_state_zip
            //print("###################################################")
            //print("#user address \(self.userAddress)#")
            //print("###################################################")
            var planName:String?
            //print(self.delegate.arrayOfPlans)
            for plan in self.delegate.arrayOfPlans
            {
                //print("plan id checking:\(plan.id), plan id from user info:\(self.delegate.arrayOfUserInfo[0].plan_id)")
                if String(plan.id) == String(self.delegate.arrayOfUserInfo[0].plan_id)
                {
                    //print("equal")
                    planName = plan.name
                    break
                }
                else
                {
                    //print("not equal")
                }
            }
            self.planSelected = planName!
        }
    }
    
    func validateAndUpdateUI()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc validateAndUpdateUI\n")
        
        self.delegate.validateAllData(rebuild: false)
        {
            self.setTechButtonTitles()
            self.setDefaultUserData()
            self.setMonthAndDays()
            if self.calendarCollectionView.alpha == 0
            {
                UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseInOut], animations:
                {
                    self.calendarCollectionView.alpha = 1
                    self.monthTitleView.alpha = 1
                    self.loadingLabel.alpha = 0
                    
                }, completion: nil)
            }
        }
        
    }
    
    @IBAction func unwindToCalendarView(sender: UIStoryboardSegue)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func unwindToCalendarView\n")
        if let sourceViewController = sender.source as? PlansViewController
        {
            self.planSelected = sourceViewController.selectedPlanName!
            self.newPlanNeeded = false
            //
        }
        //self.viewDidLoad()
    }
    
    @IBAction func changePlanTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func changePlanTapped\n")
        if self.unwindToPlans
        {
            self.unwindToPlans = false
            self.performSegue(withIdentifier: UnwindIDs.calendar.unwindToPlansView, sender: self)
        }
        else
        {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "PlansViewController") as! PlansViewController
            nextViewController.selectedPlanName = self.planSelected
            nextViewController.unwindToCalendar = true
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
        /*
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
                //print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                //print("!!Plans View not found in Nav !!")
                //print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                //print(self.navigationController!.viewControllers)
                let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "PlansViewController") as! PlansViewController
                nextViewController.selectedPlanName = self.planSelected
                self.navigationController!.pushViewController(nextViewController, animated: true)
            }
            else
            {
                self.performSegue(withIdentifier: "unwindToPlansView", sender: self)
            }
            
        }
        self.didUnwind = false//might be unnecessary
        */
    }
    
    @IBAction func tech1ButtonTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func tech1ButtonTapped\n")
        self.selectedTech = self.tech1Button.titleLabel!.text!
        calendarCollectionView.backgroundColor = tech1Button.backgroundColor
        calendarCollectionView.reloadData()
    }
    @IBAction func tech2ButtonTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func tech2ButtonTapped\n")
        self.selectedTech = self.tech2Button.titleLabel!.text!
        self.calendarCollectionView.backgroundColor = tech2Button.backgroundColor
        self.calendarCollectionView.reloadData()
    }
    @IBAction func tech3ButtonTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func tech3ButtonTapped\n")
        self.selectedTech = self.tech3Button.titleLabel!.text!
        self.calendarCollectionView.backgroundColor = tech3Button.backgroundColor
        self.calendarCollectionView.reloadData()
    }
    @IBAction func monthLeftTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func monthLeftTapped\n")
        let previous = CVC.selectedMonth
        CVC.selectedMonth = DateMute.getTheMonthBefore(month: CVC.selectedMonth)
        if previous == DateMute.JANUARY
        {
            CVC.selectedYear = String(Int(CVC.selectedYear)!-1)//year goes down when going from january back to december
        }
        self.setMonthAndDays()
        self.calendarCollectionView.reloadData()
    }
    @IBAction func monthRightTapped(_ sender: Any)
    {
        print("\n", self.classForCoder, Thread.current, "\n@IBAction func monthRightTapped\n")
        let previous = CVC.selectedMonth
        CVC.selectedMonth = DateMute.getTheMonthAfter(month: CVC.selectedMonth)
        if previous == DateMute.DECEMBER
        {
            CVC.selectedYear = String(Int(CVC.selectedYear)!+1)//year goes up when going from december to next january
        }
        self.setMonthAndDays()
        self.calendarCollectionView.reloadData()
    }
    
    func reloadCalendar()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc reloadCalendar\n")
        self.calendarCollectionView.reloadData()
        switch self.selectedTech
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
    
    func setTechButtonTitles()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc setTechButtonTitles\n")
        self.tech1Button.setTitle(self.delegate.arrayOfTechs[0].name, for: .normal)
        self.tech2Button.setTitle(self.delegate.arrayOfTechs[1].name, for: .normal)
        self.tech3Button.setTitle(self.delegate.arrayOfTechs[2].name, for: .normal)
        
        if self.selectedTech == Placeholders.loading
        {
            self.tech1ButtonTapped(tech1Button)
        }
    }
    
    func setMonthAndDays()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc setMonthAndDays\n")
        self.monthLabel.text! = CVC.selectedMonth + " " + CVC.selectedYear
        var day = DateMute.dayOfWeekOfDate(YYYYMMDD: CVC.selectedYear+DateMute.convertMonthNameToDigits(monthName: CVC.selectedMonth)+"01")
        self.day1Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day2Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day3Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day4Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day5Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day6Label.text = day
        day = DateMute.theDayAfter(day: day)
        self.day7Label.text = day
        self.reloadCalendar()
    }
    
    @objc func calendarCellButtonTapped(withSender sender:IDButton)
    {
        print("\n", self.classForCoder, Thread.current, "\n@objc func calendarCellButtonTapped\n")
        self.date = sender.ID!
        var message = "You are about to schedule a "+self.planSelected+" visit on "
        message = message+self.date+" from "+self.selectedTech
        message = message+" at "+self.userAddress+". Does everything look correct?"
        let alert = UIAlertController(title: "Schedule Visit?", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {action in self.uploadAppointmentToDatabase()}))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        
        self.time = "10"
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadAppointmentToDatabase()
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc uploadAppointmentToDatabase\n")
        
        var tech_id:Int? = nil
        for tech in self.delegate.arrayOfTechs
        {
            if tech.name == self.selectedTech
            {
                tech_id = tech.id
                break
            }
        }
        let appointment = ScheduledVisit(json:
                                      ["tech_id": tech_id!,
                                      "date": self.date,
                                      "user_id": (self.delegate.arrayOfUserInfo[0]).id,
                                      "time": Int(self.time)!,
                                      "plan_id": 1])
        guard let uploadData = try? JSONEncoder().encode(appointment) else
        {
            return
        }
        delegate.socket.emit(EmitStrings.add_scheduled_visit, with: [uploadData])
        
        /*let url = URL(string: "http://localhost:3000/scheduled_visits")!
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
        }*/
    }//end uploadAppointmentToDatabase

}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    static var hasPrintedOnce:Bool = false
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section\n")
        CVC.hasPrintedOnce = false
        if self.selectedTech == Placeholders.loading
        {
            self.setTechButtonTitles()
        }
        let numOfDays:Int! = DateMute.getMonthRangeCount(YYYYMMDD: CVC.selectedYear+DateMute.convertMonthNameToDigits(monthName: CVC.selectedMonth)+"01")
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
        print("\n", self.classForCoder, Thread.current, "\nfunc collectionView(_ collectionView: UICollectionView, cellForItemAt...Only printing ONCE\n")
        CVC.hasPrintedOnce = true
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.dayButton.setTitle(String(indexPath.row+1), for: UIControlState.normal)
        cell.dayButton.ID = String(CVC.selectedYear)+"-"+String(DateMute.convertMonthNameToDigits(monthName: CVC.selectedMonth))+"-"+DateMute.digitToZeroSafeString(digit: indexPath.row+1)
        let newCell:CalendarCollectionViewCell = self.dertermineAvailability(for: cell)

        if newCell.dayButton.isEnabled
        {
            newCell.dayButton.addTarget(self, action: #selector(calendarCellButtonTapped(withSender:)), for: .touchUpInside)
        }
        
        return newCell
    }
    
    func dertermineAvailability(for cell:CalendarCollectionViewCell) -> CalendarCollectionViewCell
    {
        print("\n", self.classForCoder, Thread.current, "\nfunc dertermineAvailability\n")
        cell.dayButton.backgroundColor = .white
        cell.dayButton.isUserInteractionEnabled = true
        
        let date = cell.dayButton.ID
        let dateArray = date!.split(separator: "-")//remove dashes from cell date
        var thisCellDateString:String! = ""
        for string in dateArray
        {
            thisCellDateString.insert(contentsOf:string, at: thisCellDateString.endIndex)
        }
        //print("thisCellDateString:"+thisCellDateString)
        
        var techs = self.delegate.arrayOfTechs
        //print(self)
        for scheduledVisit in self.delegate.arrayOfScheduledVisits
        {
            let tech = techs[scheduledVisit.tech_id-1]
            //print("self.selectedTech!: \(self.selectedTech), tech.name: \(tech.name)")
            if self.selectedTech == tech.name
            {
                let arrayOfVisitDateSubscripts = scheduledVisit.date.split(separator: "-")
                var foundVisitDateString:String! = ""
                for string in arrayOfVisitDateSubscripts
                {
                    foundVisitDateString.insert(contentsOf:string, at: foundVisitDateString.endIndex)
                }//end concactenate substrings
                //print("foundVisitDateString:"+foundVisitDateString)
                
                
                let currentDateSubstrings = self.currentDate.description.split(separator: " ")[0].split(separator: "-")// .split(separator:" ")[0] removes timestamp, etc, leaves only date as yyy-MM-dd
                //print("\(currentDateSubstrings)")
                var currentDateString = ""
                for string in currentDateSubstrings
                {
                    currentDateString.insert(contentsOf: string, at: currentDateString.endIndex)
                }
                
                //print("foundVisitDateString: \(foundVisitDateString!), thisCellDateString: \(thisCellDateString!), thisCellDateString: \(thisCellDateString!), currentDateString: \(currentDateString)")
                func daFunc()
                {
                    //print("voidfunc")
                    cell.dayButton.backgroundColor = .darkGray
                    cell.dayButton.isUserInteractionEnabled = false
                }
                if foundVisitDateString! == thisCellDateString!
                {
                    daFunc()
                    //print("Date Strings are Equal")
                    break//break for loop
                }
                if Int(thisCellDateString!)! < Int(currentDateString)!
                {
                    daFunc()
                    //print("Cell Date is less than Current Date")
                    break//break for loop
                }
                
            }//end if tech name matches
        }//end for scheduled visit in array of visits
        return cell
    }
    
}

//extension NSMutableData {
//    func appendString(string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
//        append(data!)
//    }
//}
