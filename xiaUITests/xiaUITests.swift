//  xiaUITests.swift
//  xiaUITests
//
//  Created by Guillaume on 18/12/2018.
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

class xiaUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddPhotoToCollection() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.navigationBars["Xia"].buttons["Ajouter"].tap()
        app.buttons["Take a photo"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["PhotoCapture"]/*[[".buttons[\"Prendre une photo\"]",".buttons[\"PhotoCapture\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Valider"].tap()
    }
    
    func testAddRectangle() {
        let app = XCUIApplication()
        app.collectionViews.cells.otherElements.firstMatch.tap()
        
        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons["Ajouter"].tap()
        app.sheets.buttons["Rectangle"].tap()
    }
    
    func testOpenRectangle() {
        let app = XCUIApplication()
        app.collectionViews.cells.otherElements.firstMatch.tap()
        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons["Lecture"].tap()
        
        XCTAssertTrue(app.otherElements["200"].exists)
        
        app.otherElements["200"].tap()
        
        let window = app.children(matching: .window).element(boundBy: 0)
        let element = window.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).tap()
        element.tap()
        app.buttons["delete"].tap()
        window.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        toolbar.buttons["Collection"].tap()
        
        
    }
}
