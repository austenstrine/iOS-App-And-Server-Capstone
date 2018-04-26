//
//  AppDelegate.swift
//  FullServiceHouseCleaning
//
//  Created by Student on 3/13/18.
//  Copyright © 2018 Student. All rights reserved.
//
/*  DEBUG:
        Low Priority:
            Socket connecting to server twice(thrice?) after (application becomes active, then user logs in), ONLY when application is sent to the background
            HomeView opens loginpopup twice(thrice?) on server reconnecting mid-app run
            Socket disconnect event does nothing - figure out how it should be done
    BUILD Priority:
        Profile
            HIGH -> edit buttons
            HIGH -> API implementation for updating profiles, not deleting/adding!
            LOW -> Roller content needs to be ordered by date, newest at the top to oldest at the bottom
        LoginPopup
            HIGH -> New account creation button
            HIGH -> API validation of usernames and passwords - Username should be unique, must be confirmed as a valid email through API sending an email to it
            HIGH -> API code for adding of user already exists, need to build client-side implementation
            HIGH -> Create "New Account" view, should be a copy-paste-modify of the My Profile view.
            LOW -> password must be secure
        Calendar
            LOW -> Gray out/disable days that are before current date. Converting yyyyMMdd to int and compare size should do it.
        Socketed
            *HIGH -> Build in socket.io event data handling for all textual data, build on API as well
            !HIGH -> Build in user/pass validation through socket.io, same as above

        * -> In Progress
            Notes -> need to alter any UI updates that rely on array data, so they provide filler/empty data while they wait for an emission to provide the requested data. Also need to finish implementing request/response emissions with the array validation functions, and insert emission listeners through them
        ! -> Complete
*/

