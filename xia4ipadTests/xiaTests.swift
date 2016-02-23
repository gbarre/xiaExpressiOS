//
//  xiaTests.swift
//  xiaTests
//
//  Created by Guillaume on 04/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import XCTest
@testable import xia

class xia4ipadTests: XCTestCase {
    
    var singlePointDetail = xiaDetail(tag: 1, scale: 1)
    var multiplePointsDetail = xiaDetail(tag: 1, scale: 1)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Single point detail
        singlePointDetail.createPoint(CGPointMake(10, 10), imageName: "corner")
        
        // Multiple points detail
        multiplePointsDetail.createPoint(CGPointMake(10, 10), imageName: "corner")
        multiplePointsDetail.createPoint(CGPointMake(200.5,150), imageName: "corner")
        multiplePointsDetail.createPoint(CGPointMake(120,150.5), imageName: "corner")
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
        let outputIn = pointInPolygon(multiplePointsDetail.points, touchPoint: CGPointMake(130, 140))
        let expectedOutputIn: Bool = true
        XCTAssertEqual(outputIn, expectedOutputIn)
        
        // point out
        let outputOut = pointInPolygon(multiplePointsDetail.points, touchPoint: CGPointMake(0, 0))
        let expectedOutputOut: Bool = false
        XCTAssertEqual(outputOut, expectedOutputOut)
    }
    
    func testXiaDetailCreatePoint() {
        let output = singlePointDetail.points.first
        let expectedOutput = UIImageView(image: UIImage(named: "corner"))
        expectedOutput.center = CGPointMake(10, 10)
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
        multiplePointsDetail.constraint = "ellipse"
        let outputEllipse = multiplePointsDetail.bezierPath()
        let frame = CGRect(x: 10, y: 10, width: 190.5, height: 140.5)
        let expectedOutputEllipse = UIBezierPath(ovalInRect: frame)
        XCTAssertEqual(outputEllipse, expectedOutputEllipse)
        
        // test polygon path (include rectangle)
        multiplePointsDetail.constraint = "polygon"
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
