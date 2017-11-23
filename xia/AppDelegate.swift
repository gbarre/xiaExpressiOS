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
        
        // moving the file out of the inbox to your destination URL in your case the documents directory appending the url.lastPathComponent
        let path = "\(documentsDirectory)/importFile.xml"
        let fileManager = FileManager.default
        do {
            let destinationURL = URL(fileURLWithPath: path)
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
            }
            try fileManager.moveItem(at: url, to: destinationURL)
        } catch {
            print(error)
            return false
        }
        
        var errorAtImageImport = true
        var errorAtXMLImport = true
        let now:Int = Int(Date().timeIntervalSince1970)
        
        dbg.pt("Try import file... from \(path)")
        // read file to extract image
        let xml = getXML(path, check: false)
        if (xml["XiaiPad"]["image"].value != "element <image> not found") {
            dbg.pt("Image founded")
            // convert base64 to image
            let imageDataB64 = Data(base64Encoded: xml["XiaiPad"]["image"].value!, options : .ignoreUnknownCharacters)
            let image = UIImage(data: imageDataB64!)
            // store new image to document directory
            let imageData = UIImageJPEGRepresentation(image!, 85)
            do {
                try imageData?.write(to: URL(fileURLWithPath: "\(imagesDirectory)/\(now).jpg"), options: [.atomicWrite])
                dbg.pt("Image imported")
                errorAtImageImport = false
            }
            catch {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // store the xia xml
        if (xml["XiaiPad"]["xia"].value != "element <xia> not found" && !errorAtImageImport) {
            dbg.pt("Try to import xia elements")
            let xmlXIA = AEXMLDocument()
            let _ = xmlXIA.addChild(xml["XiaiPad"]["xia"])
            let xmlString = xmlXIA.xml
            do {
                try xmlString.write(toFile: xmlDirectory + "/\(now).xml", atomically: false, encoding: String.Encoding.utf8)
                errorAtXMLImport = false
                dbg.pt("XML imported")
            }
            catch {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // something were wrong, clean it !
        if errorAtXMLImport {
            do {
                try fileManager.removeItem(atPath: "\(imagesDirectory)/\(now).jpg")
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        else {
            dbg.pt("import done")
        }
        
        return true
    }
}

