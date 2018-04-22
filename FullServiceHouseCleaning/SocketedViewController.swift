//
//  ContactViewController.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import SocketIO

typealias VoidFunc = () -> Void

class SocketedViewController: UIViewController
{
    let manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!,config:[.log(true), .connectParams(["token": "asliwemx"])])
    
    var clientLock = NSLock()
    var token:String?
    var socket:SocketIOClient!
    var arrayOfPlans = PlansArray()
    var arrayOfScheduledVisits = VisitsArray()
    var arrayOfTechs = TechsArray()
    var arrayOfUserInfo = UsersArray()
    var gotNewTokenObserver: NSObjectProtocol?
    var needsNewTokenObserver: NSObjectProtocol?
    var backOnceUnwindSegue: UIStoryboardSegue?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationViewController = segue.destination as! SocketedViewController
        destinationViewController.socket = self.socket
        destinationViewController.token = self.token
        destinationViewController.clientLock = self.clientLock
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if self.socket == nil, self.classForCoder != LoginPopupViewController.classForCoder()
        {
            self.socket = manager.defaultSocket
            self.socket.connect()
            self.setSocketEvents()
        }
        self.gotNewTokenObserver = NotificationCenter.default.addObserver(forName: Notification.Name.gotNewToken, object: nil, queue: .main, using:
            { (notification) in
                let popupViewController = notification.object as! LoginPopupViewController
                self.token = popupViewController.token
        })
        if self.needsNewTokenObserver == nil
        {
            self.needsNewTokenObserver = NotificationCenter.default.addObserver(forName: Notification.Name.needsNewToken, object: nil, queue: .main, using:
                { (notification) in
                    self.token = nil
            })
        }
    }
    
//    override func viewDidAppear(_ animated: Bool)
//    {
//    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        if let observer = gotNewTokenObserver
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        self.arrayOfPlans = PlansArray()
        self.arrayOfScheduledVisits = VisitsArray()
        self.arrayOfTechs = TechsArray()
        self.arrayOfUserInfo = UsersArray()
    }
    
    private func setSocketEvents()
    {
        self.socket.on(clientEvent: .connect)
        {
            data, ack in
            print("\n\nCONNECTED\n\n")
            
            DispatchQueue.global(qos: .background).async
            {
                if self.token == nil, self.classForCoder != LoginPopupViewController.classForCoder()
                {
                    DispatchQueue.main.async
                    {
                        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "loginPopupViewController") as? LoginPopupViewController
                        self.navigationController!.pushViewController(nextView!, animated: true)
                    }
                }
            }
        }
        self.socket.on(clientEvent: .disconnect)
        {
            data, ack in
            print("\n\nDISCONNECTED\n\n")
            NotificationCenter.default.post(name: .needsNewToken, object: nil)
            
        }
        self.socket.on(clientEvent: .error)
        {
            data, ack in
            let length = self.navigationController!.viewControllers.count
            if self.navigationController!.viewControllers[length-1].classForCoder != NetworkErrorViewController.classForCoder()
            {
                let nextView = self.storyboard!.instantiateViewController(withIdentifier: "networkErrorViewController") as! NetworkErrorViewController
                print(nextView)
                print(self.navigationController!)
                self.navigationController!.pushViewController(nextView, animated: true)
            }
        }
    }
