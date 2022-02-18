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
        print("Application moved from \"Not running\" to \"Inactive\":\(#function)")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application moved from \"Inactive\" to \"Active\":\(#function)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("Application moved from \"Active\" to \"Inaclive\":\(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application moved from \"Inactive\" to \"Background\":\(#function)")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Application moved from \"Background\" to \"Inactive\":\(#function)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Application moved from \"Background\" to \"Not Running\":\(#function)")
    }
    
}

