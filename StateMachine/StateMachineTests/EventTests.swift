//
//  EventTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class EventTests: XCTestCase {

    var machine: StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        let state = State(0)
        machine = StateMachine(initialState: state)
    }
    
    func testEventWithNoMatchingStates() {
        let event = Event(name: 1, sourceStates: [1,2], destinationState: 3)
        
        XCTAssertFalse(machine.addEvent(event))
    }
    
    func testEventWithNoSourceState() {
        machine.addState(State(2))
        
        let event = Event(name: 1, sourceStates: [], destinationState: 2)
        
        XCTAssertFalse(machine.addEvent(event))
    }
    
    func testFiringEvent() {
        let state = State(3)
        
        machine.addState(state)
        let event = Event(name: 3, sourceStates: [0], destinationState: 3)
        machine.addEvent(event)
        
        machine.fireEventNamed(3)
        XCTAssert(machine.isInState(3))
    }
    
    func testFiringEventWithWrongState() {
        let state = State(2)
        
        let event = Event(name: 3, sourceStates: [4,5], destinationState: 2)
        machine.addState(state)
        machine.addEvent(event)
        machine.fireEventNamed(3)
        
        XCTAssert(machine.isInState(0))
    }
}
