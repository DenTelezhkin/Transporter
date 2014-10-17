//
//  StateMachineTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class StateMachineStateSwitchingTests: XCTestCase {

    func testStateMachineStates() {
        let initial = State(3)
        var machine = StateMachine(initialState: initial)
        
        XCTAssert(machine.isInState(3))
        XCTAssertFalse(machine.isInState(4))
    }
    
    func testStateAvailable() {
        let initial = State(3)
        let machine = StateMachine(initialState: initial)
        
        XCTAssert(machine.isStateAvailable(3))
        XCTAssertFalse(machine.isStateAvailable(4))
    }
    
    func testActivate() {
        let initial = State(0)
        let machine = StateMachine(initialState: initial)
        
        machine.activate()
        
        XCTAssert(machine.isInState(0))
    }
}
