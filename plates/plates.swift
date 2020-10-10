//
//  plates.swift
//  plates
//
//  Created by David Grant on 10/10/20.
//

import Foundation

enum Token {
    case Atom
    case State
    
    case MetaCorrection
    case MetaNext
    case MetaDone
}

struct Command {
    
    
}

func tokenize(input: String) -> [Command] {
    return []
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
    "xray": "x",
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

func translate(_ input: String) -> String {

    var output = ""

    for atom in input.lowercased().split(separator: " ") {
        if let char = nato[String(atom)] {
            output += char
        } else if let char = numeric[String(atom)] {
            output += char
        } else {
            // "128" or "1"
            for c in atom {
                if c.isNumber {
                    output += String(c)
                }
            }
        }
    }

    return output
}
