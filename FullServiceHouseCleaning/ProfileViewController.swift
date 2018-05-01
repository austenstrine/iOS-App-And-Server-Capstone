//
//  ProfileViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Sunday4/15/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit


class ProfileViewController: DelegatedViewController
{
    
    @IBOutlet weak var scheduledVisitsView: UIView!
    @IBOutlet weak var saveView: UIView!
    
    @IBOutlet var allChangeButtons: [UIButton]!
    //not the plan or visit buttons
    @IBOutlet weak var planChangeButton: UIButton!
    
    @IBOutlet var allTextFields: [UITextField]!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var cszTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //
    @IBOutlet weak var planTextField: UITextField!
    
    @IBOutlet weak var visitPicker: UIPickerView!
    
    var userVisitsArray = VisitsArray()
    var userVisitsStringArray = [[String]]()
    var selectedVisit = [String]()
    var sendableUserInfo:UserSendable?
    var needsNewPlan:Bool = true
    var savedData:SavedData?
    var emitAsNewUser:Bool = false
    
    override func viewWillAppear(_ animated: Bool)//before every load
    {
        super.viewWillAppear(animated)
        if emitAsNewUser == false
        {
            self.delegate.validateAllData(rebuild:false)
            {
                self.updateAllData()
            }
        }
        else
        {
            if self.savedData != nil
            {
                self.planTextField.text = self.savedData!.plan
            }
        }
    }
    override func viewDidLoad()//1st load only
    {
        super.viewDidLoad()
        self.visitPicker.dataSource = self
        self.visitPicker.delegate = self
        
        if self.emitAsNewUser
        {
            self.saveView.alpha = 1
            for txtField in self.allTextFields
            {
                txtField.isUserInteractionEnabled = true
                txtField.text = ""
                txtField.placeholder = Placeholders.enterInfo
            }
            self.planTextField.isUserInteractionEnabled = false
            self.passwordTextField.isSecureTextEntry = false
            self.scheduledVisitsView.alpha = 0.25
            self.scheduledVisitsView.isUserInteractionEnabled = false
            for button in self.allChangeButtons
            {
                button.setTitle(ButtonStrings.done, for: .normal)
            }
            self.planChangeButton.setTitle(ButtonStrings.select, for: .normal)
        }
        else
        {
            self.saveView.alpha = 0
            for txtField in self.allTextFields
            {
                txtField.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func unwindToProfileView(sender: UIStoryboardSegue)
    {
        print("unwindToProfileView(sender: UIStoryboardSegue)")
        if let sourceViewController = sender.source as? PlansViewController
        {
            self.savedData!.plan = sourceViewController.selectedPlanName!
            print("$$SELECTED PLAN IS:\(sourceViewController.selectedPlanName!)\n$$Saved Data Plan is:\(self.savedData!.plan)")
            self.triggerBarAppearance()
        }
        if sender.source is LoginPopupViewController
        {
            self.navigationController!.isNavigationBarHidden = false
            self.emitAsNewUser = true
        }
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any)
    {
        // TOBUILD:
        // func confirmUser()
        // {
        //   self.areYouSureAlertPush(yesCompletionHandler:
        //   {   () in
                if self.gatherAndSendData()
                {
                    print("successfully gathered and sent data")
                }
        //   })
        // }//end confirmUser
        //
        // func invalidData()
        // {
        //   pushInvalidDataAlertView()
        // }//end invalidData
        //
        // //self.validateChangedDataWithServer will ensure that validation has been completed on all fields by checking that the name of all buttons == ButtonStrings.change
        // //must build server validation on select of done button for this to work
        // self.validateChangedDataWithServer(validCompletionHandler: confirmUser, invalidCompletionHandler: invalidData)
        // //end self.validateChangedDataWithServer
    }//end saveChangesButtonTapped
    
    @IBAction func discardChangesButtonTapped(_ sender: Any)
    {
        self.triggerBarDisappearance()
        if self.emitAsNewUser
        {
            self.performSegue(withIdentifier: UnwindIDs.profile.unwindToLoginPopupView, sender: self)
        }
        else
        {
            self.updateAllData()
        }
    }
    
    @IBAction func nameChangeButtonTapped(_ sender: Any)
    {
        self.determineButtonAction(sender: sender, textField: self.nameTextField)
        //text field is a class, and so should be passed by reference
    }
    @IBAction func surnameChangeButtonTapped(_ sender: Any)
    {
        self.determineButtonAction(sender: sender, textField: self.surnameTextField)
    }
    @IBAction func cszChangeButtonTapped(_ sender: Any)//city, state, zip: csz
    {
        self.determineButtonAction(sender: sender, textField: self.cszTextField)
    }
    @IBAction func streetAddressChangeButtonTapped(_ sender: Any)
    {
        self.determineButtonAction(sender: sender, textField: self.streetAddressTextField)
    }
    @IBAction func numberChangeButtonTapped(_ sender: Any)
    {
        self.determineButtonAction(sender: sender, textField: self.numberTextField)
    }
    @IBAction func usernameChangeButtonTapped(_ sender: Any)
    {
        self.determineButtonAction(sender: sender, textField: self.usernameTextField)
    }
    @IBAction func passwordChangeButtonTapped(_ sender: Any)
    {
        self.pushPasswordChangeRequest(badEntry: false)
    }
    @IBAction func planChangeButtonTapped(_ sender: Any)
    {
        self.savedData = SavedData(
            dict:
            [
                SavedData.NAME : self.nameTextField.text!,
                SavedData.SURNAME : self.surnameTextField.text!,
                SavedData.STREET_ADDRESS : self.streetAddressTextField.text!,
                SavedData.CSZ : self.cszTextField.text!,
                SavedData.NUMBER : self.numberTextField.text!,
                SavedData.USERNAME : self.usernameTextField.text!,
                SavedData.PASSWORD : self.passwordTextField.text!,
                SavedData.PLAN : self.planTextField.text!,
                SavedData.USER_VISITS : self.userVisitsArray,
                SavedData.USER_VISITS_STRINGS : self.userVisitsStringArray
            ])
        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "PlansViewController") as! PlansViewController
        nextViewController.selectedPlanName = self.planTextField.text!
        nextViewController.unwindToProfile = true
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    @IBAction func visitsPickerButtonTapped(_ sender: Any)
    {
        
    }
    
    func determineButtonAction(sender:Any, textField:UITextField)
    {
        func change()
        {
            textField.isHighlighted = true
            textField.isUserInteractionEnabled = true
            textField.selectAll(self)
        }
        func done()
        {
            textField.isHighlighted = false
            textField.isUserInteractionEnabled = false
            self.triggerBarAppearance()
        }
        if let senderButton = sender as? UIButton
        {
            switch senderButton.titleLabel!.text
            {
                
            case ButtonStrings.change:
                senderButton.setTitle(ButtonStrings.done, for: .normal)
                change()
            case ButtonStrings.done:
                senderButton.setTitle(ButtonStrings.change, for: .normal)
                done()
            default:
                print("\n\nBUTTON ERROR FOR:\(senderButton.titleLabel!.text ?? "nil")\n\n")
            }
        }
        else
        {
            print("\n\nSENDER ERROR, SENDER IS:\(sender)\n\n")
        }
    }
    
    func pushPasswordChangeRequest(badEntry:Bool)
    {
        var currentPasswordTextField: UITextField?
        var newPasswordTextField: UITextField?
        var newPasswordRepeatTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Password Change",
            message: "Please enter your credentials",
            preferredStyle: UIAlertControllerStyle.alert)
        
        if badEntry
        {
            alertController.addTextField {
                (txtfield) -> Void in
                txtfield.text = "Incorrect information provided!"
                txtfield.isUserInteractionEnabled = false
                txtfield.textColor = .red
                txtfield.tintColor = .white
            }
        }
        
        alertController.addTextField {
            (txtCurrentPass) -> Void in
            currentPasswordTextField = txtCurrentPass
            currentPasswordTextField!.isSecureTextEntry = true
            currentPasswordTextField!.placeholder = "Enter your current password"
        }
        alertController.addTextField {
            (txtPassword) -> Void in
            newPasswordTextField = txtPassword
            newPasswordTextField!.isSecureTextEntry = true
            newPasswordTextField!.placeholder = "Enter your new password"
        }
        alertController.addTextField {
            (txtPasswordAgain) -> Void in
            newPasswordRepeatTextField = txtPasswordAgain
            newPasswordRepeatTextField!.isSecureTextEntry = true
            newPasswordRepeatTextField!.placeholder = "Enter your new password"
        }
        
        let doneAction = UIAlertAction(
        title: "Done", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            if self.delegate.password == currentPasswordTextField!.text {
                //Do not change password yet, we're waiting for the save button to be selected
                print("Password correct: \(currentPasswordTextField!.text!)")
            } else {
                print("Current password INCORRECT")
                self.pushPasswordChangeRequest(badEntry: true)
            }
            
            if newPasswordTextField!.text == newPasswordRepeatTextField!.text {
                print("New Password = \(newPasswordTextField!.text!)")
                self.passwordTextField.text = newPasswordTextField!.text!
            } else {
                print("New Password does not match")
                self.pushPasswordChangeRequest(badEntry: true)
            }
        }
        alertController.addAction(doneAction)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func triggerBarAppearance()
    {
        if self.saveView.alpha == 0
        {
            UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseInOut], animations:
                {
                    self.saveView.alpha = 1
                    
                }, completion: nil)
        }
    }
    
    func triggerBarDisappearance()
    {
        if self.saveView.alpha == 1
        {
            UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseInOut], animations:
                {
                    self.saveView.alpha = 0
                    
                }, completion: nil)
        }
    }
    
    func gatherAndSendData() -> Bool
    {
        if self.getSendableData()
        {
            guard let uploadData = try? JSONEncoder().encode(self.sendableUserInfo!) else
            {
                print("\n\nuploadData ENCODE FAILED!!!!\n\n")
                return false
            }
            
            var emitFunc:VoidFunc?
            
            if self.emitAsNewUser
            {
                emitFunc =
                    {   () in
                        self.delegate.socket.emit(EmitStrings.new_user, with:[uploadData])
                    }
            }
            else
            {
                emitFunc =
                    {   () in
                        self.delegate.socket.emit(EmitStrings.update_user, with:[uploadData])
                    }
            }
            
            self.relogPrompt(completionHandler:emitFunc!)
            return true
        }
        else
        {
            self.incorrectDataPrompt()
            return false
        }
    }
    
    func incorrectDataPrompt()
    {
        let alert = UIAlertController(title: "Incorrect Data!", message: "Data fields cannot be empty! Please ensure all data fields have correct information, and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func relogPrompt(completionHandler:@escaping VoidFunc)
    {
        
        let alert = UIAlertController(title: "Success!", message: "Your user profile has been updated. You will now be redirected to the login page.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion:
        {
            completionHandler()
        })
    }
    
    func updateAllData()
    {
        if self.savedData == nil
        {
            self.buildUserVisitsArraysAndReload()
            let user = self.delegate.arrayOfUserInfo[0]
            self.nameTextField.text = user.first_name
            self.surnameTextField.text = user.last_name
            self.streetAddressTextField.text = user.street_address
            self.cszTextField.text = user.city_state_zip
            self.numberTextField.text = user.number
            self.usernameTextField.text = user.username
            self.passwordTextField.text = self.delegate.password
            self.planTextField.text = self.delegate.arrayOfPlans[user.plan_id-1].name
            self.sendableUserInfo = UserSendable(user: self.delegate.arrayOfUserInfo[0], passwordString: "")
        }
        else
        {
            self.userVisitsArray = self.savedData!.userVisits
            self.userVisitsStringArray = self.savedData!.userVisitsStrings
            self.visitPicker.reloadAllComponents()
            
            self.nameTextField.text = self.savedData!.name
            self.surnameTextField.text = self.savedData!.surname
            self.streetAddressTextField.text = self.savedData!.streetAddress
            self.cszTextField.text = self.savedData!.csz
            self.numberTextField.text = self.savedData!.number
            self.usernameTextField.text = self.savedData!.username
            self.passwordTextField.text = self.savedData!.password
            self.planTextField.text = self.savedData!.plan
        }
        
    }
    
    func reloadPicker()
    {
        //print("\n\n"+"\nreloading picker\n\n")
        visitPicker.reloadAllComponents()
    }

    func buildUserVisitsArraysAndReload()
    {
        self.userVisitsArray = VisitsArray()
        self.userVisitsStringArray = [[String]]()
        let user:User! = self.delegate.arrayOfUserInfo[0]
        for visit in self.delegate.arrayOfScheduledVisits
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
            for plan in self.delegate.arrayOfPlans
            {
                if plan.id == visit.plan_id
                {
                    planName = plan.name
                    break
                }
            }
            var techName:String?
            for tech in self.delegate.arrayOfTechs
            {
                if tech.id == visit.tech_id
                {
                    techName = tech.name
                    break
                }
            }
            string = visit.date + "\n" + techName! + "\n" + planName!
            self.userVisitsStringArray.append([string!, String(index)])
            index += 1
        }
        self.userVisitsStringArray.sort{
            return $0[0] < $1[0]
        }
        self.reloadPicker()
    }

    func getSendableData() -> Bool
    {
        var planID:Int?
        for plan in self.delegate.arrayOfPlans
        {
            if plan.name == self.planTextField.text
            {
                planID = plan.id
                break
            }
        }
        if planID == nil
        {
            print("\n\nID is nil!!\n\n")
            return false
        }
        var dict : [String : Any?] = [
            UserStrings.id : 0,
            UserStrings.first_name : self.nameTextField.text!,
            UserStrings.last_name : self.surnameTextField.text!,
            UserStrings.plan_id : planID!,
            UserStrings.street_address : self.streetAddressTextField.text!,
            UserStrings.city_state_zip : self.cszTextField.text!,
            UserStrings.active : 1,
            UserStrings.number : self.numberTextField.text!,
            UserStrings.username : self.usernameTextField.text!
            ]
        if self.emitAsNewUser != true
        {
            dict[UserStrings.id] = self.delegate.id
            dict[UserStrings.active] = self.delegate.arrayOfUserInfo[0].active
        }
        for (key, value) in dict
        {
            if value == nil
            {
                print(key, "is nil!!!")
                return false
            }
        }
        let user:User = User(json: (dict as [String:Any]))
        let password = PairedPhrase.encodePass(pass: self.passwordTextField.text!)
        self.sendableUserInfo = UserSendable(user: user, passwordString: password)
        return true
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
        if userVisitsArray.isEmpty || self.delegate.arrayOfPlans.isEmpty || self.delegate.arrayOfTechs.isEmpty //|| self.arrayOfUserInfo.isEmpty
        {
            return "No Scheduled Visits to show yet!"
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
