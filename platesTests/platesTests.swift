//
//  platesTests.swift
//  platesTests
//
//  Created by David Grant on 10/9/20.
//

import XCTest

@testable import plates

class platesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTranslate() {
        XCTAssertEqual(translate("alpha beta 1 2 3"), "ab123")
        XCTAssertEqual(translate("alpha beta 123"), "ab123")
        XCTAssertEqual(translate("alpha 123 beta charlie"), "a123bc")
        XCTAssertEqual(translate("alpha yankee 123 beta charlie"), "ay123bc")
        
        XCTAssertEqual(translate("1 11 111"), "111111")
    }

}
