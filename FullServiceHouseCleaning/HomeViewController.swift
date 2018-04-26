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

class HomeViewController: SocketedViewController
{

    @IBAction func buttonAction(_ sender: Any) {
        delegate.socket.emit("plans_request")
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nHome viewDidLoad()\n\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\n\nHome viewDidAppear\n\n")
        delegate.validateSocket(rebuildSocket: false)
        print(delegate.socket.status)
        if delegate.socket.status != .connected
        {
            print("\n\nConnecting, not connected.\n\n")
            delegate.connectSocket()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate.validateAllData()
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue)
    {
        //self.delegate.validateAllData()
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
