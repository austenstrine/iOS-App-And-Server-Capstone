//
//  ContactViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class ContactViewController: DelegatedViewController
{

    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    let number:String! = "1-530-966-7034"
    let email:String! = "austenstrine@gmail.com"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        phoneNumberButton.setTitle("Tap to Call: "+number, for: .normal)
        phoneNumberButton.addTarget(self, action: #selector(self.phoneNumberLabelTapped), for: .touchUpInside)
        emailButton.setTitle("Tap to Email: "+email, for: .normal)
        emailButton.addTarget(self, action: #selector(self.emailLabelTapped), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func phoneNumberLabelTapped()
    {
        //print("entered call number function")
        if let url = URL(string: "tel:\(self.number)")//, UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10, *)
            {
                UIApplication.shared.open(url)
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
            //print("phone app would open here on iOS Device (does not work on simulator)")
        }
    }
    
    @objc func emailLabelTapped()
    {
        //print("entered email function")
        if let url = URL(string: "mailto:\(self.email)")//, UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10, *)
            {
                UIApplication.shared.open(url)
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
            //print("email app would open here on iOS Device (does not work on simulator)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
