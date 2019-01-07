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
        
        // Open first element in collection
        app.collectionViews.cells.otherElements.firstMatch.tap()
        
        // Add rectangle
        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons["Ajouter"].tap()
        app.sheets.buttons["Rectangle"].tap()
        
        // Open detail
        app.toolbars["Toolbar"].buttons["edit"].tap()
        
        // Add title
        app.typeText("Un titre")
        
        // Add description
        app.buttons["tab"].tap()
        app.typeText("Une description simple...")
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"retour\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.typeText("Un lien : http://perdu.com")
        
        // Close popup
        app.navigationBars.buttons["OK"].tap()
        
    }
    
    func testOpenRectangle() {
        let app = XCUIApplication()
        
        // Open first element in collection
        app.collectionViews.cells.otherElements.firstMatch.tap()
        
        // Go to PlayView
        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons["Lecture"].tap()
        
        // Try to open the first detail
        app.otherElements["detail200"].tap()
        
        // Check for title
        let title = app.staticTexts["DetailTitle"].label
        XCTAssertEqual(title, "Un titre")
        
        // Check for description
        let text1 = app.webViews.staticTexts["Une description simple..."].label
        XCTAssertEqual(text1, "Une description simple...")
        
        let text2 = app.webViews.staticTexts["http://perdu.com"].label
        XCTAssertEqual(text2, "http://perdu.com")
        
    }
}
