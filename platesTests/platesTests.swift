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
    
    func testParse() {
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaAdd),
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                    Token(type: TokenType.MetaDone),
                ]),
            PlateCommand(commandType: CommandType.Add,
                         plate: Plate(plateNumber: "abc123", state: nil),
                         terminator: CommandTerminator.Done)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaAdd),
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                    Token(type: TokenType.State, value: "washington"),
                    Token(type: TokenType.MetaDone),
                ]),
            PlateCommand(commandType: CommandType.Add,
                         plate: Plate(plateNumber: "abc123", state: "washington"),
                         terminator: CommandTerminator.Done)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    // implicit add
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                    Token(type: TokenType.State, value: "washington"),
                    Token(type: TokenType.MetaDone),
                ]),
            PlateCommand(commandType: CommandType.Add,
                         plate: Plate(plateNumber: "abc123", state: "washington"),
                         terminator: CommandTerminator.Done)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaCorrection),
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                    Token(type: TokenType.State, value: "washington"),
                    Token(type: TokenType.MetaNext),
                ]),
            PlateCommand(commandType: CommandType.Correction,
                         plate: Plate(plateNumber: "abc123", state: "washington"),
                         terminator: CommandTerminator.Next)
        )
    }
    
    /// Test "discarding" of commands.
    func testParseCommandDiscard() {
        
        
    }
    
    /// Test partial (not-yet-terminated) commands.
    func testParseCommandPartial() {
        XCTAssertEqual(
            parseCommand([]),
            PlateCommand(commandType: CommandType.Add,
                         plate: nil,
                         terminator: CommandTerminator.Incomplete)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaCorrection),
                ]),
            PlateCommand(commandType: CommandType.Correction,
                         plate: nil,
                         terminator: CommandTerminator.Incomplete)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaCorrection),
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                ]),
            PlateCommand(commandType: CommandType.Correction,
                         plate: Plate(plateNumber: "abc123", state: nil),
                         terminator: CommandTerminator.Incomplete)
        )
        
        XCTAssertEqual(
            parseCommand(
                [
                    Token(type: TokenType.MetaCorrection),
                    Token(type: TokenType.PlateNumber, value: "abc123"),
                    Token(type: TokenType.State, value: "washington"),
                ]),
            PlateCommand(commandType: CommandType.Correction,
                         plate: Plate(plateNumber: "abc123", state: "washington"),
                         terminator: CommandTerminator.Incomplete)
        )
    }
}
