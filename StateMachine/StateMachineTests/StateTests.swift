//
//  StateTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest
import StateMachine

class StateTests: XCTestCase {

    func testStrings() {
        var state = State(6)
        var state2 = State(5+1)
        
        XCTAssert(state == state2)
    }

    func testDifferentStrings() {
        var state = State(4)
        var state2 = State(5)
        
        XCTAssertFalse(state == state2)
    }
}
