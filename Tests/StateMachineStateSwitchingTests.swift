//
//  TransporterTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest
import Transporter

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
    
    func testShouldFireEvent()
    {
        let event = Event(name: "Foo", sourceValues: [0], destinationValue: 1)
        var blockCalled = false
        event.shouldFireEvent = { event -> Bool in
            blockCalled = true
            return true
        }
        machine.addState(State(1))
        _ = try? machine.addEvent(event)
        machine.fireEvent(event)
        XCTAssert(blockCalled)
    }
    
    func testAddValidEvents()
    {
        let event = Event(name: "Foo", sourceValues: [0], destinationValue: 1)
        let event2 = Event(name: "Bar", sourceValues: [0], destinationValue: 2)
        machine.addState(State(1))
        machine.addEvents([event,event2])
        
        XCTAssert(machine.canFireEvent("Foo"))
        XCTAssertFalse(machine.canFireEvent("Bar"))
    }
}
