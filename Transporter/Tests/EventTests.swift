//
//  EventTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import Transporter

class NumberTests: XCTestCase {

    var machine: StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        let state = State(0)
        machine = StateMachine(initialState: state)
    }
    
    func testEventWithNoMatchingStates() {
        let event = Event(name: "", sourceStates: [1,2], destinationState: 3)
        
        XCTAssertFalse(machine.addEvent(event))
    }
    
    func testEventWithNoSourceState() {
        machine.addState(State(2))
        
        let event = Event(name: "", sourceStates: [], destinationState: 2)
        
        XCTAssertFalse(machine.addEvent(event))
    }
    
    func testFiringEvent() {
        let state = State(3)
        
        machine.addState(state)
        let event = Event(name: "3", sourceStates: [0], destinationState: 3)
        machine.addEvent(event)
        
        machine.fireEventNamed("3")
        XCTAssert(machine.isInState(3))
    }
    
    func testFiringEventWithWrongState() {
        let state = State(2)
        
        let event = Event(name: "3", sourceStates: [4,5], destinationState: 2)
        machine.addState(state)
        machine.addEvent(event)
        machine.fireEventNamed("3")
        
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
        event.shouldFireEvent = { _ in
            return false
        }
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Pass")
        
        switch transition {
        case .Success(_,_):
            XCTFail("success should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.TransitionDeclined.rawValue)
            XCTAssert(error.domain == Errors.stateMachineDomain)
        }
    }
    
    func testInvalidTransition() {
        let state = State("Completed")
        let event = Event(name: "Completed", sourceStates: ["Passed"], destinationState: "Completed")
        machine.addState(state)
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Completed")
        
        switch transition {
        case .Success(_,_):
            XCTFail("success should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.InvalidTransition.rawValue)
        }
    }
    
    func testStatePassed() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Pass")
        switch transition {
        case .Success(let sourceState,let destinationState):
            XCTAssert(sourceState.value == "Initial")
            XCTAssert(destinationState.value == "Passed")
        case .Error(_):
            XCTFail("There shouldn't be any errors")
        }
    }
    
    func testUnknownEvent() {
        let transition = machine.fireEventNamed("Foo")
        
        switch transition {
        case .Success(_, _):
            XCTFail("Event does not exist and should not be fired")
        case .Error(let error):
            XCTAssert(error.code == Errors.Transition.UnknownEvent.rawValue)
        }
    }
    
    func testWillFireEventBlock() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        var foo = 5
        event.willFireEvent = { _ in
            XCTAssert(self.machine.isInState("Initial"))
            foo = 7
        }
        machine.addEvent(event)
        
        var transition = machine.fireEventNamed("Pass")
        XCTAssert(foo == 7)
    }
    
    func testDidFireEventBlock() {
        let event = Event(name: "Pass", sourceStates: ["Initial"], destinationState: "Passed")
        var foo = 5
        event.didFireEvent = { _ in
            XCTAssert(self.machine.isInState("Passed"))
            foo = 7
        }
        machine.addEvent(event)
        
        let transition = machine.fireEventNamed("Pass")
        XCTAssert(foo == 7)
    }
}