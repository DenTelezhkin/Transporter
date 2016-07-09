//
//  EventTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest
import Transporter

func XCTAssertThrows<T: ErrorProtocol where T: Equatable>(_ error: T, block: () throws -> ()) {
    do {
        try block()
    }
    catch let e as T {
        XCTAssertEqual(e, error)
    }
    catch {
        XCTFail("Wrong error")
    }
}

class NumberTests: XCTestCase {

    var machine: StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        let state = State(0)
        machine = StateMachine(initialState: state)
    }
    
    func testEventWithNoMatchingStates() {
        let event = Event(name: "", sourceValues: [1,2], destinationValue: 3)
        XCTAssertThrows(EventError.noSourceValue) {
            try self.machine.addEvent(event)
        }
    }
    
    func testEventWithNoSourceState() {
        machine.addState(State(2))
        
        let event = Event(name: "", sourceValues: [], destinationValue: 2)
        
        XCTAssertThrows(EventError.noSourceValue) {
            try self.machine.addEvent(event)
        }
    }
    
    func testFiringEvent() {
        let state = State(3)
        
        machine.addState(state)
        let event = Event(name: "3", sourceValues: [0], destinationValue: 3)
        guard let _ = try? machine.addEvent(event) else {
            XCTFail()
            return
        }
        
        machine.fireEvent("3")
        XCTAssert(machine.isInState(3))
    }
    
    func testAddingEventWithWrongDestinationState() {
        let event = Event(name: "3", sourceValues: [0], destinationValue: 2)
        XCTAssertThrows(EventError.noDestinationValue) {
            try self.machine.addEvent(event)
        }
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
        let event = Event(name: "Pass", sourceValues: ["Initial"], destinationValue: "Passed")
        
        XCTAssertFalse(machine.canFireEvent("Pass"))
        XCTAssertFalse(machine.canFireEvent(event))
        _ = try? machine.addEvent(event)
        XCTAssertTrue(machine.canFireEvent("Pass"))
        XCTAssertTrue(machine.canFireEvent(event))
        
        machine.fireEvent("Pass")
        XCTAssert(machine.isInState("Passed"))
    }
    
    func testShouldFireEventBlock() {
        let event = Event(name: "Pass", sourceValues: ["Initial"], destinationValue: "Passed")
        event.shouldFireEvent = { _ in
            return false
        }
        _ = try? machine.addEvent(event)
        
        let transition = machine.fireEvent("Pass")
        
        switch transition {
        case .success(_,_):
            XCTFail("success should not be fired")
        case .error(let error):
            XCTAssertEqual(error, TransitionError.transitionDeclined)
        }
    }
    
    func testSourceStateUnavailable() {
        let state = State("Completed")
        let event = Event(name: "Completed", sourceValues: ["Passed"], destinationValue: "Completed")
        machine.addState(state)
        _ = try? machine.addEvent(event)
        
        let transition = machine.fireEvent("Completed")
        
        switch transition {
        case .success(_,_):
            XCTFail("success should not be fired")
        case .error(let error):
            XCTAssertEqual(error, TransitionError.wrongSourceState)
        }
    }
    
    func testStatePassed() {
        let event = Event(name: "Pass", sourceValues: ["Initial"], destinationValue: "Passed")
        _ = try? machine.addEvent(event)
        
        let transition = machine.fireEvent("Pass")
        switch transition {
        case .success(let sourceState,let destinationState):
            XCTAssert(sourceState.value == "Initial")
            XCTAssert(destinationState.value == "Passed")
        case .error(_):
            XCTFail("There shouldn't be any errors")
        }
    }
    
    func testTransitionSuccessful()
    {
        let event = Event(name: "Pass", sourceValues: ["Initial"],destinationValue: "Passed")
        _ = try? machine.addEvent(event)
        let transition = machine.fireEvent("Pass")
        
        XCTAssert(transition.successful)
    }
    
    func testTransitionFailed()
    {
        let event = Event(name: "Pass", sourceValues: ["Initial"],destinationValue: "Passed")
        _ = try? machine.addEvent(event)
        let transition = machine.fireEvent("Foo")
        
        XCTAssertFalse(transition.successful)
    }
    
    func testUnknownEvent() {
        let transition = machine.fireEvent("Foo")
        
        switch transition {
        case .success(_, _):
            XCTFail("Event does not exist and should not be fired")
        case .error(let error):
            XCTAssertEqual(error, TransitionError.unknownEvent)
        }
    }
    
    func testWillFireEventBlock() {
        let event = Event(name: "Pass", sourceValues: ["Initial"], destinationValue: "Passed")
        var foo = 5
        event.willFireEvent = { _ in
            XCTAssert(self.machine.isInState("Initial"))
            foo = 7
        }
        _ = try? machine.addEvent(event)
        
        _ = machine.fireEvent("Pass")
        XCTAssert(foo == 7)
    }
    
    func testDidFireEventBlock() {
        let event = Event(name: "Pass", sourceValues: ["Initial"], destinationValue: "Passed")
        var foo = 5
        event.didFireEvent = { _ in
            XCTAssert(self.machine.isInState("Passed"))
            foo = 7
        }
        _ = try? machine.addEvent(event)
        
        _ = machine.fireEvent("Pass")
        XCTAssert(foo == 7)
    }
}
