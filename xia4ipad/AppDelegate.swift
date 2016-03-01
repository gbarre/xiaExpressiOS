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
        var errorAtSVGImport = true
        let now:Int = Int(NSDate().timeIntervalSince1970)
        let documentRoot = NSHomeDirectory() + "/Documents"
        
        if url != nil {
            // read file to extract image
            var path = url!.path!
            path = path.stringByReplacingOccurrencesOfString("/private", withString: "")
            let xml = getXML(path, check: false)
            let ext = path.substringWithRange(Range<String.Index>(start: path.endIndex.advancedBy(-3), end: path.endIndex.advancedBy(0)))
            switch (ext) {
            case "xml": // The document was created by a tablet
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
                break
            case "svg":
                if xml["svg"]["image"].attributes["xlink:href"] != nil {
                    // convert base64 to image
                    let b64Chain = xml["svg"]["image"].attributes["xlink:href"]!.stringByReplacingOccurrencesOfString("data:image/jpeg;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/png;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/jpg;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/gif;base64,", withString: "")
                    let imageDataB64 = NSData(base64EncodedString: b64Chain, options : .IgnoreUnknownCharacters)
                    let image = UIImage(data: imageDataB64!)
                    // store new image to document directory
                    let imageData = UIImageJPEGRepresentation(image!, 85)
                    if ((imageData?.writeToFile("\(documentRoot)/\(now).jpg", atomically: true)) != nil) {
                        errorAtImageImport = false
                    }
                }
                
                // build the xia xml
                if !errorAtImageImport {
                    let xmlXIA = AEXMLDocument()
                    xmlXIA.addChild(name: "xia")
                    let metas = ["title" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:title"]),
                        "description" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:description"]),
                        "creator" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:creator"]["cc:Agent"]["dc:title"]),
                        "rights" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:rights"]["cc:Agent"]["dc:title"]),
                        "date" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:date"]),
                        "publisher" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:publisher"]["cc:Agent"]["dc:title"]),
                        "identifier" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:identifier"]),
                        "source" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:source"]),
                        "relation" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:relation"]),
                        "language" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:language"]),
                        "keywords" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:subject"]["rdf:Bag"]["rdf:li"]),
                        "coverage" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:coverage"]),
                        "contributors" : getElementValue(xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:contributor"]["cc:Agent"]["dc:title"])
                    ]
                    
                    for (thisName, thisValue) in metas {
                        xmlXIA["xia"].addChild(name: thisName, value: thisValue, attributes: nil)
                    }
                    xmlXIA["xia"].addChild(name: "readonly", value: "false", attributes: ["code" : "12343"])
                    let license = (xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["cc:license"].attributes["rdf:resource"] != nil) ? xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["cc:license"].attributes["rdf:resource"]! : ""
                    switch license {
                    case "http://creativecommons.org/licenses/by/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution - CC-BY", attributes: nil)
                        break
                    case "http://creativecommons.org/licenses/by-sa/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-ShareALike - CC-BY-SA", attributes: nil)
                        break
                    case "http://creativecommons.org/licenses/by-nd/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NoDerivs - CC-BY-ND", attributes: nil)
                        break
                    case "http://creativecommons.org/licenses/by-nc/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial - CC-BY-NC", attributes: nil)
                        break
                    case "http://creativecommons.org/licenses/by-nc-sa/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial-ShareALike - CC-BY-NC-SA", attributes: nil)
                        break
                    case "http://creativecommons.org/licenses/by-nc-nd/3.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial-NoDerivs - CC-BY-NC-ND", attributes: nil)
                        break
                    case "http://creativecommons.org/publicdomain/zero/1.0/":
                        xmlXIA["xia"].addChild(name: "license", value: "CC0 Public Domain Dedication", attributes: nil)
                        break
                    case "http://artlibre.org/licence/lal":
                        xmlXIA["xia"].addChild(name: "license", value: "Free Art", attributes: nil)
                        break
                    case "http://scripts.sil.org/OFL":
                        xmlXIA["xia"].addChild(name: "license", value: "Open Font License", attributes: nil)
                        break
                    default:
                        xmlXIA["xia"].addChild(name: "license", value: "Other", attributes: nil)
                        break
                    }
                    
                    // Create details
                    xmlXIA["xia"].addChild(name: "details")
                    var currentDetailTag = 99
                    
                    // Get rectangles
                    if let rectangles = xml["svg"]["rect"].all {
                        for rect in rectangles {
                            currentDetailTag++
                            let origin = CGPointMake(convertStringToCGFloat(rect.attributes["x"]!), convertStringToCGFloat(rect.attributes["y"]!))
                            let width = convertStringToCGFloat(rect.attributes["width"]!)
                            let heigt = convertStringToCGFloat(rect.attributes["height"]!)
                            
                            let thisPath = "\(origin.x);\(origin.y) \(origin.x + width);\(origin.y) \(origin.x + width);\(origin.y + heigt) \(origin.x);\(origin.y + heigt)"
                            let detailTitle = (rect["title"].value != nil) ? rect["title"].value! : ""
                            let detailDescription = (rect["desc"].value != nil) ? rect["desc"].value! : ""
                            
                            let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "false", "title" : detailTitle, "subtitle" : "", "path" : thisPath, "constraint" : "rectangle", "locked" : "false"]
                            
                            xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
                        }
                    }
                    
                    // Get ellipse
                    if let ellipses = xml["svg"]["ellipse"].all {
                        for ellipse in ellipses {
                            currentDetailTag++
                            let center = CGPointMake(convertStringToCGFloat(ellipse.attributes["cx"]!), convertStringToCGFloat(ellipse.attributes["cy"]!))
                            let radiusX = convertStringToCGFloat(ellipse.attributes["rx"]!)
                            let radiusY = convertStringToCGFloat(ellipse.attributes["ry"]!)
                            
                            let thisPath = "\(center.x);\(center.y - radiusY) \(center.x + radiusX);\(center.y) \(center.x);\(center.y + radiusY) \(center.x - radiusX);\(center.y)"
                            let detailTitle = (ellipse["title"].value != nil) ? ellipse["title"].value! : ""
                            let detailDescription = (ellipse["desc"].value != nil) ? ellipse["desc"].value! : ""
                            
                            let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "false", "title" : detailTitle, "subtitle" : "", "path" : thisPath, "constraint" : "ellipse", "locked" : "false"]
                            
                            xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
                        }
                    }
                    
                    // Get polygons
                    if let polygons = xml["svg"]["path"].all {
                        for polygon in polygons {
                            currentDetailTag++
                            var thisPath = "0;0"
                            let svgPath = polygon.attributes["d"]!
                            let firstLetter: String = svgPath.substringWithRange(svgPath.startIndex..<svgPath.startIndex.successor())
                            if firstLetter == "M" {
                                thisPath = svgPath.stringByReplacingOccurrencesOfString("M ", withString: "").stringByReplacingOccurrencesOfString(" Z", withString: "").stringByReplacingOccurrencesOfString(",", withString: ";")
                            }
                            else {
                                thisPath = ""
                                let path = svgPath.stringByReplacingOccurrencesOfString("m ", withString: "").stringByReplacingOccurrencesOfString(" z", withString: "").stringByReplacingOccurrencesOfString(",", withString: ";")
                                let pointsArray = path.characters.split{$0 == " "}.map(String.init)
                                var previousPoint = CGPointMake(0.0, 0.0)
                                for point in pointsArray {
                                    let coords = point.characters.split{$0 == ";"}.map(String.init)
                                    let x = convertStringToCGFloat(coords[0])
                                    let y = convertStringToCGFloat(coords[1])
                                    thisPath += "\(previousPoint.x + x);\(previousPoint.y + y) "
                                    previousPoint = CGPointMake(previousPoint.x + x, previousPoint.y + y)
                                }
                                thisPath = thisPath.substringWithRange(Range<String.Index>(start: thisPath.startIndex.advancedBy(0), end: thisPath.endIndex.advancedBy(-1)))
                            }
                            
                            let detailTitle = (polygon["title"].value != nil) ? polygon["title"].value! : ""
                            let detailDescription = (polygon["desc"].value != nil) ? polygon["desc"].value! : ""
                            
                            let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "false", "title" : detailTitle, "subtitle" : "", "path" : thisPath, "constraint" : "polygon", "locked" : "false"]
                            
                            xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
                        }
                    }
                    
                    
                    // Store the xia xml
                    let xmlString = xmlXIA.xmlString
                    do {
                        try xmlString.writeToFile(documentRoot + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
                        errorAtSVGImport = false
                    }
                    catch {
                        dbg.pt("\(error)")
                    }
                }
                break
            default:
                break
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
        if errorAtXMLImport && errorAtSVGImport {
            do {
                try fileManager.removeItemAtPath("\(documentRoot)/\(now).jpg")
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        
        return true
    }
    
    func getElementValue(element: AEXMLElement) -> String {
        if (element.value != nil && element.value! != "element <\(element)> not found") {
            return element.value!
        }
        else {
            return ""
        }
    }

}

