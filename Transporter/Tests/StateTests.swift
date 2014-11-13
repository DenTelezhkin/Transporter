//
//  StateTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest

class StateTests: XCTestCase {

    func testNumberEqualStates() {
        var state = State(6)
        var state2 = State(5+1)
        
        XCTAssert(state.value == state2.value)
    }
    
    func testNumberDifferentState() {
        let state = State(4)
        let state2 = State(3)
        
        XCTAssertFalse(state.value == state2.value)
    }

    func testDifferentStrings() {
        let state = State("Foo")
        let state2 = State("Bar")
        
        XCTAssertFalse(state.value == state2.value)
    }
    
    func testIdenticalStrings() {
        let state = State("omg")
        let state2 = State("omg")
        
        XCTAssert(state.value == state2.value)
    }
}
