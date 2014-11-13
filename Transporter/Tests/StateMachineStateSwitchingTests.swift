//
//  TransporterTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class StateMachineStateSwitchingTests: XCTestCase {

    var machine: StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        let initial = State(0)
        machine = StateMachine(initialState: initial)
    }
    
    func testStateMachineStates() {
        XCTAssert(machine.isInState(0))
        XCTAssertFalse(machine.isInState(4))
    }
    
    func testStateAvailable() {
        XCTAssert(machine.isStateAvailable(0))
        XCTAssertFalse(machine.isStateAvailable(4))
    }
    
    func testActivate() {
        XCTAssert(machine.isInState(0))
    }
    
    func testWillEnterStateBlock() {
        let state = State(3)
        var blockCalled = false
        state.willEnterState = { enteringState in
            XCTAssert(enteringState.value == state.value)
            blockCalled = true
        }
        
        machine.addState(state)
        machine.activateState(3)
        XCTAssert(blockCalled)
    }
    
    func testDidEnterStateBlock() {
        let state = State(4)
        var blockCalled = false
        state.didEnterState = { enteringState in
            XCTAssert(enteringState.value == state.value)
            blockCalled = true
        }
        
        machine.addState(state)
        machine.activateState(4)
        XCTAssert(blockCalled)
    }
    
    func testWillExitStateBlock() {
        let state = State(3)
        var blockCalled = false
        state.willExitState = { exitingState in
            XCTAssert(exitingState.value == state.value)
            blockCalled = true
        }
        machine.addState(state)
        machine.activateState(3)
        machine.activateState(0)
        XCTAssert(blockCalled)
    }
    
    func testDidExitStateBlock() {
        let state = State(3)
        var blockCalled = false
        state.didExitState = { exitingState in
            XCTAssert(exitingState.value == state.value)
            blockCalled = true
        }
        machine.addState(state)
        machine.activateState(3)
        machine.activateState(0)
        XCTAssert(blockCalled)
    }
}
