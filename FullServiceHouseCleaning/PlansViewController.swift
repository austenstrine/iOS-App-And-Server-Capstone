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
typealias PVC = PlansViewController

class PlansViewController: DelegatedViewController
{

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var planImage: UIImageView!
    @IBOutlet weak var planContentLabel: UILabel!
    @IBOutlet weak var planRateLabel: UILabel!
    @IBOutlet weak var planTitleLabel: UILabel!
    
    var selectedPlanName:String! = "Timeless"
    var unwindToCalendar:Bool = false
    var unwindToProfile:Bool = false
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.delegate.validateAllData(rebuild:false)
        {
            self.updatePlanContent()
        }
    }
    

    
    @IBAction func unwindToPlansView(sender: UIStoryboardSegue)
    {
        //print("++++++++++")
        //print("UNWIND TO PLANS")
        //print("++++++++++")
        
        if let sourceViewController = sender.source as? CalendarViewController
        {
            self.selectedPlanName = sourceViewController.planSelected
        }
    }
    
    @IBAction func selectPlanTapped(_ sender: Any)
    {
        //print("++++++++++")
        //print("SELECT PLAN TAPPED")
        //print("++++++++++")
        if self.unwindToProfile
        {
            self.unwindToProfile = false
            self.performSegue(withIdentifier: UnwindIDs.plans.unwindToProfileView, sender: self)
            return
        }
        
        if self.unwindToCalendar
        {
            self.unwindToCalendar = false
            self.performSegue(withIdentifier: UnwindIDs.plans.unwindToCalendarView, sender: self)
        }
        else
        {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
            nextViewController.planSelected = self.selectedPlanName
            nextViewController.unwindToPlans = true
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        /*
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
         //print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
         //print("!!  Calendar not found in Nav !!")
         //print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
         //print(self.navigationController!.viewControllers)
         let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
         nextViewController.planSelected = self.selectedPlanName
         self.navigationController?.pushViewController(nextViewController, animated: true)
         }
         else
         {
         self.performSegue(withIdentifier: "unwindToCalendarView", sender: self)
         }*/
    }
    
    @IBAction func goldPlanNavTap(_ sender: Any)
    {
        self.refreshPlan(index: 3)
    }
    
    @IBAction func silverPlanNavTap(_ sender: Any)
    {
        self.refreshPlan(index: 2)
    }
    
    @IBAction func bronzePlanNavTap(_ sender: Any)
    {
        self.refreshPlan(index: 1)
    }
    
    @IBAction func timelessPlanNavTap(_ sender: Any)
    {
        self.refreshPlan(index: 0)
    }
    
    func refreshPlan(index:Int)
    {
        self.selectedPlanName = self.delegate.arrayOfPlans[index].name
        self.updatePlanContent()
    }
    
    func updatePlanContent()
    {
        var num:Int? = nil
        switch self.selectedPlanName
        {
        case self.delegate.arrayOfPlans[0].name:
            num = 0
        case self.delegate.arrayOfPlans[1].name:
            num = 1
        case self.delegate.arrayOfPlans[2].name:
            num = 2
        case self.delegate.arrayOfPlans[3].name:
            num = 3
        default:
            print("Whoops! What happened? Unexpected selectedPlanName value!")
        }
        self.planImage.image = UIImage(named:self.delegate.arrayOfPlans[num!].image)
        self.planTitleLabel.text = String(self.delegate.arrayOfPlans[num!].name)
        self.planRateLabel.text = String(self.delegate.arrayOfPlans[num!].rate)
        self.planContentLabel.text = String(self.delegate.arrayOfPlans[num!].description)
    }

}
