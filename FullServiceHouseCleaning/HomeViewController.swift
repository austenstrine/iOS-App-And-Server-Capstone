//
//  HomeViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/2/18.
//  Copyright © 2018 Student. All rights reserved.
//
//  

import UIKit
import SocketIO

class HomeViewController: DelegatedViewController
{
    var unwindOnce = true

    @IBAction func buttonAction(_ sender: Any)
    {
        guard let uploadData = try? JSONEncoder().encode(UserSendable(user: self.delegate.arrayOfUserInfo[0], passwordString: PairedPhrase.encodePass(pass:"abc123$%^")))
            else
        {
            print("let uploadData FAILED!!!")
            return
        }
        self.delegate.socket.emit(EmitStrings.update_user, with:[uploadData])
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("home")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        print("home")
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue)
    {
        print("home unwind")
        if unwindOnce
        {
            unwindOnce = false
            DispatchQueue.main.async
            {
                self.delegate.validateAllData()
            }
        }
    }

}
