//
//  platesTests.swift
//  platesTests
//
//  Created by David Grant on 10/9/20.
//

import XCTest

@testable import plates

class platesTests: XCTestCase {
    func testTranslate() {
        XCTAssertEqual(translate("alpha beta 1 2 3"), "ab123")
        XCTAssertEqual(translate("alpha beta 123"), "ab123")
        XCTAssertEqual(translate("alpha 123 beta charlie"), "a123bc")
        XCTAssertEqual(translate("alpha yankee 123 beta charlie"), "ay123bc")
        
        XCTAssertEqual(translate("1 11 111"), "111111")
    }
    
    func testTokenize() {
        XCTAssertEqual(tokenize("alpha beta 1 2 3"),
                       [Token(type: TokenType.PlateNumber, value: "ab123")])
        XCTAssertEqual(
            tokenize("alpha 1 done beta 2 done"),
            [
                Token(type: TokenType.PlateNumber, value: "a1"),
                Token(type: TokenType.MetaDone),
                Token(type: TokenType.PlateNumber, value: "b2"),
                Token(type: TokenType.MetaDone),
                Token(type: TokenType.PlateNumber, value: "w9"),
            ])
        
        XCTAssertEqual(
            tokenize("alpha 1 zulu 2 next whiskey 1"),
            [
                Token(type: TokenType.PlateNumber, value: "a1z2"),
                Token(type: TokenType.MetaNext),
                Token(type: TokenType.PlateNumber, value: "w1"),
            ])
        
        XCTAssertEqual(
            tokenize("alpha 1 zulu 2 state washington done"),
            [
                Token(type: TokenType.PlateNumber, value: "a1z2"),
                Token(type: TokenType.State, value: "washington"),
                Token(type: TokenType.MetaDone),
            ])
        
        XCTAssertEqual(
            tokenize(
                "alpha 1 zulu 2 state washington next " +
                "november alpha charlie 0 9 5 4 done"
            ),
            [
                Token(type: TokenType.PlateNumber, value: "a1z2"),
                Token(type: TokenType.State, value: "washington"),
                Token(type: TokenType.MetaNext),
                Token(type: TokenType.PlateNumber, value: "nac0954"),
                Token(type: TokenType.MetaDone),
            ])
        
    }
}
