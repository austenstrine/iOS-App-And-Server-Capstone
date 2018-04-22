//
//  PlansViewController.swift
//  FullServiceHouseCleaning
//
//  Created by Student on 3/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
//https://youtu.be/akmPXZ4hDuU
//unwind segue info

class PlansViewController: SocketedViewController
{

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var planImage: UIImageView!
    @IBOutlet weak var planContentLabel: UILabel!
    @IBOutlet weak var planRateLabel: UILabel!
    @IBOutlet weak var planTitleLabel: UILabel!
    
    var selectedPlanName:String! = "Timeless"
    var didUnwind:Bool! = false
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let task = self.getPlansTask(deferredUIUpdateFunc:self.updatePlanContent)//will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        task.resume()
    }
    
    @IBAction func unwindToPlansView(sender: UIStoryboardSegue)
    {
        print("++++++++++")
        print("UNWIND TO PLANS")
        print("++++++++++")
        if let sourceViewController = sender.source as? CalendarViewController
        {
            sourceViewController.didUnwind = true
            self.selectedPlanName = sourceViewController.planSelected!
            self.socket = sourceViewController.socket
            self.token = sourceViewController.token
            self.clientLock = sourceViewController.clientLock
        }
    }
    
    @IBAction func selectPlanTapped(_ sender: Any)
    {
        print("++++++++++")
        print("SELECT PLAN TAPPED")
        print("++++++++++")
        if self.didUnwind == false
        {
            var doesNotHaveCalendarViewController:Bool! = true
            for vc in self.navigationController!.viewControllers
            {
                if vc is CalendarViewController
                {
                    doesNotHaveCalendarViewController = false
                    break
                }
            }
            if doesNotHaveCalendarViewController
            {
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print("!!  Calendar not found in Nav !!")
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print(self.navigationController!.viewControllers)
                let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
                nextViewController.planSelected = self.selectedPlanName
                nextViewController.socket = self.socket
                nextViewController.token = self.token
                nextViewController.clientLock = self.clientLock
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            else
            {
                self.performSegue(withIdentifier: "unwindToCalendarView", sender: self)
            }
        }
        self.didUnwind = false
    }
    
    @IBAction func goldPlanNavTap(_ sender: Any)
    {
        func refreshPlan(){self.refreshPlan(index: 3)}
        if self.arrayOfPlans.isEmpty
        {
            let task = self.getPlansTask(deferredUIUpdateFunc:refreshPlan)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            refreshPlan()
        }
    }
    
    @IBAction func silverPlanNavTap(_ sender: Any)
    {
        func refreshPlan(){self.refreshPlan(index: 2)}
        if self.arrayOfPlans.isEmpty
        {
            let task = self.getPlansTask(deferredUIUpdateFunc:refreshPlan)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            refreshPlan()
        }
    }
    
    @IBAction func bronzePlanNavTap(_ sender: Any)
    {
        func refreshPlan(){self.refreshPlan(index: 1)}
        if self.arrayOfPlans.isEmpty
        {
            let task = self.getPlansTask(deferredUIUpdateFunc:refreshPlan)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            refreshPlan()
        }
    }
    
    @IBAction func timelessPlanNavTap(_ sender: Any)
    {
        func refreshPlan(){self.refreshPlan(index: 0)}
        if self.arrayOfPlans.isEmpty
        {
            let task = self.getPlansTask(deferredUIUpdateFunc:refreshPlan)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            refreshPlan()
        }
    }
    
    func refreshPlan(index:Int)
    {
        self.selectedPlanName = self.arrayOfPlans[index].name
        self.updatePlanContent()
    }
    
    func updatePlanContent()
    {
        var num:Int? = nil
        switch self.selectedPlanName
        {
        case self.arrayOfPlans[0].name:
            num = 0
        case self.arrayOfPlans[1].name:
            num = 1
        case self.arrayOfPlans[2].name:
            num = 2
        case self.arrayOfPlans[3].name:
            num = 3
        default:
            print("Whoops! What happened? Unexpected selectedPlanName value!")
        }
        self.planImage.image = UIImage(named:self.arrayOfPlans[num!].image)
        self.planTitleLabel.text = String(self.arrayOfPlans[num!].name)
        self.planRateLabel.text = String(self.arrayOfPlans[num!].rate)
        self.planContentLabel.text = String(self.arrayOfPlans[num!].description)
        self.clientLock.unlock()
    }

}
