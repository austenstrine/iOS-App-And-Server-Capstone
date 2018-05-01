//
//  AppDelegate.swift
//  FullServiceHouseCleaning
//
//  Created by Student on 3/13/18.
//  Copyright © 2018 Student. All rights reserved.
//
/*  DEBUG: priority -> bug
 
        !HIGH -> Socket disconnect event does nothing - figure out how it should be done
        !LOW -> Socket connecting to server twice(thrice?) after (application becomes active, then user logs in), ONLY when application is sent to the background
        !LOW -> HomeView opens loginpopup twice(thrice?) on server reconnecting mid-app run
 
        LOW -> NetworkError will push, then LoginPopup on "Try Again" select for NetworkError - probably needs to be fixed in Home
 
    BUILD: priority -> build
 
        All Views
            LOW -> add animation, opacity
 
        Profile
            !HIGH -> edit buttons
            !HIGH -> API implementation for updating profiles, not deleting/adding!
            !LOW -> Roller content needs to be ordered by date, newest at the top to oldest at the bottom
 
            LOW -> set NavController.isNavViewControllerVisible = false when going to plansView
            LOW -> API validation of usernames and passwords - Username should be unique, must be confirmed as a valid email through API sending an email to it
                -> create data validation emit event handlers on API and in AppDelegate, emit from here with data to server to see if server thinks the data is valid, server responds with an emit with data detailing what was wrong or that all is well
            LOW -> make savedData a static variable, make initialization of savedData happen on viewWillDisappear, ensure that it only reloads with "new user" version of page if emitNewUser = true, else discards savedData, vice versa, ensure that it does not initialize if discard changes button was selected
 
        LoginPopup
            !HIGH -> New account creation button
            !HIGH -> API code for adding of user already exists, need to build client-side implementation
            !HIGH -> Create "New Account" view, should be a copy-paste-modify of the My Profile view.
 
            *LOW -> password must be secure
                -> created crappy Ceasar Cipher that encrypts only the password(I'm keeping it regardless, maybe after security is enabled it will throw an unexpected wrench in any successful hacks), API does not check whether the password the user chooses is secure or not, does not check for length. In the future, maybe have user choose a security phrase that acts as the cipher key? I'm kind of just playing with this for fun.
 
        Calendar
            !LOW -> Gray out/disable days that are before current date. Converting yyyyMMdd to int and compare size should do it.
 
            LOW -> correct horizontal alignment after calendar appears
            LOW -> change techs scrollview into a collectionview that initializes tech buttons dynamically according to the number of techs
                -> HIGH WORKLOAD
 
        Delegated(changed from Socketed, socket functionality moved to AppDelegate)
            !HIGH -> Build in socket.io event data handling for all textual data, build on API as well
            !HIGH -> Build in user/pass validation through socket.io, same as above
 
        AppDelegate
            LOW -> figure out how to enable/implement https or tls/ssl on socket.io
 
        NetworkError
            !LOW -> Ensure user must get a new token on reconnect

        * -> In Progress
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
    var username:String = ""
    var password:String = ""
    var socket:SocketIOClient!
    var window: UIWindow?
    var connectCodeCanRun:Bool = true
    var disconnectCodeCanRun:Bool = true
    var arrayOfPlans = PlansArray()
    var arrayOfScheduledVisits = VisitsArray()
    var arrayOfTechs = TechsArray()
    var arrayOfUserInfo = UsersArray()
    var dataGetRunning:Bool = false
    var plansValidationHasNotRun = true
    var userValidationHasNotRun = true
    var techsValidationHasNotRun = true
    var scheduledVisitsValidationHasNotRun = true
    var newTokenHandlerRunning:Bool = false


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
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func applicationWillResignActive")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyyT:hh:mm.ss"
            socket.emit(EmitStrings.disconnect, with: [dateFormat.string(from:Date())])
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
        print("\n", self.classForCoder, Thread.current,"\n\n"+"func applicationDidEnterBackground")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            socket.emit(EmitStrings.disconnect, with: [dateFormat.string(from:Date())])
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
        print("\n", self.classForCoder, Thread.current,"\n\n"+"func applicationWillEnterForeground")
        
        DispatchQueue.main.async
        {
            let sockWindow: DelegatedViewController = self.root.viewControllers[self.root.viewControllers.count-1] as! DelegatedViewController
            self.validateSocket(rebuildSocket: false)
            if self.connectCodeCanRun, self.socket.status != SocketIOStatus.connected
            {
                self.disconnectCodeCanRun = true
                self.connectCodeCanRun = false
                DispatchQueue.main.async
                {
                    if self.token == "nil", sockWindow.classForCoder != LoginPopupViewController.classForCoder()
                    {
                        let nextView = sockWindow.storyboard!.instantiateViewController(withIdentifier: "loginPopupViewController") as? LoginPopupViewController
                        sockWindow.navigationController!.pushViewController(nextView!, animated: true)
                    }//end if
                }//end background thread push
            }//end if not connected
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("\n", self.classForCoder, Thread.current,"\n\n"+"func applicationDidBecomeActive")
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
        print("\n", self.classForCoder, Thread.current,"\n\n"+"func applicationWillTerminate")
        if self.disconnectCodeCanRun, socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            socket.emit(EmitStrings.disconnect, with: [dateFormat.string(from:Date())])
            if socket != nil
            {
                socket.disconnect()
                socket = nil
            }
        }
    }
    
/*   ********************
**   * Socket Functions *
**   ********************
**       func connectSocket()
**       func validateSocket(rebuildSocket:Bool)
**       func setSocketEvents()
**/
    
    func connectSocket()
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func connectSocket()")
        if self.socket.status == .disconnected || self.socket.status == .notConnected
        {
            self.socket.connect()
        }
    }
    
    func validateSocket(rebuildSocket:Bool)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateSocket(rebuildSocket:Bool)")
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
            if self.socket == nil//, "\n", self.classForCoder != LoginPopupViewController.classForCoder()
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
    
    func setSocketEvents()
    {
        self.socket.on(clientEvent: .connect)
        {
            data, ack in//the majority of these event handlers need their code to be converted into functions because the code is reused and needs to be exactly the same, with the option of a deferred code completion handling block
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on(clientEvent: .connect)")
            self.clientLock.lock()
            print("\n\n"+"\nCONNECTED\n\n")
            print(self.token as Any, "<--TOKEN")
            DispatchQueue.main.async
            {
                self.clientLock.lock()
                if self.token == "nil" || self.token == ""
                {
                    if self.classForCoder != LoginPopupViewController.classForCoder()
                    {
                        //print("\n\n"+"\n", self.manager, " is manager\n\n")
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
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on(clientEvent: .disconnect)")
            print("\n\n"+"\nDISCONNECTED\n\n")
            
        }
        
        self.socket.on(clientEvent: .error)
        {
            data, ack in
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on(clientEvent: .error)")
            print("error")
            print(self.root)
            DispatchQueue.main.async
            {
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
        }
        
        self.socket.on(EmitStrings.needs_new_token)
        {
            data, ack in
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on('needs_new_token')")
            if self.newTokenHandlerRunning != true
            {
                self.newTokenHandlerRunning = true
                self.token = "nil"
                self.validateSocket(rebuildSocket: true)
                DispatchQueue.main.async
                {
                    self.newTokenHandlerRunning = false
                }
            }
        }
        
        self.socket.on(EmitStrings.plans_data)
        {
            data, ack in
            self.clientLock.lock()
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on('plans_data')")
            print("\n\n"+"\n\nplans_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let plans = gotData["plans"] as! [[String:Any]]
            var arrayOfPlans = PlansArray()
            for planDict in plans
            {
                arrayOfPlans.append(Plan(json:planDict))
            }
            self.arrayOfPlans = arrayOfPlans
            //print(self.arrayOfPlans)
            self.clientLock.unlock()
        }
        
        self.socket.on(EmitStrings.techs_data)
        {
            data, ack in
            self.clientLock.lock()
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on('techs_data')")
            print("\n\n"+"\n\ntechs_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let techs = gotData["techs"] as! [[String:Any]]
            var arrayOfTechs = TechsArray()
            for techDict in techs
            {
                arrayOfTechs.append(Tech(json:techDict))
            }
            self.arrayOfTechs = arrayOfTechs
            //print(self.arrayOfTechs)
            self.clientLock.unlock()
        }
        
        self.socket.on(EmitStrings.users_data)
        {
            data, ack in
            self.clientLock.lock()
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on('user_data')")
            print("\n\n"+"\n\nuser_data\n\n\n")
            let gotData = data[0] as! NSDictionary
            let users = gotData["users"] as! [[String:Any]]
            var arrayOfUsers = UsersArray()
            for userDict in users
            {
                arrayOfUsers.append(User(json:userDict))
            }
            self.arrayOfUserInfo = arrayOfUsers
            //print(self.arrayOfUserInfo)
            self.clientLock.unlock()
        }
        
        self.socket.on(EmitStrings.scheduled_visits_data)
        {
            data, ack in
            //print(self.arrayOfScheduledVisits)
            self.clientLock.lock()
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on('scheduled_visit_data')")
            print("\n\n"+"\n\nscheduled_visit\n\n\n")
            let gotData = data[0] as! NSDictionary
            let scheduledVisits = gotData["scheduled_visits"] as! [[String:Any]]
            var arrayOfScheduledVisits = VisitsArray()
            for visitDict in scheduledVisits
            {
                arrayOfScheduledVisits.append(ScheduledVisit(json:visitDict))
            }
            self.arrayOfScheduledVisits = arrayOfScheduledVisits
            //print(self.arrayOfScheduledVisits)
            self.clientLock.unlock()
        }
        
        socket.on(EmitStrings.scheduled_visits_updated)
        {
            data, ack in
            print("\n\nsocket.on(\"scheduled_visits_updated\")\n\n")
            //print(self.arrayOfScheduledVisits)
            self.clientLock.lock()
            if let calendarView = self.getTopInNav() as? CalendarViewController
            {
                self.validateScheduledVisitsData(rebuild:true)
                {
                    calendarView.reloadCalendar()
                }
            }
            self.clientLock.unlock()
        }
        
        self.socket.on(EmitStrings.reconnect_with_token)
        {
            data, ack in
            print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on(\"reconnect_with_token\"")
            let gotToken = data[0] as! [String:Any]
            self.token = gotToken["token"] as! String
            self.id = gotToken["id"] as! Int
            self.validateSocket(rebuildSocket: true)
            DispatchQueue.main.async
            {
                print("\n\n"+"\nSEGUE\n\n")
                if let topView = self.getTopInNav() as? LoginPopupViewController
                {
                    self.socket.on(clientEvent: .connect)
                    {
                        data, ack in
                        print("\n", self.classForCoder, Thread.current, "\n\n"+"self.socket.on(clientEvent: .connect)")
                        self.clientLock.lock()
                        print("\n\n"+"\nCONNECTED\n\n")
                        print(self.token as Any, "<--TOKEN")
                        DispatchQueue.main.async
                        {
                            topView.performSegue(withIdentifier: "unwindToHome", sender: self)
                            self.setSocketEvents()
                        }
                        self.clientLock.unlock()
                    }
                }
            }
        }
        
        self.socket.on(EmitStrings.incorrect_auth)
        {
            data, ack in
            DispatchQueue.main.async
            {
                if let loginPopupView = self.getTopInNav() as? LoginPopupViewController
                {
                    loginPopupView.warningLabel.alpha = 1
                }
            }
        }
    }
    
/*  *************************************
**  | Data Validation/Rebuild Functions |
**  *************************************
**      func validateAllData()
**      func validateAllData(mainThreadCompletionHandler:@escaping VoidFunc)
**      func buildAllData()
**      func validatePlansData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
**      func validatePlansData(rebuild:Bool)
**      func validateScheduledVisitsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
**      func validateScheduledVisitsData(rebuild:Bool)
**      func validateTechsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
**      func validateTechsData(rebuild:Bool)
**      func validateUserInfoData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
**      func validateUserInfoData(rebuild:Bool)
**      func resetValidationBools()
**/

    func validateAllData()
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateAllData()")
        
        self.validateSocket(rebuildSocket: false)
        self.validateTechsData(rebuild:false)
        {
            self.validatePlansData(rebuild:false)
            {
                self.validateUserInfoData(rebuild:false)
                {
                    self.validateScheduledVisitsData(rebuild:false)
                    {
                        
                    }
                }
            }
        }
    }//end func validateAllData()
    
    func validateAllData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateAllData()")
        
        self.validateSocket(rebuildSocket: false)
        self.validateTechsData(rebuild:rebuild)
        {
            self.validatePlansData(rebuild:rebuild)
            {
                self.validateUserInfoData(rebuild:rebuild)
                {
                    self.validateScheduledVisitsData(rebuild:rebuild)
                    {
                        mainThreadCompletionHandler()
                    }
                }
            }
        }
        if self.scheduledVisitsValidationHasNotRun == false
        {
            mainThreadCompletionHandler()
        }
    }//end func validateAllData(mainThreadCompletionHandler:@escaping VoidFunc)
    
    func validatePlansData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validatePlansData(mainThreadCompletionHandler:@escaping VoidFunc)")
        
        func embedCompletionHandlerInEventHandler()
        {
            self.socket.on(EmitStrings.plans_data)
            {
                data, ack in
                print("\n\n"+"\n\nplans_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let plans = gotData["plans"] as! [[String:Any]]
                var arrayOfPlans = PlansArray()
                for planDict in plans
                {
                    arrayOfPlans.append(Plan(json:planDict))
                }
                self.arrayOfPlans = arrayOfPlans
                //print(self.arrayOfPlans)
                DispatchQueue.main.async
                    {
                        self.setSocketEvents()
                        self.dataGetRunning = false
                        print("CHECK TRIGGERED")
                        mainThreadCompletionHandler()
                }
            }
        }//end embedCompletionHandlerInEventHandler
        
        if rebuild
        {
            self.dataGetRunning = true
            embedCompletionHandlerInEventHandler()
            self.plansValidationHasNotRun = false
            self.socket.emit(EmitStrings.plans_request)
        }
        else
        {
            if self.arrayOfPlans.isEmpty
            {
                if self.plansValidationHasNotRun
                {
                    self.dataGetRunning = true
                    embedCompletionHandlerInEventHandler()
                    self.plansValidationHasNotRun = false
                    self.socket.emit(EmitStrings.plans_request)
                }
            }
            else
            {
                mainThreadCompletionHandler()
            }
        }
    }//end validatePlansData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    
    func validatePlansData(rebuild:Bool)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validatePlansData(rebuild:Bool)")
        dataGetRunning = true
        validatePlansData(rebuild: rebuild)
        {
            self.dataGetRunning = false
        }
    }//end validatePlansData(rebuild:Bool)
    
    func validateScheduledVisitsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateScheduledVisitsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)")
        
        func embedCompletionHandlerInEventHandler()
        {
            self.socket.on(EmitStrings.scheduled_visits_data)
            {
                data, ack in
                print("\n\n"+"\n\nscheduled_visit\n\n\n")
                let gotData = data[0] as! NSDictionary
                let scheduledVisits = gotData["scheduled_visits"] as! [[String:Any]]
                var arrayOfScheduledVisits = VisitsArray()
                for visitDict in scheduledVisits
                {
                    arrayOfScheduledVisits.append(ScheduledVisit(json:visitDict))
                }
                self.arrayOfScheduledVisits = arrayOfScheduledVisits
                //print(self.arrayOfScheduledVisits)
                
                DispatchQueue.main.async
                {
                    self.setSocketEvents()
                    self.dataGetRunning = false
                    mainThreadCompletionHandler()
                    print("CHECK TRIGGERED")
                }
            }
        }
        
        if rebuild
        {
            self.dataGetRunning = true
            embedCompletionHandlerInEventHandler()
            self.scheduledVisitsValidationHasNotRun = false
            self.socket.emit(EmitStrings.scheduled_visits_request)
        }
        else
        {
            if self.arrayOfScheduledVisits.isEmpty
            {
                if self.scheduledVisitsValidationHasNotRun
                {
                    self.dataGetRunning = true
                    embedCompletionHandlerInEventHandler()
                    self.scheduledVisitsValidationHasNotRun = false
                    self.socket.emit(EmitStrings.scheduled_visits_request)
                }
            }
            else
            {
                mainThreadCompletionHandler()
            }
        }
    }//end func validateScheduledVisitsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    func validateScheduledVisitsData(rebuild:Bool)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateScheduledVisitsData()")
        dataGetRunning = true
        validateScheduledVisitsData(rebuild: rebuild)
        {
            self.dataGetRunning = false
        }
    }//end func validateScheduledVisitsData(rebuild:Bool)
    
    func validateTechsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateTechsData(mainThreadCompletionHandler:@escaping VoidFunc)")

        
        func embedCompletionHandlerInEventHandler()
        {
            self.socket.on(EmitStrings.techs_data)
            {
                data, ack in
                print("\n\n"+"\n\ntechs_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let techs = gotData["techs"] as! [[String:Any]]
                var arrayOfTechs = TechsArray()
                for techDict in techs
                {
                    arrayOfTechs.append(Tech(json:techDict))
                }
                self.arrayOfTechs = arrayOfTechs
                //print(self.arrayOfTechs)
                
                DispatchQueue.main.async
                {
                    self.setSocketEvents()
                    self.dataGetRunning = false
                    mainThreadCompletionHandler()
                    print("CHECK TRIGGERED")
                }
            }
        }//end embedCompletionHandlerInEventHandler
        
        if rebuild
        {
            self.dataGetRunning = true
            embedCompletionHandlerInEventHandler()
            self.techsValidationHasNotRun = false
            self.socket.emit(EmitStrings.techs_request)
        }
        else
        {
            if self.arrayOfTechs.isEmpty
            {
                if self.techsValidationHasNotRun
                {
                    self.dataGetRunning = true
                    embedCompletionHandlerInEventHandler()
                    self.techsValidationHasNotRun = false
                    self.socket.emit(EmitStrings.techs_request)
                }
            }
            else
            {
                mainThreadCompletionHandler()
            }
        }//end rebuild
    }//end func validateTechsData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    func validateTechsData(rebuild:Bool)
    {
        dataGetRunning = true
        validateTechsData(rebuild: rebuild)
        {
            self.dataGetRunning = false
        }
    }//end func validateTechsData(rebuild:Bool)
    
    func validateUserInfoData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateUserInfoData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)")
        
        func embedCompletionHandlerInEventHandler()
        {
            self.socket.on(EmitStrings.users_data)
            {
                data, ack in
                print("\n\n"+"\n\nuser_data\n\n\n")
                let gotData = data[0] as! NSDictionary
                let users = gotData["users"] as! [[String:Any]]
                print("users:\(users)")
                var arrayOfUsers = UsersArray()
                for userDict in users
                {
                    arrayOfUsers.append(User(json:userDict))
                }
                self.arrayOfUserInfo = arrayOfUsers
                
                DispatchQueue.main.async
                {
                    mainThreadCompletionHandler()
                    print("mainThreadCompletionHandler run: \(mainThreadCompletionHandler)")
                    self.setSocketEvents()
                    self.dataGetRunning = false
                }
            }
        }//end func embedCompletionHandlerInEventHandler()
        
        guard let uploadData = try? JSONEncoder().encode(ID(id:self.id))
            else
        {
            print("let uploadData = try? JSONEncoder().encode(ID(ID:self.id)) FAILED!!!")
            return
        }
        
        if rebuild
        {
            self.dataGetRunning = true
            embedCompletionHandlerInEventHandler()
            self.userValidationHasNotRun = false
            self.socket.emit(EmitStrings.users_request, with:[uploadData])
        }
        else
        {
            if self.arrayOfUserInfo.isEmpty
            {
                if self.userValidationHasNotRun
                {
                    self.dataGetRunning = true
                    embedCompletionHandlerInEventHandler()
                    self.userValidationHasNotRun = false
                    self.socket.emit(EmitStrings.users_request, with:[uploadData])
                }
            }
            else
            {
                mainThreadCompletionHandler()
            }
        }
    }//end func validateUserInfoData(rebuild:Bool, mainThreadCompletionHandler:@escaping VoidFunc)
    func validateUserInfoData(rebuild:Bool)
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func validateUserInfoData(rebuild:Bool)")
        dataGetRunning = true
        validateUserInfoData(rebuild: rebuild)
        {
            self.dataGetRunning = false
        }
    }//end func validateUserInfoData(rebuild:Bool)
    
    
    func pushLoginPopup()
    {
        print("\n", self.classForCoder, Thread.current, "\n\n"+"func pushLoginPopup()")
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
    
    func resetValidationBools()
    {
        self.userValidationHasNotRun = true
        self.techsValidationHasNotRun = true
        self.plansValidationHasNotRun = true
        self.scheduledVisitsValidationHasNotRun = true
    }
}

