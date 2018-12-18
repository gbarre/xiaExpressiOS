//
//  xiaDetails.swift
//  xia
//
//  Created by Guillaume on 06/11/2015.
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

class xiaDetail: NSObject {

    @objc var points = [Int: UIImageView]()
    @objc var tag: Int = 0
    @objc var scale: CGFloat = 1.0
    @objc var constraint: String = emptyString
    @objc var locked: Bool = false
    
    @objc init(tag: Int, scale: CGFloat){
        self.tag = tag
        self.points = [:]
        self.scale = scale
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        fatalError(fatalErrorInit)
    }
    
    @objc func bezierFrame(_ scale:CGFloat = 1.0) -> CGRect {
        var xMin: CGFloat = UIScreen.main.bounds.width
        var xMax: CGFloat = 0
        var yMin: CGFloat = UIScreen.main.bounds.height
        var yMax: CGFloat = 0
        // Get dimensions of the shape
        for (_,point) in points {
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
        return CGRect(x: xMin * scale, y: yMin * scale, width: (xMax - xMin) * scale, height: (yMax - yMin) * scale)
    }
    
    @objc func bezierPath(_ scale:CGFloat = 1.0) -> UIBezierPath {
        var path = UIBezierPath()
        if constraint == constraintEllipse {
            path = UIBezierPath(ovalIn: self.bezierFrame())
        }
        else {
            let sortedPoints = points.sorted{$0.0 < $1.0}
            for (_,point) in sortedPoints {
                if (point == sortedPoints[0].1) {
                    path.move(to: CGPoint(x: point.center.x * scale, y: point.center.y * scale))
                }
                else {
                    path.addLine(to: CGPoint(x: point.center.x * scale, y: point.center.y * scale))
                }
            }
            path.close()
        }
        return path
    }
    
    @objc func createPath() -> String {
        if (points.count < 2) {
            return newDetailPathString
        }
        else {
            
            var path: String = emptyString
            let sortedPoints = points.sorted{$0.0 < $1.0}
            for (_,point) in sortedPoints {
                let x = point.center.x / scale
                let y = point.center.y / scale
                path += x.toString + semicolonString + y.toString + spaceString
            }
            path = String(path.prefix(path.count - 1))
            
            return path // return X1.xxx;Y1.yyy X2.xxx;Y2.yyy X3.xxx;Y3.yyy ...
        }
    }
    
    @objc func createPoint(_ location: CGPoint, imageName: String, index: Int) -> UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.center = location
        imageView.tag = tag
        points[index] = imageView
        
        return imageView
        // remember to add this point to the view afte calling this method :
        // view.addSubview(newPoint)
    }
    
    @objc func makeVirtPoints() -> [Int: UIImageView] {
        let nbPoints = points.count
        var virtPoints = [Int: UIImageView]()
        
        for i in 0...nbPoints-1 {
            let j = (i+1)%nbPoints
            let point1 = CGPoint(x: points[i]!.center.x, y: points[i]!.center.y)
            let point2 = CGPoint(x: points[j]!.center.x, y: points[j]!.center.y)
            // Get distance between point1 & point2
            let x = point1.x - point2.x
            let y = point1.y - point2.y
            let dist = sqrt(x * x + y * y)
            if dist > 50 {
                // We can show a virt point
                let newPoint = CGPoint(x: (point1.x+point2.x)/2, y: (point1.y+point2.y)/2)
                let image = UIImage(named: cornerString)
                let imageView = UIImageView(image: image!)
                imageView.alpha = 0.2
                imageView.tag = tag+100
                imageView.center = newPoint
                virtPoints[i] = imageView
            }
        }
        
        return virtPoints
    }
}
