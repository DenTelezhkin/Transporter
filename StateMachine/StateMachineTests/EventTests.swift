//
//  EventTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class NumberTests: XCTestCase {

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

class StringTests: XCTestCase {
    
    var machine: StateMachine<String>!
    
    override func setUp() {
        super.setUp()
        let state = State("Initial")
        let passedState = State("Passed")
        machine = StateMachine(initialState: state)
        machine.addState(passedState)
    }
    
    func testCanFireEvent() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        
        XCTAssertFalse(machine.canFireEvent("Pass"))
        XCTAssertFalse(machine.canFireEvent(event))
        machine.addEvent(event)
        XCTAssertTrue(machine.canFireEvent("Pass"))
        XCTAssertTrue(machine.canFireEvent(event))
        
        machine.fireEventNamed("Pass")
        XCTAssert(machine.isInState("Passed"))
    }
    
    func testShouldFireEventBlock() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        event.shouldFireEvent = { event in
            return false
        }
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Pass")
        
        switch transition {
        case .Success(let sourceState, let destinationState):
            XCTFail("success should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.TransitionDeclined.rawValue)
        }
    }
    
    func testInvalidTransition() {
        let state = State("Completed")
        let event = Event(name: "Completed", sourceStates: ["Passed"], destinationState: "Completed")
        machine.addState(state)
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Completed")
        
        switch transition {
        case .Success(let sourceState, let destinationState):
            XCTFail("success should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.InvalidTransition.rawValue)
        }
    }
    
    func testStated() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Pass")
        switch transition {
        case .Success(let sourceState,let destinationState):
            XCTAssert(sourceState.value == "Initial")
            XCTAssert(destinationState.value == "Passed")
        case .Error(let error):
            XCTFail("There shouldn't be any errors")
        }
    }
    
    func testUnknownEvent() {
        let transition = machine.fireEventNamed("Foo")
        
        switch transition {
        case .Success(let sourceState, let destinationState):
            XCTFail("Event does not exist and should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.UnknownEvent.rawValue)
        }
    }
}