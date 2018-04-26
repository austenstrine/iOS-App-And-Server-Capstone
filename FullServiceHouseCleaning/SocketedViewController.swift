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
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var backOnceUnwindSegue: UIStoryboardSegue?

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        print(self.classForCoder, "\noverride func prepare(for segue: UIStoryboardSegue, sender: Any?)")
//        let destinationViewController = segue.destination as! SocketedViewController
//    }
    
    
//    func checkSocket(every seconds:Int)
//    {
//        func printSocketStatus()
//        {
//            DispatchQueue.global(qos: .background).async
//                {
//                    print(self.socket.status)
//                    sleep(UInt32(seconds))
//                    printSocketStatus()
//                }
//        }
//        printSocketStatus()
//    }
    
//Plans
    
    
    /*func getPlansTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
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
    }*/
    
//Scheduled Visits
    
    
    
    /*func getScheduledVisitsTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
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
    }*/
    
//Techs
    
    
    /*func getTechsTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
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
    }*/
    
//User Info
    
    /*func getUserInfoTask(deferredUIUpdateFunc:@escaping VoidFunc) -> URLSessionDataTask
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
    }*/

}
