//
//  platesTests.swift
//  platesTests
//
//  Created by David Grant on 10/9/20.
//

import XCTest

@testable import plates

class platesTests: XCTestCase {
    func testTokenize() {
        XCTAssertEqual(tokenize("alpha beta 1 2 3"),
                       [Token(type: TokenType.PlateNumber, value: "ab123")])

        XCTAssertEqual(
            tokenize("alpha 1 done"),
            [
                Token(type: TokenType.PlateNumber, value: "a1"),
                Token(type: TokenType.MetaDone),
            ])
        
        XCTAssertEqual(
            tokenize("alpha 1 zulu 2 next"),
            [
                Token(type: TokenType.PlateNumber, value: "a1z2"),
                Token(type: TokenType.MetaNext),
            ])
        
        XCTAssertEqual(
            tokenize("alpha 1 zulu 2 state washington done"),
            [
                Token(type: TokenType.PlateNumber, value: "a1z2"),
                Token(type: TokenType.State, value: "washington"),
                Token(type: TokenType.MetaDone),
            ])
    }
}
