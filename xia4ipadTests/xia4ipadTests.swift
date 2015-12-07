//
//  xia4ipadTests.swift
//  xia4ipadTests
//
//  Created by Guillaume on 04/12/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import XCTest
@testable import xia4ipad

class xia4ipadTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*func testXiaDetailCreatePointImage() {
        let newDetail = xiaDetail(tag: 1, scale: 1)
        let output = newDetail.createPoint(CGPointMake(10, 10), imageName: "corner")
        let expected_output = UIImageView(image: UIImage(named: "corner"))
        expected_output.center = CGPointMake(10, 10)
        expected_output.tag = 1
        XCTAssertEqual(output, expected_output)
    }*/

    func testXiaDetailCreatePathSinglePoint() {
        
        let newDetail = xiaDetail(tag: 1, scale: 1)
        newDetail.createPoint(CGPointMake(10, 10), imageName: "corner")
        let output = newDetail.createPath()
        let expected_output = "0;0"
        XCTAssertEqual(output, expected_output)
    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
