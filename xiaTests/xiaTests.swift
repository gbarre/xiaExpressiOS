//
//  xiaTests.swift
//  xiaTests
//
//  Created by Guillaume on 04/12/2015.
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

import XCTest
class xiaTests: XCTestCase {
    
    var singlePointDetail = xiaDetail(tag: 1, scale: 1)
    var multiplePointsDetail = xiaDetail(tag: 1, scale: 1)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Single point detail
        let _ = singlePointDetail.createPoint(CGPoint(x: 10, y: 10), imageName: "corner", index: 0)
        
        // Multiple points detail
        let _ = multiplePointsDetail.createPoint(CGPoint(x: 10, y: 10), imageName: "corner", index: 0)
        let _ = multiplePointsDetail.createPoint(CGPoint(x: 200.5,y: 150), imageName: "corner", index: 1)
        let _ = multiplePointsDetail.createPoint(CGPoint(x: 120,y: 150.5), imageName: "corner", index: 2)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUtilConvertStringToCGFloat() {
        let output1 = convertStringToCGFloat("3.14")
        let expectedOutput: CGFloat = 3.14
        XCTAssertEqual(output1, expectedOutput)
        
        let output2 = convertStringToCGFloat("3,14")
        XCTAssertEqual(output2, expectedOutput)
    }
    
    func testUtilPointInPolygon() {
        // point in
        let outputIn = pointInPolygon(multiplePointsDetail.points, touchPoint: CGPoint(x: 130, y: 140))
        let expectedOutputIn: Bool = true
        XCTAssertEqual(outputIn, expectedOutputIn)
        
        // point out
        let outputOut = pointInPolygon(multiplePointsDetail.points, touchPoint: CGPoint(x: 0, y: 0))
        let expectedOutputOut: Bool = false
        XCTAssertEqual(outputOut, expectedOutputOut)
    }
    
    func testXiaDetailCreatePoint() {
        let output = singlePointDetail.points[0]
        let expectedOutput = UIImageView(image: UIImage(named: "corner"))
        expectedOutput.center = CGPoint(x: 10, y: 10)
        expectedOutput.tag = 1
        XCTAssertEqual(output!.tag, expectedOutput.tag)
        XCTAssertEqual(output!.center, expectedOutput.center)
    }

    func testXiaDetailCreatePath() {
        // Single point
        let output = singlePointDetail.createPath()
        let expectedOutput = "0;0"
        XCTAssertEqual(output, expectedOutput)
        
        // Multiple points
        let output3pts = multiplePointsDetail.createPath()
        let expectedOutput3pts = "10.0;10.0 200.5;150.0 120.0;150.5"
        XCTAssertEqual(output3pts, expectedOutput3pts)
    }
    
    func testXiaDetailBezierPath() {
        // test ellipse path
        multiplePointsDetail.constraint = constraintEllipse
        let outputEllipse = multiplePointsDetail.bezierPath()
        let frame = CGRect(x: 10, y: 10, width: 190.5, height: 140.5)
        let expectedOutputEllipse = UIBezierPath(ovalInRect: frame)
        XCTAssertEqual(outputEllipse, expectedOutputEllipse)
        
        // test polygon path (include rectangle)
        multiplePointsDetail.constraint = constraintPolygon
        let outputPolygon = multiplePointsDetail.bezierPath()
        let expectedOutputPolygon = UIBezierPath()
        expectedOutputPolygon.moveToPoint(CGPointMake(10, 10))
        expectedOutputPolygon.addLineToPoint(CGPointMake(200.5, 150))
        expectedOutputPolygon.addLineToPoint(CGPointMake(120, 150.5))
        expectedOutputPolygon.closePath()
        XCTAssertEqual(outputPolygon, expectedOutputPolygon)
    }
    
    func testXiaDetailBezierFrame() {
        let output = multiplePointsDetail.bezierFrame()
        let expectedOutput = CGRect(x: 10, y: 10, width: 190.5, height: 140.5)
        XCTAssertEqual(output, expectedOutput)
    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
