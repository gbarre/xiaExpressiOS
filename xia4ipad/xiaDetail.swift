//
//  xiaDetails.swift
//  xia4ipad
//
//  Created by Guillaume on 06/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class xiaDetail: NSObject {

    var points = [UIImageView]()
    var tag: Int = 0
    var title: String = ""
    var desc: String = ""
    var zoom: Bool = false
    var scale: CGFloat = 1.0
    
    init(tag: Int, scale: CGFloat){
        self.tag = tag
        self.points = []
        self.scale = scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPoint(location: CGPoint, imageName: String) -> UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.center = location
        imageView.tag = tag
        points.append(imageView)
        
        return imageView
        // remember to add this point to the view afte calling this method :
        // view.addSubview(newPoint)
    }
    
    func createPath() -> String {
        if (points.count < 2) {
            return "Needs 2 points at least..."
        }
        else {
            
            var path: String = ""
            for point in points {
                let x = point.center.x / scale
                let y = point.center.y / scale
                path += "\(x);\(y) "
            }
            path = path.substringWithRange(Range<String.Index>(start: path.startIndex.advancedBy(0), end: path.endIndex.advancedBy(-1)))
        
            return path // return X1,xxx;Y1,yyy X2,xxx;Y2,yyy X3,xxx;Y3,yyy ...
        }
    }
    
    func bezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        for point in points {
            if (point == points.first) {
                path.moveToPoint(point.center)
            }
            else {
                path.addLineToPoint(point.center)
            }
        }
        path.closePath()
        
        return path
    }
    
    func bezierFrame() -> [CGPoint] {
        var xMin: CGFloat = UIScreen.mainScreen().bounds.width
        var xMax: CGFloat = 0
        var yMin: CGFloat = UIScreen.mainScreen().bounds.height
        var yMax: CGFloat = 0
        // Get dimensions of the shape
        for point in points {
            let xPoint = point.center.x
            let yPoint = point.center.y
            if ( xPoint < xMin ) {
                xMin = xPoint
            }
            if ( yPoint < yMin ) {
                yMin = yPoint
            }
            if ( xPoint > xMax ) {
                xMax = xPoint
            }
            if ( yPoint > yMax ) {
                yMax = yPoint
            }
        }
        return [CGPoint(x: xMin, y: yMin), CGPoint(x: xMax, y: yMin), CGPoint(x: xMax, y: yMax), CGPoint(x: xMin, y: yMax)]
        //return CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    }
    
    func distanceToTop() -> CGFloat {
        var yDist = UIScreen.mainScreen().bounds.height
        
        if (points.count > 2) {
            for point in points {
                let y = point.frame.origin.y
                if (y < yDist) {
                    yDist = y
                }
            }
        }
        return yDist
    }
    
    func test() {
        print("This xia detail have \(self.points.count) points.")
        for var i = 0; i < self.points.count; i++ {
            print(points[i])
        }
    }

}