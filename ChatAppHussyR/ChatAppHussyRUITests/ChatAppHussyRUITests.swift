//
//  ChatAppHussyRUITests.swift
//  ChatAppHussyRUITests
//
//  Created by Данил on 18.05.2022.
//

import XCTest

class ChatAppHussyRUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        app.navigationBars.buttons["person.fill"].tap()
        XCTAssertTrue(app.textViews.element.exists)
        XCTAssertTrue(app.textFields.element.exists)
        XCTAssertTrue(app.staticTexts["My Profile"].exists)
        XCTAssertTrue(app.images["person"].exists)
        XCTAssertTrue(app.buttons["editProfile"].exists)
        XCTAssertTrue(app.buttons["editText"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
