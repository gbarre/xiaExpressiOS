//
//  AppDelegate.swift
//  xia4ipad
//
//  Created by Guillaume on 26/09/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dbg = debug(enable: true)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let url = url.standardizedURL
        var errorAtImageImport = true
        var errorAtXMLImport = true
        let now:Int = Int(NSDate().timeIntervalSince1970)
        let documentRoot = NSHomeDirectory() + "/Documents"
        
        if url != nil {
            // read file to extract image
            var path = url!.path!
            path = path.stringByReplacingOccurrencesOfString("/private", withString: "")
            let xml = getXML(path)
            if (xml["XiaiPad"]["image"].value != "element <image> not found") {
                // convert base64 to image
                let imageDataB64 = NSData(base64EncodedString: xml["XiaiPad"]["image"].value!, options : .IgnoreUnknownCharacters)
                let image = UIImage(data: imageDataB64!)
                // store new image to document directory
                let imageData = UIImageJPEGRepresentation(image!, 85)
                if ((imageData?.writeToFile("\(documentRoot)/\(now).jpg", atomically: true)) != nil) {
                    errorAtImageImport = false
                }
            }
            
            // store the xia xml
            if (xml["XiaiPad"]["xia"].value != "element <xia> not found" && !errorAtImageImport) {
                let xmlXIA = AEXMLDocument()
                xmlXIA.addChild(xml["XiaiPad"]["xia"])
                let xmlString = xmlXIA.xmlString
                do {
                    try xmlString.writeToFile(documentRoot + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
                    errorAtXMLImport = false
                }
                catch {
                    dbg.pt("\(error)")
                }
            }
        }
        // purge Inbox
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath("\(documentRoot)/Inbox")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(documentRoot)/Inbox/\(file)"
                try fileManager.removeItemAtPath(filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // something was wrong
        if errorAtXMLImport {
            do {
                try fileManager.removeItemAtPath("\(documentRoot)/\(now).jpg")
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        
        return true
    }

}

