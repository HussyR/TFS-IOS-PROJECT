//
//  AppDelegate.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if LOG
        print("Application moved from \"Not running\" to \"Inactive\":\(#function)")
        #endif
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        #if LOG
        print("Application moved from \"Inactive\" to \"Active\":\(#function)")
        #endif
    }

    func applicationWillResignActive(_ application: UIApplication) {
        #if LOG
        print("Application moved from \"Active\" to \"Inaclive\":\(#function)")
        #endif
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        #if LOG
        print("Application moved from \"Inactive\" to \"Background\":\(#function)")
        #endif
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        #if LOG
        print("Application moved from \"Background\" to \"Inactive\":\(#function)")
        #endif
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        #if LOG
        print("Application moved from \"Background\" to \"Not Running\":\(#function)")
        #endif
    }
    
}

