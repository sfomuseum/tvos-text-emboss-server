//
//  AppDelegate.swift
//  TextEmbossServer
//
//  Created by asc on 9/19/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        registerSettingsBundle()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    // I wish something like were just built in to iOS...
    // https://github.com/Abstract45/SettingsExample
    
    private func registerSettingsBundle() {
        
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension:"bundle") else {
            NSLog("Could not find Settings.bundle")
            return;
        }
        
        guard let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            NSLog("Could not find Root.plist in settings bundle")
            return
        }
        
        guard let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]] else {
            NSLog("Root.plist has invalid format")
            return
        }
        
        var defaultsToRegister = [String: AnyObject]()
        for p in preferences {
            if let k = p["Key"] as? String, let v = p["DefaultValue"] {
                // NSLog("%@", "registering \(v) for key \(k)")
                defaultsToRegister[k] = v
            }
        }
        
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}

