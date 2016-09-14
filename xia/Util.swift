//
//  Util.swift
//  xia4ipad
//
//  Created by Guillaume on 07/12/2015.
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

func buildShape(_ fill: Bool, color: UIColor, tag: Int, points: [Int: UIImageView], parentView: AnyObject, ellipse: Bool = false, locked: Bool = false) {
    var shapeArg: Int = 0
    let shapeTag = tag + 100
    if fill {
        shapeArg = (ellipse) ? 3 : 1
    }
    else {
        shapeArg = (ellipse) ? 2 : 0
    }
    var xMin: CGFloat = UIScreen.main.bounds.width
    var xMax: CGFloat = 0
    var yMin: CGFloat = UIScreen.main.bounds.height
    var yMax: CGFloat = 0
    // Get dimensions of the shape
    for subview in parentView.subviews {
        if subview.tag == tag {
            let xMinSubview = subview.frame.origin.x
            let yMinSubview = subview.frame.origin.y
            let xMaxSubview = subview.frame.origin.x + 10
            let yMaxSubview = subview.frame.origin.y + 10
            if ( xMinSubview < xMin ) {
                xMin = xMinSubview
            }
            if ( yMinSubview < yMin ) {
                yMin = yMinSubview
            }
            if ( xMaxSubview > xMax ) {
                xMax = xMaxSubview
            }
            if ( yMaxSubview > yMax ) {
                yMax = yMaxSubview
            }
        }
    }
    let shapeFrame = CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    
    // Build the shape
    let myView = ShapeView(frame: shapeFrame, shape: shapeArg, points: points, color: color)
    myView.backgroundColor = UIColor(white: 0, alpha: 0)
    myView.tag = shapeTag
    parentView.addSubview(myView)
    
    // Shape is locked ?
    if locked {
        let lock = UIImage(named: "lock")
        let lockView = UIImageView(image: lock!)
        lockView.center = CGPoint(x: shapeFrame.midX, y: shapeFrame.midY)
        lockView.tag = shapeTag
        lockView.layer.zPosition = 105
        lockView.alpha = 0.5
        parentView.addSubview(lockView)
    }
}

func checkXML (_ xml: AEXMLDocument) -> AEXMLDocument {
    for child in xml["xia"].all! {
        // Look for readonly child
        if let readonly = child["readonly"].value {
            if (readonly != "true" && readonly != "false") {
                let _ = xml["xia"].addChild("readonly", value: "false", attributes: ["code" : "1234"])
            }
        }
        // Look for image child (to store image title & description)
        if child["image"].attributes["title"] == nil {
            let _ = xml["xia"].addChild("image", value: "", attributes: ["title" : "", "desctription" : ""])
        }
        // Look for the default show details attributes
        if child["details"].attributes["show"] == nil {
            xml["xia"]["details"].attributes["show"] = "true"
        }
            
    }
    if let xmlDetails = xml["xia"]["details"]["detail"].all {
        for detail in xmlDetails {
            if detail.attributes["locked"] == nil {
                detail.attributes["locked"] = "false"
            }
        }
    }
    
    for element in xmlElements {
        if (xml["xia"][element].value != nil && xml["xia"][element].value! == "element <\(element)> not found") {
            let _ = xml["xia"].addChild(element)
            if (element == "creator" && xml["xia"]["author"].value != nil) {
                xml["xia"][element].value = xml["xia"]["author"].value!
                if xml["xia"]["author"].value! != "element <author> not found" {
                    xml["xia"]["author"].removeFromParent()
                }
            }            
        }
    }
    
    return xml
}

func convertStringToCGFloat(_ txt: String) -> CGFloat {
    let cgFloat: CGFloat?
    if let double = Double("\(txt)") {
        cgFloat = CGFloat(double)
    }
    else {
        let d = txt.replacingOccurrences(of: ",", with: ".")
        cgFloat = (Double("\(d)") == nil) ? -12345.6789 : CGFloat(Double("\(d)")!)
    }
    return cgFloat!
}

/*func delay(delay:Double, closure:()->()) {
    DispatchQueue.main.after(
        when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), block: closure)
}*/

func getCenter() -> CGPoint{
    var point = CGPoint(x: 0, y: 0)
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    if ( screenHeight == 1024 && screenWidth != 1366 ) { // device is portrait and not iPad Pro
        point.x = (screenWidth - 540) / 2 + 100
        point.y = (screenHeight - 620) / 2 + 100
    }
    else {
        point.x = (screenWidth - 800) / 2 + 100
        point.y = (screenHeight - 600) / 2 + 100
    }
    return point
}

func getXML(_ path: String, check: Bool = true) -> AEXMLDocument {
    let data = try? Data(contentsOf: URL(fileURLWithPath: path))
    var xml: AEXMLDocument!
    do {
        try xml = AEXMLDocument(xmlData: data!)
    }
    catch {
        dbg.pt("\(error)" as AnyObject)
    }
    return (check) ? checkXML(xml) : xml
}

func pointInPolygon(_ points: [Int: UIImageView], touchPoint: CGPoint) -> Bool {
    // translate from C : http://alienryderflex.com/polygon/
    let polyCorners = points.count
    var j = polyCorners - 1
    var oddNodes:Bool = false
    
    for i in 0 ..< polyCorners {
        if ( (points[i]!.center.y < touchPoint.y && points[j]!.center.y >= touchPoint.y
            || points[j]!.center.y < touchPoint.y && points[i]!.center.y >= touchPoint.y)
            && (points[i]!.center.x <= touchPoint.x || points[j]!.center.x <= touchPoint.x) ) {
                if ( points[i]!.center.x + (touchPoint.y - points[i]!.center.y) / (points[j]!.center.y - points[i]!.center.y) * (points[j]!.center.x - points[i]!.center.x) < touchPoint.x ) {
                    oddNodes = !oddNodes
                }
        }
        j=i
    }
    
    return oddNodes
}

func writeXML(_ xml: AEXMLDocument, path: String) -> Bool {
    var error = true
    do {
        try xml.xmlString.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        error = false
    }
    catch {
        dbg.pt("\(error)" as AnyObject)
    }
    return error
}


