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
            HIGH -> Gray out/disable days that are before current date. Converting yyyyMMdd to int and compare size should do it.
        Socketed
            LOW -> Build in socket.io event data handling for all textual data, build on API as well
*/

import UIKit
import SocketIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
    var connectCodeCanRun:Bool = true
    var disconnectCodeCanRun:Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("\n\napplicationWillResignActive\n\n")
        let navController: UINavigationController = window!.rootViewController as! UINavigationController
        let sockWindow: SocketedViewController = navController.viewControllers[navController.viewControllers.count-1] as! SocketedViewController
        if self.disconnectCodeCanRun, sockWindow.socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            sockWindow.socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            sockWindow.socket.disconnect()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\n\napplicationDidEnterBackground\n\n")
        let navController: UINavigationController = window!.rootViewController as! UINavigationController
        let sockWindow: SocketedViewController = navController.viewControllers[navController.viewControllers.count-1] as! SocketedViewController
        if self.disconnectCodeCanRun, sockWindow.socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            sockWindow.socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            sockWindow.socket.disconnect()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("\n\napplicationWillEnterForeground\n\n")
        let navController: UINavigationController = window!.rootViewController as! UINavigationController
        let sockWindow: SocketedViewController = navController.viewControllers[navController.viewControllers.count-1] as! SocketedViewController
        if self.connectCodeCanRun, sockWindow.socket.status != SocketIOStatus.connected
        {
            self.disconnectCodeCanRun = true
            self.connectCodeCanRun = false
            sockWindow.socket.connect()
            DispatchQueue.global(qos: .background).async
            {
                if sockWindow.token == nil, sockWindow.classForCoder != LoginPopupViewController.classForCoder()
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
        print("\n\napplicationDidBecomeActive\n\n")
        let navController: UINavigationController = window!.rootViewController as! UINavigationController
        let sockWindow: SocketedViewController = navController.viewControllers[navController.viewControllers.count-1] as! SocketedViewController
        if self.connectCodeCanRun, sockWindow.socket.status != SocketIOStatus.connected
        {
            self.disconnectCodeCanRun = true
            self.connectCodeCanRun = false
            sockWindow.socket.connect()
        }//end if not connected
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("\n\napplicationWillTerminate\n\n")
        let navController: UINavigationController = window!.rootViewController as! UINavigationController
        let sockWindow: SocketedViewController = navController.viewControllers[navController.viewControllers.count-1] as! SocketedViewController
        if self.disconnectCodeCanRun, sockWindow.socket.status != SocketIOStatus.disconnected
        {
            self.connectCodeCanRun = true
            self.disconnectCodeCanRun = false
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM-dd-yyyy"
            sockWindow.socket.emit("disconnect", with: [dateFormat.string(from:Date())])
            sockWindow.socket.disconnect()
        }
    }
}