//Plans
    
    func validatePlansData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        if self.arrayOfPlans.isEmpty
        {
            let task = self.getPlansTask(deferredUIUpdateFunc:deferredUIUpdateFunc)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    
    func getPlansTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
    {
        print("***Plans Entered***")
        let jsonURLString:String = "http://localhost:3000/plans/?token="+self.token!
        //print("@@@ Plans URL @@@"+jsonURLString)
        guard let url = URL(string: jsonURLString) else
        {
            print("***Plan URL Failed!***")
            return URLSessionDataTask()
        }
        let plansDataTask = URLSession.shared.dataTask(with: url)
        {
            (data, response, err) in
            self.clientLock.lock()
            print("plans got lock")
            defer
            {
                print("plans releasing lock")
                self.clientLock.unlock()
                DispatchQueue.main.async {
                    deferredUIUpdateFunc()
                }
            }
            guard let data = data else
            {
                print("***Plan Data Failed!***")
                return
            }//if data can't be assigned, exit.
            
            var arrayOfPlans = PlansArray()
            
            do
            {
                let plansAPIStruct = try JSONDecoder().decode(PlansAPIStruct.self, from: data)//grab data from server
                
                for item in plansAPIStruct.plans
                {
                    arrayOfPlans.append(item)
                }
                
            }
            catch let jsonErr
            {
                print ("error: ", jsonErr)
            }
            print("<<<PLANS>>>")
            self.arrayOfPlans = arrayOfPlans
            print(self.arrayOfPlans)
        }
        return plansDataTask
    }
    func getPlansTask() -> URLSessionDataTask
    {
        return self.getPlansTask(deferredUIUpdateFunc: {() in})
    }
//Scheduled Visits
    
    func validateScheduledVisitsData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        if self.arrayOfScheduledVisits.isEmpty
        {
            let task = self.getScheduledVisitsTask(deferredUIUpdateFunc:deferredUIUpdateFunc)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    
    func getScheduledVisitsTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
    {
        let jsonURLString:String = "http://localhost:3000/scheduled_visits/?token="+self.token!
        //print("@@@ visits URL @@@"+jsonURLString)
        guard let url = URL(string: jsonURLString) else
        {
            print("***Visit URL Failed!***")
            return URLSessionDataTask()
        }
        let scheduledVisitsDataTask = URLSession.shared.dataTask(with: url)
        {
            (data, response, err) in
            
            self.clientLock.lock()
            print("visits got lock")
            defer
            {
                print("visits releasing lock")
                self.clientLock.unlock()
                DispatchQueue.main.async {
                    deferredUIUpdateFunc()
                }
            }
            guard let data = data else
            {
                print("***Visit Data Failed!***")
                return
            }//if data can't be assigned, exit.
            
            var arrayOfScheduledVisits = VisitsArray()
            
            do
            {
                let scheduledVisitsAPIStruct = try JSONDecoder().decode(ScheduledVisitsAPIStruct.self, from: data)//grab data from server
                
                for item in scheduledVisitsAPIStruct.scheduled_visits
                {
                    arrayOfScheduledVisits.append(item)
                }
            }
            catch let jsonErr
            {
                print ("error: ", jsonErr)
            }
            self.arrayOfScheduledVisits = arrayOfScheduledVisits
        }
        return scheduledVisitsDataTask
    }
    func getScheduledVisitsTask() -> URLSessionDataTask
    {
        return self.getScheduledVisitsTask(deferredUIUpdateFunc:{() in})
    }
    
//Techs
    
    func validateTechsData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        if self.arrayOfTechs.isEmpty
        {
            let task = self.getTechsTask(deferredUIUpdateFunc:deferredUIUpdateFunc)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    
    func getTechsTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
    {
        let jsonURLString:String = "http://localhost:3000/techs/?token="+self.token!
        //print("@@@ Techs URL @@@"+jsonURLString)
        guard let url = URL(string: jsonURLString) else
        {
            print("***TEch URL Failed!***")
            return URLSessionDataTask()
        }
        let techsDataTask = URLSession.shared.dataTask(with: url)
        {
            (data, response, err) in
            
            self.clientLock.lock()
            print("techs got lock")
            defer
            {
                print("techs releasing lock")
                self.clientLock.unlock()
                DispatchQueue.main.async {
                    deferredUIUpdateFunc()
                }
            }
            guard let data = data else
            {
                print("***Tech Data Failed!***")
                return
            }//if data can't be assigned, exit.
            
            var arrayOfTechs = TechsArray()
            
            do
            {
                let techsAPIStruct = try JSONDecoder().decode(TechsAPIStruct.self, from: data)//grab data from server
                
                for item in techsAPIStruct.techs
                {
                    arrayOfTechs.append(item)
                }

            }
            catch let jsonErr
            {
                print ("error: ", jsonErr)
            }
            self.arrayOfTechs = arrayOfTechs
        }
        return techsDataTask
    }
    func getTechsTask() -> URLSessionDataTask
    {
        return self.getTechsTask(deferredUIUpdateFunc:{() in})
    }
    
//User Info
    
    func validateUserInfoData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        if self.arrayOfUserInfo.isEmpty
        {
            let task = self.getUserInfoTask(deferredUIUpdateFunc:deferredUIUpdateFunc)
            task.resume()
            //will create a data task that updates/initializes the arrayOfPlans and calls the deferredUIUpdateFunc after it has done so. Prevents data access before data exists
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    
    func getUserInfoTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
    {
        let jsonURLString:String = "http://localhost:3000/userinfo/?token="+self.token!
        //print("@@@ UserInfo URL @@@"+jsonURLString)
        guard let url = URL(string: jsonURLString) else
        {
            print("***User URL Failed!***")
            return URLSessionDataTask()
        }
        let userInfoDataTask = URLSession.shared.dataTask(with: url)
        {
            (data, response, err) in
            
            self.clientLock.lock()
            print("users got lock")
            defer
            {
                print("users releasing lock")
                self.clientLock.unlock()
                DispatchQueue.main.async {
                    deferredUIUpdateFunc()
                }
            }
            guard let data = data else
            {
                print("***User Data Failed!***")
                return
            }//if data can't be assigned, exit.
            print("&&& UserInfo Data to follow &&&")
            //print(data)
            do
            {
                print("Entered userinfo do")
                let userInfo = try JSONDecoder().decode(UserAPIStruct.self, from: data)//grab data from server
                //print(userInfo)
                //print("***user data above***")
                var arrayOfUsers = UsersArray()
                for item in userInfo.user
                {
                    arrayOfUsers.append(item)
                }
                self.arrayOfUserInfo = arrayOfUsers
            }
            catch let jsonErr
            {
                print ("error: ", jsonErr)
            }
        }
        return userInfoDataTask
    }
    func getUserInfoTask() -> URLSessionDataTask
    {
        return self.getUserInfoTask(deferredUIUpdateFunc:{() in})
    }

}
