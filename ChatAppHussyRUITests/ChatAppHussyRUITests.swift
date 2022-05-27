//
//  ChatAppHussyRUITests.swift
//  ChatAppHussyRUITests
//
//  Created by Данил on 18.05.2022.
//

import XCTest

class ChatAppHussyRUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testProfileScreen() {
        // UI tests must launch the application that they test.
        app.navigationBars.buttons["person.fill"].tap()
        XCTAssertTrue(app.textViews.element.exists)
        XCTAssertTrue(app.textFields.element.exists)
        XCTAssertTrue(app.staticTexts["My Profile"].exists)
        XCTAssertTrue(app.images["person"].exists)
        XCTAssertTrue(app.buttons["editProfile"].exists)
        XCTAssertTrue(app.buttons["editText"].exists)
    }
}
