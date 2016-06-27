//
//  AppDelegate.swift
//  xia4ipad
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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // purge Inbox
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath("\(documentsDirectory)/Inbox")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(documentsDirectory)/Inbox/\(file)"
                try fileManager.removeItemAtPath(filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
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
        let errorAtSVGImport = true
        let now:Int = Int(NSDate().timeIntervalSince1970)
        
        dbg.pt("Try import file... from \(url)")
        // read file to extract image
        var path = url!.path!
        dbg.pt("path : \(path)")
        dbg.ptLine()
        path = path.stringByReplacingOccurrencesOfString("/private", withString: "")
        dbg.pt("path : \(path)")
        let xml = getXML(path, check: false)
        let ext = path.substringWithRange(path.endIndex.advancedBy(-3)..<path.endIndex.advancedBy(0))
        dbg.pt("File type is : \(ext)")
        switch (ext) {
        case "xml": // The document was created by a tablet
            if (xml["XiaiPad"]["image"].value != "element <image> not found") {
                dbg.pt("Image founded")
                // convert base64 to image
                let imageDataB64 = NSData(base64EncodedString: xml["XiaiPad"]["image"].value!, options : .IgnoreUnknownCharacters)
                let image = UIImage(data: imageDataB64!)
                // store new image to document directory
                let imageData = UIImageJPEGRepresentation(image!, 85)
                if ((imageData?.writeToFile("\(documentsDirectory)/\(now).jpg", atomically: true)) != nil) {
                    dbg.pt("Image imported")
                    errorAtImageImport = false
                }
            }
            
            // store the xia xml
            if (xml["XiaiPad"]["xia"].value != "element <xia> not found" && !errorAtImageImport) {
                dbg.pt("Try to import xia elements")
                let xmlXIA = AEXMLDocument()
                let _ = xmlXIA.addChild(xml["XiaiPad"]["xia"])
                let xmlString = xmlXIA.xmlString
                do {
                    try xmlString.writeToFile(documentsDirectory + "/\(now).xml", atomically: false, encoding: NSUTF8StringEncoding)
                    errorAtXMLImport = false
                    dbg.pt("XML imported")
                }
                catch {
                    dbg.pt("\(error)")
                }
            }
            break
            /*case "svg":
             let (b64Chain, group, imgWidth, imgTitle, imgDesc) = getBackgroundImage(xml)
             var image = UIImage()
             if b64Chain != "" {
             dbg.pt("Image founded")
             //let imageDataB64 = Data(base64Encoded: b64Chain)
             let imageDataB64 = NSData(base64Encoded: b64Chain, options : .ignoreUnknownCharacters)
             image = UIImage(data: imageDataB64! as Data)!
             // store new image to document directory
             let imageData = UIImageJPEGRepresentation(image, 85)
             if (((try? imageData?.write(to: URL(fileURLWithPath: "\(documentsDirectory)/\(now).jpg"), options: [.dataWritingAtomic])) != nil)) {
             errorAtImageImport = false
             dbg.pt("Image imported")
             }
             }
             
             // build the xia xml
             if !errorAtImageImport {
             let xmlXIA = AEXMLDocument()
             let _ = xmlXIA.addChild(name: "xia")
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
             let _ = xmlXIA["xia"].addChild(name: thisName, value: thisValue, attributes: nil)
             }
             let _ = xmlXIA["xia"].addChild(name: "readonly", value: "false", attributes: ["code" : "1234"])
             let _ = xmlXIA["xia"].addChild(name: "image", value: "", attributes: ["title" : imgTitle, "description" : imgDesc])
             let license = (xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["cc:license"].attributes["rdf:resource"] != nil) ? xml["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["cc:license"].attributes["rdf:resource"]! : ""
             switch license {
             case "http://creativecommons.org/licenses/by/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution - CC-BY", attributes: nil)
             break
             case "http://creativecommons.org/licenses/by-sa/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-ShareALike - CC-BY-SA", attributes: nil)
             break
             case "http://creativecommons.org/licenses/by-nd/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NoDerivs - CC-BY-ND", attributes: nil)
             break
             case "http://creativecommons.org/licenses/by-nc/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial - CC-BY-NC", attributes: nil)
             break
             case "http://creativecommons.org/licenses/by-nc-sa/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial-ShareALike - CC-BY-NC-SA", attributes: nil)
             break
             case "http://creativecommons.org/licenses/by-nc-nd/3.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC Attribution-NonCommercial-NoDerivs - CC-BY-NC-ND", attributes: nil)
             break
             case "http://creativecommons.org/publicdomain/zero/1.0/":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "CC0 Public Domain Dedication", attributes: nil)
             break
             case "http://artlibre.org/licence/lal":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "Free Art", attributes: nil)
             break
             case "http://scripts.sil.org/OFL":
             let _ = xmlXIA["xia"].addChild(name: "license", value: "Open Font License", attributes: nil)
             break
             default:
             let _ = xmlXIA["xia"].addChild(name: "license", value: "Other", attributes: nil)
             break
             }
             
             // Create details
             let _ = xmlXIA["xia"].addChild(name: "details", value: "", attributes: ["show" : "true"])
             var currentDetailTag = 99
             
             let svgRoot = (group) ? xml["svg"]["g"] : xml["svg"]
             let scale = image.size.width / imgWidth
             
             // Get rectangles
             if let rectangles = svgRoot["rect"].all {
             for rect in rectangles {
             currentDetailTag += 1
             let origin = CGPoint(x: convertStringToCGFloat(rect.attributes["x"]!) * scale, y: convertStringToCGFloat(rect.attributes["y"]!) * scale)
             let width = convertStringToCGFloat(rect.attributes["width"]!) * scale
             let heigt = convertStringToCGFloat(rect.attributes["height"]!) * scale
             
             let thisPath = "\(origin.x);\(origin.y) \(origin.x + width);\(origin.y) \(origin.x + width);\(origin.y + heigt) \(origin.x);\(origin.y + heigt)"
             let detailTitle = (rect["title"].value != nil && rect["title"].value! != "element <title> not found") ? rect["title"].value! : ""
             let detailDescription = (rect["desc"].value != nil && rect["desc"].value! != "element <desc> not found") ? rect["desc"].value! : ""
             
             let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "true", "title" : detailTitle, "path" : thisPath, "constraint" : constraintRectangle, "locked" : "false"]
             
             let _ = xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
             }
             }
             
             // Get ellipse
             if let ellipses = svgRoot["ellipse"].all {
             for ellipse in ellipses {
             currentDetailTag += 1
             let center = CGPoint(x: convertStringToCGFloat(ellipse.attributes["cx"]!) * scale, y: convertStringToCGFloat(ellipse.attributes["cy"]!) * scale)
             let radiusX = convertStringToCGFloat(ellipse.attributes["rx"]!) * scale
             let radiusY = convertStringToCGFloat(ellipse.attributes["ry"]!) * scale
             
             let thisPath = "\(center.x);\(center.y - radiusY) \(center.x + radiusX);\(center.y) \(center.x);\(center.y + radiusY) \(center.x - radiusX);\(center.y)"
             let detailTitle = (ellipse["title"].value != nil && ellipse["title"].value! != "element <title> not found") ? ellipse["title"].value! : ""
             let detailDescription = (ellipse["desc"].value != nil && ellipse["desc"].value! != "element <desc> not found") ? ellipse["desc"].value! : ""
             
             let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "true", "title" : detailTitle, "path" : thisPath, "constraint" : constraintEllipse, "locked" : "false"]
             
             let _ = xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
             }
             }
             
             // Get polygons
             if let polygons = svgRoot["path"].all {
             for polygon in polygons {
             currentDetailTag += 1
             var thisPath = ""
             let svgPath = polygon.attributes["d"]!
             
             var command: String = ""
             var previousPoint = CGPoint(x: 0.0, y: 0.0)
             var prepreviousPoint = CGPoint(x: 0.0, y: 0.0)
             var startPoint = CGPoint(x: 0.0, y: 0.0)
             var controlPoint1 = CGPoint(x: 3.14, y: 42)
             var controlPoint2 = CGPoint(x: 3.14, y: 42)
             var indexPoints: Int = 1
             
             let path = svgPath.stringByReplacingOccurrencesOfString(",", with: ";")
             let pointsArray = path.characters.split{$0 == " "}.map(String.init)
             for point in pointsArray {
             let coords = point.characters.split{$0 == ";"}.map(String.init)
             let x: CGFloat = convertStringToCGFloat(coords[0]) * scale
             if x == -12345.6789 * scale {
             command = coords[0]
             continue
             }
             let y: CGFloat = (coords.count == 2) ? convertStringToCGFloat(coords[1]) * scale : x
             // get the point
             switch command {
             case "M": // move to absolute (x;y)
             thisPath = (thisPath == "") ? "\(x);\(y) " : "\(thisPath) \(x);\(y) "
             previousPoint = CGPoint(x: x, y: y)
             command = "L"
             break
             case "m": // move to relative (x;y)
             thisPath = (thisPath == "") ? "\(x);\(y) " : "\(thisPath) "
             previousPoint = (thisPath == "") ? CGPoint(x: x, y: y) : CGPoint(x: previousPoint.x + x, y: previousPoint.y + y)
             command = "l"
             break
             case "Z", "z": // close path (do nothing)
             break
             case "L": // line to absolute (x;y)
             thisPath += "\(x);\(y) "
             previousPoint = CGPoint(x: x, y: y)
             break
             case "l": // line to relative (x;y)
             thisPath += "\(previousPoint.x + x);\(previousPoint.y + y) "
             previousPoint = CGPoint(x: previousPoint.x + x, y: previousPoint.y + y)
             break
             case "H": // horizontal line to absolute (x)
             thisPath += "\(x);\(previousPoint.y) "
             previousPoint = CGPoint(x: x, y: previousPoint.y)
             break
             case "h": // horizontal line to relative (x)
             thisPath += "\(previousPoint.x + x);\(previousPoint.y) "
             previousPoint = CGPoint(x: previousPoint.x + x, y: previousPoint.y)
             break
             case "V": // vertical line to absolute (y)
             thisPath += "\(previousPoint.x);\(y) "
             previousPoint = CGPoint(x: previousPoint.x, y: y)
             break
             case "v": // vertical line to absolute (y)
             thisPath += "\(previousPoint.x);\(previousPoint.y + y) "
             previousPoint = CGPoint(x: previousPoint.x, y: previousPoint.y + y)
             break
             case "C": // curve to absolute (x1;y1 x2;y2 x;y) (2 controls points)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: x, y: y)
             indexPoints += 1
             break
             case 2:
             controlPoint2 = CGPoint(x: x, y: y)
             prepreviousPoint = controlPoint2
             indexPoints += 1
             break
             case 3:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + controlPoint1.y + controlPoint2.y)/3)
             let point2 = CGPoint(x: (x + controlPoint1.x + controlPoint2.x)/3, y: (y + controlPoint1.y + controlPoint2.y)/3)
             thisPath += "\(point1.x);\(point1.y) \(point2.x);\(point2.y) \(x);\(y) "
             indexPoints = 1
             previousPoint = CGPoint(x: x, y: y)
             break
             default:
             break
             }
             break
             case "c": // curve to relative (x1;y1 x2;y2 x;y) (2 controls points)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             indexPoints += 1
             break
             case 2:
             controlPoint2 = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             prepreviousPoint = controlPoint2
             indexPoints += 1
             break
             case 3:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + controlPoint1.y + controlPoint2.y)/3)
             let point2 = CGPoint(x: (startPoint.x + x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + y + controlPoint1.y + controlPoint2.y)/3)
             thisPath += "\(point1.x);\(point1.y) \(point2.x);\(point2.y) \(startPoint.x + x);\(startPoint.y + y) "
             indexPoints = 1
             previousPoint = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             break
             default:
             break
             }
             break
             case "S": // shorthand/smooth curve to absolute (x2;y2 x;y)
             // (The first control point is assumed to be the reflection of the second control point on the previous command relative to the current point)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: 2 * previousPoint.x - prepreviousPoint.x, y: 2 * previousPoint.y - prepreviousPoint.y)
             indexPoints += 1
             break
             case 2:
             controlPoint2 = CGPoint(x: x, y: y)
             prepreviousPoint = controlPoint2
             indexPoints += 1
             break
             case 3:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + controlPoint1.y + controlPoint2.y)/3)
             let point2 = CGPoint(x: (x + controlPoint1.x + controlPoint2.x)/3, y: (y + controlPoint1.y + controlPoint2.y)/3)
             thisPath += "\(point1.x);\(point1.y) \(point2.x);\(point2.y) \(x);\(y) "
             indexPoints = 1
             previousPoint = CGPoint(x: x, y: y)
             break
             default:
             break
             }
             break
             case "s": // shorthand/smooth curve to relative (x2;y2 x;y)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: 2 * startPoint.x - prepreviousPoint.x, y: 2 * startPoint.y - prepreviousPoint.y)
             indexPoints += 1
             break
             case 2:
             controlPoint2 = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             prepreviousPoint = controlPoint2
             indexPoints += 1
             break
             case 3:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + controlPoint1.y + controlPoint2.y)/3)
             let point2 = CGPoint(x: (startPoint.x + x + controlPoint1.x + controlPoint2.x)/3, y: (startPoint.y + y + controlPoint1.y + controlPoint2.y)/3)
             thisPath += "\(point1.x);\(point1.y) \(point2.x);\(point2.y) \(startPoint.x + x);\(startPoint.y + y) "
             indexPoints = 1
             previousPoint = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             break
             default:
             break
             }
             break
             case "Q": // quadratic Bézier curve to absolute (x1;y1 x;y)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: x, y: y)
             prepreviousPoint = controlPoint1
             indexPoints += 1
             break
             case 2:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + x)/3, y: (startPoint.y + controlPoint1.y + y)/3)
             thisPath += "\(point1.x);\(point1.y) \(x);\(y) "
             indexPoints = 1
             previousPoint = CGPoint(x: x, y: y)
             break
             default:
             break
             }
             break
             case "q": // quadratic Bézier curve to relative (x1;y1 x;y)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             prepreviousPoint = controlPoint1
             indexPoints += 1
             break
             case 2:
             let point1 = CGPoint(x: (2 * startPoint.x + controlPoint1.x + x)/3, y: (2 * startPoint.y + controlPoint1.y + y)/3)
             thisPath += "\(point1.x);\(point1.y) \(startPoint.x + x);\(startPoint.y + y) "
             indexPoints = 1
             previousPoint = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             break
             default:
             break
             }
             break
             case "T": // shorthand/smooth quadratic Bézier curve to absolute (x;y)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: 2 * previousPoint.x - prepreviousPoint.x, y: 2 * previousPoint.y - prepreviousPoint.y)
             prepreviousPoint = controlPoint1
             indexPoints += 1
             break
             case 2:
             let point1 = CGPoint(x: (startPoint.x + controlPoint1.x + x)/3, y: (startPoint.y + controlPoint1.y + y)/3)
             thisPath += "\(point1.x);\(point1.y) \(x);\(y) "
             indexPoints = 1
             previousPoint = CGPoint(x: x, y: y)
             break
             default:
             break
             }
             break
             case "t": // shorthand/smooth quadratic Bézier curve to relative (x;y)
             switch indexPoints {
             case 1:
             startPoint = previousPoint
             controlPoint1 = CGPoint(x: 2 * startPoint.x - prepreviousPoint.x, y: 2 * startPoint.y - prepreviousPoint.y)
             prepreviousPoint = controlPoint1
             indexPoints += 1
             break
             case 3:
             let point1 = CGPoint(x: (2 * startPoint.x + controlPoint1.x + x)/3, y: (2 * startPoint.y + controlPoint1.y + y)/3)
             thisPath += "\(point1.x);\(point1.y) \(startPoint.x + x);\(startPoint.y + y) "
             indexPoints = 1
             previousPoint = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
             break
             default:
             break
             }
             break
             case "A": // elliptical arc absolute (rx ry x-axis-rotation large-arc-flag sweep-flag x y)
             break
             case "a": // elliptical arc relative (rx ry x-axis-rotation large-arc-flag sweep-flag x y)
             break
             default:
             break
             }
             }
             
             let detailTitle = (polygon["title"].value != nil && polygon["title"].value! != "element <title> not found") ? polygon["title"].value! : ""
             let detailDescription = (polygon["desc"].value != nil && polygon["desc"].value! != "element <desc> not found") ? polygon["desc"].value! : ""
             
             let attributes = ["tag" : "\(currentDetailTag)", "zoom" : "true", "title" : detailTitle, "path" : thisPath, "constraint" : constraintPolygon, "locked" : "false"]
             
             let _ = xmlXIA["xia"]["details"].addChild(name: "detail", value: detailDescription, attributes: attributes)
             }
             }
             
             
             // Store the xia xml
             let xmlString = xmlXIA.xmlString
             do {
             try xmlString.write(toFile: documentsDirectory + "/\(now).xml", atomically: false, encoding: String.Encoding.utf8)
             errorAtSVGImport = false
             }
             catch {
             dbg.pt("\(error)")
             }
             }
             break*/
        default:
            break
        }
        // purge Inbox
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.enumeratorAtPath("\(documentsDirectory)/Inbox")
        while let fileObject = files?.nextObject() {
            let file = fileObject as! String
            do {
                let filePath = "\(documentsDirectory)/Inbox/\(file)"
                try fileManager.removeItemAtPath(filePath)
            }
            catch let error as NSError {
                dbg.pt(error.localizedDescription)
            }
        }
        
        // something was wrong
        if errorAtXMLImport && errorAtSVGImport {
            do {
                try fileManager.removeItemAtPath("\(documentsDirectory)/\(now).jpg")
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
    
    func getElementValue(element: AEXMLElement) -> String {
        if (element.value != nil && element.value! != "element <\(element)> not found" && element.value! != "element &lt;\(element)&gt; not found") {
            dbg.pt(element.value!)
            return element.value!
        }
        else {
            return ""
        }
    }
    
    func getBackgroundImage(xml: AEXMLDocument) -> (String, Bool, CGFloat, String, String) {
        var b64img = ""
        var group = false
        var imgWidth:CGFloat = 1024.0
        var title: String = ""
        var desc: String = ""
        if xml["svg"]["image"].attributes["xlink:href"] != nil {
            b64img = xml["svg"]["image"].attributes["xlink:href"]!
            imgWidth = convertStringToCGFloat(xml["svg"]["image"].attributes["width"]!)
            title = (xml["svg"]["image"]["title"].value == "element &lt;title&gt; not found") ? "" : xml["svg"]["image"]["title"].value!
            desc = (xml["svg"]["image"]["desc"].value == "element &lt;desc&gt; not found") ? "" : xml["svg"]["image"]["desc"].value!
        }
        else if xml["svg"]["g"]["image"].attributes["xlink:href"] != nil {
            b64img = xml["svg"]["g"]["image"].attributes["xlink:href"]!
            group = true
            imgWidth = convertStringToCGFloat(xml["svg"]["g"]["image"].attributes["width"]!)
            title = (xml["svg"]["g"]["image"]["title"].value == "element &lt;title&gt; not found") ? "" : xml["svg"]["g"]["image"]["title"].value!
            desc = (xml["svg"]["g"]["desc"]["title"].value == "element &lt;title&gt; not found") ? "" : xml["svg"]["g"]["image"]["desc"].value!
        }
        
        return (b64img.stringByReplacingOccurrencesOfString("data:image/jpeg;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/png;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/jpg;base64,", withString: "").stringByReplacingOccurrencesOfString("data:image/gif;base64,", withString: ""), group, imgWidth, title, desc)
    }
    
}

