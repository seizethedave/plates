//
//  plates.swift
//  plates
//
//  Created by David Grant on 10/10/20.
//

import Foundation



enum TokenType {
    case PlateNumber
    case State

    case MetaAdd
    case MetaCorrection
    case MetaNext
    case MetaDone
}

struct Token : Equatable {
    var type: TokenType
    var value: String?
}

enum CommandType {
    case Add
    case Correction
}

enum CommandTerminator {
    case Done
    case Next
    case Incomplete
}

struct Plate : Equatable {
    var plateNumber: String
    var state: String?
}

struct PlateCommand : Equatable {
    var commandType: CommandType
    var plate: Plate?
    var terminator: CommandTerminator
}

let nato = [
    "alpha": "a",
    "beta": "b",
    "charlie": "c",
    "delta": "d",
    "echo": "e",
    "foxtrot": "f",
    "golf": "g",
    "hotel": "h",
    "india": "i",
    "juliet": "j",
    "kilo": "k",
    "lima": "l",
    "mike": "m",
    "november": "n",
    "oscar": "o",
    "papa": "p",
    "quebec": "q",
    "romeo": "r",
    "sierra": "s",
    "tango": "t",
    "uniform": "u",
    "victor": "v",
    "whiskey": "w",
    "x-ray": "x",
    "yankee": "y",
    "zulu": "z",
]
let numeric = [
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
]


/*
 input:
 alpha beta 1 2 3
 output:
 [Token("ab123"), ...]
 */
func tokenize(_ input: String) -> [Token] {
    var tokens = [Token]()
    var plateBuf = ""
    var expectState = false
    
    func flushPlate() {
        if !plateBuf.isEmpty {
            tokens.append(Token(type: TokenType.PlateNumber, value: plateBuf))
            plateBuf = ""
        }
    }

    for atom in input.lowercased().split(separator: " ") {
        if expectState {
            tokens.append(Token(type: TokenType.State, value: String(atom)))
            expectState = false
        } else if atom == "done" {
            flushPlate()
            tokens.append(Token(type: TokenType.MetaDone))
            break
        } else if atom == "next" {
            flushPlate()
            tokens.append(Token(type: TokenType.MetaNext))
            break
        } else if atom == "state" {
            flushPlate()
            expectState = true
        } else if let val = nato[String(atom)] {
            plateBuf += val
        } else if let val = numeric[String(atom)] {
            plateBuf += val
        } else if atom.allSatisfy({ $0.isNumber }) {
            // e.g., "128" or "1"
            plateBuf += atom
        } else {
            print("unrecognized atom:", atom)
        }
    }

    // dangling plate at end of input without terminal token:
    flushPlate()

    return tokens
}

func parseCommand(_ tokens: [Token]) -> PlateCommand? {
    var commandType = CommandType.Add
    var plate : Plate? = nil
    var terminator = CommandTerminator.Incomplete
    
    if tokens.isEmpty {
        return PlateCommand(
            commandType: commandType,
            plate: plate,
            terminator: terminator
        )
    }
    
    var it = tokens.makeIterator()
    var t = it.next()
    if t == nil {
        return PlateCommand(
            commandType: commandType,
            plate: plate,
            terminator: terminator
        )
    }
    var tok = t!
    
    if tok.type == TokenType.MetaAdd || tok.type == TokenType.MetaCorrection {
        // It's a command type.
        commandType = tok.type == TokenType.MetaAdd ? CommandType.Add : CommandType.Correction
        
        t = it.next()
        if t == nil {
            return PlateCommand(
                commandType: commandType,
                plate: plate,
                terminator: terminator
            )
        }
        tok = t!
    }
    
    // Next one is the plate number.
    
    assert(tok.type == TokenType.PlateNumber)
    let plateNumber = tok.value!
    var state: String? = nil
    plate = Plate(plateNumber: plateNumber, state: state)
    
    t = it.next()
    if t == nil {
        return PlateCommand(
            commandType: commandType,
            plate: plate,
            terminator: terminator
        )
    }
    tok = t!
    
    if tok.type == TokenType.State {
        state = tok.value
        plate = Plate(plateNumber: plateNumber, state: state)
        
        t = it.next()
        if t == nil {
            return PlateCommand(
                commandType: commandType,
                plate: plate,
                terminator: terminator
            )
        }
        tok = t!
    }
    
    terminator = tok.type == TokenType.MetaDone ? CommandTerminator.Done : CommandTerminator.Next
    return PlateCommand(commandType: commandType, plate: plate, terminator: terminator)
}

