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

class HomeViewController: SocketedViewController {

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("\n\nHome viewDidAppear\n\n")
        print(self.socket.status)
        if self.socket.status != .connected
        {
            print("\n\nConnecting, not connected.\n\n")
            self.socket.connect()
        }
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue)
    {
        
        if let sourceViewController = segue.source as? SocketedViewController
        {
            self.token = sourceViewController.token
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
