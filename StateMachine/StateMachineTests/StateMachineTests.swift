//
//  StateMachineTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class StateMachineTests: XCTestCase {

    func testStateMachineStates() {
        let initial = State(3)
        var machine = StateMachine(initialState: initial)
        
        XCTAssert(machine.isInState(State(3)))
        XCTAssertFalse(machine.isInState(State(4)))
    }
}
