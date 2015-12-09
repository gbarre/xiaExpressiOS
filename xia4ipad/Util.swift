//
//  Util.swift
//  xia4ipad
//
//  Created by Guillaume on 07/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit



func buildShape(fill: Bool, color: UIColor, tag: Int, points: Array<AnyObject>, parentView: AnyObject) {
    var shapeArg: Int = 0
    let shapeTag = tag + 100
    switch fill {
    case true:
        shapeArg = 1
    default:
        shapeArg = 0
    }
    var xMin: CGFloat = UIScreen.mainScreen().bounds.width
    var xMax: CGFloat = 0
    var yMin: CGFloat = UIScreen.mainScreen().bounds.height
    var yMax: CGFloat = 0
    // Get dimensions of the shape
    for subview in parentView.subviews {
        if subview.tag == tag {
            let xMinSubview = subview.frame.origin.x
            let yMinSubview = subview.frame.origin.y
            let xMaxSubview = subview.frame.origin.x + 29
            let yMaxSubview = subview.frame.origin.y + 29
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
    let shapeWidth = xMax - xMin
    let shapeHeight = yMax - yMin
    
    // Build the shape
    let myView = ShapeView(frame: CGRectMake(xMin, yMin, shapeWidth, shapeHeight), shape: shapeArg, points: points, color: color)
    myView.backgroundColor = UIColor(white: 0, alpha: 0)
    myView.tag = shapeTag
    parentView.addSubview(myView)
}

func getXML(path: String) -> AEXMLDocument {
    let data = NSData(contentsOfFile: path)
    var xml: AEXMLDocument!
    do {
        try xml = AEXMLDocument(xmlData: data!)
    }
    catch {
        print("\(error)")
    }
    return xml
}

func pointInPolygon(points: AnyObject, touchPoint: CGPoint) -> Bool {
    // translate from C : http://alienryderflex.com/polygon/
    let polyCorners = points.count
    var j = polyCorners - 1
    var oddNodes:Bool = false
    
    for var i=0; i<polyCorners; i++ {
        if ( (points[i].center.y < touchPoint.y && points[j].center.y >= touchPoint.y
            || points[j].center.y < touchPoint.y && points[i].center.y >= touchPoint.y)
            && (points[i].center.x <= touchPoint.x || points[j].center.x <= touchPoint.x) ) {
                if ( points[i].center.x + (touchPoint.y - points[i].center.y) / (points[j].center.y - points[i].center.y) * (points[j].center.x - points[i].center.x) < touchPoint.x ) {
                    oddNodes = !oddNodes
                }
        }
        j=i
    }
    
    return oddNodes
}

func writeXML(xml: AEXMLDocument, path: String) -> Bool {
    var error = true
    do {
        try xml.xmlString.writeToFile("\(path).xml", atomically: true, encoding: NSUTF8StringEncoding)
        error = false
    }
    catch {
        print("\(error)")
    }
    return error
}


