//
//  ProfileViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Sunday4/15/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class ProfileViewController: SocketedViewController
{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cszTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var planTextField: UITextField!
    @IBOutlet weak var visitPicker: UIPickerView!
    var userVisitsArray = VisitsArray()
    var userVisitsStringArray = [[String]]()
    var selectedVisit = [String]()
    
    override func viewWillAppear(_ animated: Bool)//before every load
    {
        super.viewWillAppear(animated)
        
        validateTechsData(deferredUIUpdateFunc:
        {   () -> Void in
            self.validatePlansData(deferredUIUpdateFunc:
            {   () -> Void in
                self.validateScheduledVisitsData(deferredUIUpdateFunc:
                {   () -> Void in
                    self.validateUserInfoData(deferredUIUpdateFunc:self.updateAllData)
                })
            })
        })
    }
    override func viewDidLoad()//1st load only
    {
        super.viewDidLoad()
        visitPicker.dataSource = self
        visitPicker.delegate = self
    }
    
    @IBAction func nameChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func surnameChangeButtonTapped(_ sender: Any) {
    }
    //city, state, zip: csz
    @IBAction func cszChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func streetAddressChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func numberChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func usernameChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func passwordChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func planChangeButtonTapped(_ sender: Any) {
    }
    @IBAction func pickerButtonTapped(_ sender: Any)
    {
        let alert = UIAlertController(title: "Selection", message: String(selectedVisit[1]+"\t"+selectedVisit[0]), preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateAllData()
    {
        self.buildUserVisitsArraysAndReload()
        let user = self.arrayOfUserInfo[0]
        self.nameTextField.text = user.first_name
        self.surnameTextField.text = user.last_name
        self.streetAddressTextField.text = user.street_address
        self.cszTextField.text = user.city_state_zip
        self.numberTextField.text = user.number
        self.usernameTextField.text = user.username
    }
    
    func reloadPicker()
    {
        print("\n\nreloading\n\n")
        visitPicker.reloadAllComponents()
    }

    func buildUserVisitsArraysAndReload()
    {
        self.userVisitsArray = VisitsArray()
        self.userVisitsStringArray = [[String]]()
        let user:User! = self.arrayOfUserInfo[0]
        for visit in self.arrayOfScheduledVisits
        {
            if visit.user_id == user.id
            {
                self.userVisitsArray.append(visit)
            }
        }
        var index = 0
        for visit in self.userVisitsArray
        {
            var string:String?
            var planName:String?
            for plan in self.arrayOfPlans
            {
                if plan.id == visit.plan_id
                {
                    planName = plan.name
                    break
                }
            }
            var techName:String?
            for tech in self.arrayOfTechs
            {
                if tech.id == visit.tech_id
                {
                    techName = tech.name
                    break
                }
            }
            string = visit.date + "\t" + techName! + "\t" + planName!
            self.userVisitsStringArray.append([string!, String(index)])
            index += 1
        }
        self.reloadPicker()
    }
}

extension ProfileViewController:UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if userVisitsArray.isEmpty
        {
            return 1
        }
        else
        {
            return userVisitsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if userVisitsArray.isEmpty || self.arrayOfPlans.isEmpty || self.arrayOfTechs.isEmpty //|| self.arrayOfUserInfo.isEmpty
        {
            return "Loading... "+String(row)
        }
        else
        {
            return userVisitsStringArray[row][0]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedVisit = userVisitsStringArray[row]
    }
}
