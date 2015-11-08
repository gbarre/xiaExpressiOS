//
//  xiaDetails.swift
//  xia4ipad
//
//  Created by Guillaume on 06/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class xiaDetail: NSObject {

/*    var moving = false
    var movingPoint = -1 // Id of point
    var movingShape = -1 // Id of Shape
    var movingCoords = CGPointMake(0, 0)
    var endEditShape = false
*/
    var points = [UIImageView]()
    var tag: Int = 0
    
    init(tag: Int){
        self.tag = tag
        self.points = []
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
            
            var path: String = "M "
            for point in points {
                let x = point.center.x
                let y = point.center.y
                path += "\(x),\(y) "
            }
            path += "Z"
        
            return path
        }
    }
    
    
    func test() {
        print("This xia detail have \(self.points.count) points.")
        for var i = 0; i < self.points.count; i++ {
            print(points[i])
        }
    }

}