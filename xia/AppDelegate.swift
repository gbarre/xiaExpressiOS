//
//  AppDelegate.swift
//  xia
//
//  Created by Guillaume on 26/09/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //dbg.enable = true
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let defaults = UserDefaults.standard
        // update version in settings
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        defaults.set(version, forKey: "version")
        // Empty oembed.plist if useCache is not enable
        let useCache = defaults.bool(forKey: "useCache")
        if (!useCache) {
            let fileManager = FileManager.default
            do {
                let pathToBundleDB = Bundle.main.path(forResource: "oembed", ofType: "plist")!
                try fileManager.removeItem(atPath: dbPath)
                try fileManager.copyItem(atPath: pathToBundleDB, toPath: dbPath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let url = url.standardizedFileURL  // this will strip out the private from your url
        
        // Just move the new file to prepare import
        do {
            let destinationURL = URL(fileURLWithPath: importPath)
            if !FileManager.default.fileExists(atPath: importPath) {
                try FileManager.default.moveItem(at: url, to: destinationURL)
                
            }
        } catch {
            dbg.pt(error.localizedDescription)
            return false
        }
        
        return true
    }
}