import UIKit
import SocketIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var root:UINavigationController!
    var manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!,config:[.log(false), .connectParams(["token": "nil"])])
    var clientLock = NSLock()
    var token:String = "nil"
    var id:Int = -10
    var socket:SocketIOClient!
    var window: UIWindow?
    var connectCodeCanRun:Bool = true
    var disconnectCodeCanRun:Bool = true
    var arrayOfPlans = PlansArray()
    var arrayOfScheduledVisits = VisitsArray()
    var arrayOfTechs = TechsArray()
    var arrayOfUserInfo = UsersArray()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        root = self.window!.rootViewController! as! UINavigationController
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print(self.classForCoder, "\nfunc applicationWillResignActive")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyyT:hh:mm.ss"
            socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            if socket != nil
            {
                socket.disconnect()
                socket = nil
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(self.classForCoder,"\nfunc applicationDidEnterBackground")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            if socket != nil
            {
                socket.disconnect()
                socket = nil
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print(self.classForCoder,"\nfunc applicationWillEnterForeground")
        let sockWindow: SocketedViewController = root.viewControllers[root.viewControllers.count-1] as! SocketedViewController
        self.validateSocket(rebuildSocket: false)
        if self.connectCodeCanRun, socket.status != SocketIOStatus.connected
        {
            self.disconnectCodeCanRun = true
            self.connectCodeCanRun = false
            DispatchQueue.global(qos: .background).async
            {
                if self.token == "nil", sockWindow.classForCoder != LoginPopupViewController.classForCoder()
                {
                    DispatchQueue.main.async
                    {
                        let nextView = sockWindow.storyboard!.instantiateViewController(withIdentifier: "loginPopupViewController") as? LoginPopupViewController
                        sockWindow.navigationController!.pushViewController(nextView!, animated: true)
                    }//end main thread push
                }//end if
            }//end background thread push
        }//end if not connected
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(self.classForCoder,"\nfunc applicationDidBecomeActive")
        validateSocket(rebuildSocket: false)
        if self.connectCodeCanRun, socket.status != SocketIOStatus.connected
        {
            self.disconnectCodeCanRun = true
            self.connectCodeCanRun = false
        }//end if not connected
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(self.classForCoder,"\nfunc applicationWillTerminate")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            if socket != nil
            {
                socket.disconnect()
                socket = nil
            }
        }
    }
    
    func setSocketEvents()
    {
        self.socket.on(clientEvent: .connect)
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on(clientEvent: .connect)")
            self.clientLock.lock()
            print("\n\nCONNECTED\n\n")
            print(self.token as Any, "<--TOKEN")
            DispatchQueue.global(qos: .background).async
                {
                    self.clientLock.lock()
                    if self.token == "nil" || self.token == ""
                    {
                        if self.classForCoder != LoginPopupViewController.classForCoder()
                        {
                            //print("\n\n", self.manager, " is manager\n\n")
                            self.pushLoginPopup()
                        }
                    }
                    self.clientLock.unlock()
            }
            self.clientLock.unlock()
        }
        
        self.socket.on(clientEvent: .disconnect)
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on(clientEvent: .disconnect)")
            print("\n\nDISCONNECTED\n\n")
            
        }
        
        self.socket.on(clientEvent: .error)
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on(clientEvent: .error)")
            print("error")
            print(self.root)
            if self.root != nil
            {
                let length = self.root.viewControllers.count//this line generates an error, unexpectedly found nil unwrapping optional
                if self.root.viewControllers[length-1].classForCoder != NetworkErrorViewController.classForCoder()
                {
                    let nextView = self.root.storyboard!.instantiateViewController(withIdentifier: "networkErrorViewController") as! NetworkErrorViewController
                    print(nextView)
                    print(self.root)
                    self.root.pushViewController(nextView, animated: true)
                }
            }
        }
        
        self.socket.on("needs_new_token")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on('needs_new_token')")
            print("needs_new_token")
            self.pushLoginPopup()
        }
        
        self.socket.on("plans_data")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on('plans_data')")
            print("\n\n\nplans_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let plans = gotData["plans"] as! [[String:Any]]
            var arrayOfPlans = PlansArray()
            for planDict in plans
            {
                arrayOfPlans.append(Plan(json:planDict))
            }
            self.arrayOfPlans = arrayOfPlans
            print(self.arrayOfPlans)
        }
        
        self.socket.on("techs_data")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on('techs_data')")
            print("\n\n\ntechs_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let techs = gotData["techs"] as! [[String:Any]]
            var arrayOfTechs = TechsArray()
            for techDict in techs
            {
                arrayOfTechs.append(Tech(json:techDict))
            }
            self.arrayOfTechs = arrayOfTechs
            print(self.arrayOfTechs)
        }
        
        self.socket.on("user_data")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on('user_data')")
            print("\n\n\nuser_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let users = gotData["users"] as! [[String:Any]]
            var arrayOfUsers = UsersArray()
            for userDict in users
            {
                arrayOfUsers.append(User(json:userDict))
            }
            self.arrayOfUserInfo = arrayOfUsers
            print(self.arrayOfUserInfo)
        }
        
        self.socket.on("scheduled_visit_data")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on('scheduled_visit_data')")
            print("\n\n\nscheduled_visit\n\n\n")
            let gotData = data[0] as! NSDictionary
            let scheduledVisits = gotData["users"] as! [[String:Any]]
            var arrayOfScheduledVisits = VisitsArray()
            for visitDict in scheduledVisits
            {
                arrayOfScheduledVisits.append(ScheduledVisit(json:visitDict))
            }
            self.arrayOfScheduledVisits = arrayOfScheduledVisits
            print(self.arrayOfScheduledVisits)
        }
        
        socket.on("scheduled_visits_updated")
        {
            data, ack in
            if let calendarView = self.getTopInNav() as? CalendarViewController
            {
                self.validateScheduledVisitsData
                {
                    calendarView.reloadCalendar()
                }
            }
        }
        
        self.socket.on("reconnect_with_token")
        {
            data, ack in
            print(self.classForCoder, "\nself.socket.on(\"reconnect_with_token\"")
            let gotToken = data[0] as! [String:Any]
            self.token = gotToken["token"] as! String
            self.id = gotToken["id"] as! Int
            self.validateSocket(rebuildSocket: true)
            DispatchQueue.main.async
            {
                print("\n\nSEGUE\n\n")
                if let topView = self.getTopInNav() as? LoginPopupViewController
                {
                    topView.performSegue(withIdentifier: "unwindToHome", sender: self)
                    self.setSocketEvents()
                }
            }
        }
        
        self.socket.on("incorrect_auth")
        {
            data, ack in
            if let loginPopupView = self.getTopInNav() as? LoginPopupViewController
            {
                loginPopupView.warningLabel.alpha = 1
            }
        }
    }
    
    func connectSocket()
    {
        print(self.classForCoder, "\nfunc connectSocket()")
        if self.socket.status == .disconnected || self.socket.status == .notConnected
        {
            self.socket.connect()
        }
    }
    
    func validateSocket(rebuildSocket:Bool)
    {
        print(self.classForCoder, "\nfunc validateSocket(rebuildSocket:Bool)")
        if rebuildSocket
        {
            self.manager.disconnect()
            self.manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!,config:[.log(false), .connectParams(["token": self.token])])
            if self.socket != nil
            {
                self.socket.disconnect()
                self.socket = nil
            }
            self.socket = manager.defaultSocket
            self.setSocketEvents()
            self.connectSocket()
        }
        else
        {
            if self.socket == nil//, self.classForCoder != LoginPopupViewController.classForCoder()
            {
                self.manager.disconnect()
                self.manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!,config:[.log(false), .connectParams(["token": self.token])])
                if self.socket != nil
                {
                    self.socket.disconnect()
                    self.socket = nil
                }
                self.socket = manager.defaultSocket
                self.setSocketEvents()
                self.connectSocket()
            }
        }
    }
    
    func validatePlansData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        print(self.classForCoder, "\nfunc validatePlansData(deferredUIUpdateFunc:@escaping VoidFunc)")
        if self.arrayOfPlans.isEmpty
        {
            self.socket.on("plans_data")
            {
                data, ack in
                print("\n\n\nplans_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let plans = gotData["plans"] as! [[String:Any]]
                var arrayOfPlans = PlansArray()
                for planDict in plans
                {
                    arrayOfPlans.append(Plan(json:planDict))
                }
                self.arrayOfPlans = arrayOfPlans
                print(self.arrayOfPlans)
                DispatchQueue.main.async
                {
                    print("CHECK TRIGGERED")
                    deferredUIUpdateFunc()
                    self.setSocketEvents()
                }
            }
            self.socket.emit("plans_request")
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    func validatePlansData()
    {
        print(self.classForCoder, "\nfunc validatePlansData()")
        self.socket.emit("plans_request")
    }
    
    func validateScheduledVisitsData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        print(self.classForCoder, "\nfunc validateScheduledVisitsData(deferredUIUpdateFunc:@escaping VoidFunc)")
        if self.arrayOfScheduledVisits.isEmpty
        {
            self.socket.on("scheduled_visit_data")
            {
                data, ack in
                print("\n\n\nscheduled_visit\n\n\n")
                let gotData = data[0] as! NSDictionary
                let scheduledVisits = gotData["users"] as! [[String:Any]]
                var arrayOfScheduledVisits = VisitsArray()
                for visitDict in scheduledVisits
                {
                    arrayOfScheduledVisits.append(ScheduledVisit(json:visitDict))
                }
                self.arrayOfScheduledVisits = arrayOfScheduledVisits
                print(self.arrayOfScheduledVisits)
                
                DispatchQueue.main.async
                {
                    deferredUIUpdateFunc()
                    print("CHECK TRIGGERED")
                    self.setSocketEvents()
                }
            }
            self.socket.emit("scheduled_visits_request")
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    func validateScheduledVisitsData()
    {
        print(self.classForCoder, "\nfunc validateScheduledVisitsData()")
        self.socket.emit("scheduled_visits_request")
    }
    
    func validateTechsData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        print(self.classForCoder, "\nfunc validateTechsData(deferredUIUpdateFunc:@escaping VoidFunc)")
        if self.arrayOfTechs.isEmpty
        {
            self.socket.on("techs_data")
            {
                data, ack in
                print("\n\n\ntechs_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let techs = gotData["techs"] as! [[String:Any]]
                var arrayOfTechs = TechsArray()
                for techDict in techs
                {
                    arrayOfTechs.append(Tech(json:techDict))
                }
                self.arrayOfTechs = arrayOfTechs
                print(self.arrayOfTechs)
                
                DispatchQueue.main.async
                {
                    deferredUIUpdateFunc()
                    print("CHECK TRIGGERED")
                    self.setSocketEvents()
                }
            }
            self.socket.emit("techs_request")
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    func validateTechsData()
    {
        print(self.classForCoder, "\nfunc validateTechsData()")
        self.socket.emit("techs_request")
    }
    
    func validateUserInfoData(deferredUIUpdateFunc:@escaping VoidFunc)
    {
        print(self.classForCoder, "\nfunc validateUserInfoData(deferredUIUpdateFunc:@escaping VoidFunc)")
        if self.arrayOfUserInfo.isEmpty
        {
            self.socket.on("users_data")
            {
                data, ack in
                print("\n\n\nuser_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let users = gotData["users"] as! [[String:Any]]
                print("users:\(users)")
                var arrayOfUsers = UsersArray()
                for userDict in users
                {
                    arrayOfUsers.append(User(json:userDict))
                }
                self.arrayOfUserInfo = arrayOfUsers
                print("##################################")
                print("# ALTERED EVENT DID RUN          #")
                print("##################################")
                
                DispatchQueue.main.async
                    {
                        deferredUIUpdateFunc()
                        print("CHECK TRIGGERED")
                        self.setSocketEvents()
                }
            }
            guard let uploadData = try? JSONEncoder().encode(ID(id:self.id))
            else
            {
                print("let uploadData = try? JSONEncoder().encode(ID(ID:self.id)) FAILED!!!")
                return
            }
            
            self.socket.emit("users_request", with:[uploadData])
        }
        else
        {
            deferredUIUpdateFunc()
        }
    }
    func validateUserInfoData()
    {
        guard let uploadData = try? JSONEncoder().encode(ID(id:self.id))
            else
        {
            print("let uploadData = try? JSONEncoder().encode(ID(ID:self.id)) FAILED!!!")
            return
        }
        
        self.socket.emit("users_request", with:[uploadData])
    }
    
    func validateAllData()
    {
        self.validateTechsData()
        self.validatePlansData()
        self.validateUserInfoData()
        self.validateScheduledVisitsData()
    }
    
    struct ID:Codable
    {
        let id:Int
    }
    
    
    func pushLoginPopup()
    {
        print(self.classForCoder, "\nfunc pushLoginPopup()")
        DispatchQueue.main.async
        {
            let nextView = self.root.storyboard!.instantiateViewController(withIdentifier: "loginPopupViewController") as? LoginPopupViewController
            print(self.root, self.root.classForCoder)
            self.root.pushViewController(nextView!, animated: true)
        }
    }
    
    func getTopInNav() -> UIViewController
    {
        let navViewControllers = self.root.viewControllers
        return navViewControllers[navViewControllers.count-1]
    }
}

