//
//  NetworkErrorViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Thursday4/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class NetworkErrorViewController: UIViewController
{

    override func viewWillAppear(_ animated: Bool)
    {
        DispatchQueue.main.async
        {
            if self.navigationController != nil
            {
                self.navigationController!.isNavigationBarHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func tryAgainButtonTapped(_ sender: Any)
    {
        if self.navigationController != nil
        {
            self.navigationController!.isNavigationBarHidden = false
        }
        performSegue(withIdentifier: "unwindToHome", sender: self)
        DispatchQueue.main.async
        {
            (UIApplication.shared.delegate as! AppDelegate).validateSocket(rebuildSocket: true)
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
