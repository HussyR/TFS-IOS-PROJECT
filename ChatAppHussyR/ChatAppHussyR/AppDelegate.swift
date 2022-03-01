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
        window = UIWindow()
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
  
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

    }
    
    func applicationWillTerminate(_ application: UIApplication) {

    }
    
}

