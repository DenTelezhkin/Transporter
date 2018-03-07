//
//  AddingStatesTestCase.swift
//  Transporter
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest
import Transporter

class AddingStatesTestCase: XCTestCase {

    let initial = State(4)
    var machine : StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        
        machine = StateMachine(initialState: initial)
    }

    func testAddState() {
        machine.addState(State(3))
        
        XCTAssert(machine.isStateAvailable(3))
    }
    
    func testAddStates() {
        machine.addStates([State(6),State(7)])
        
        XCTAssert(machine.isStateAvailable(6))
        XCTAssert(machine.isStateAvailable(7))
    }
    
    func testStateAvailable() {
        machine.addState(State(5))
        
        let state = machine.stateWithValue(5)
        
        XCTAssertNotNil(state)
    }
    
    func testStateIsNotAvailable() {
        let state = machine.stateWithValue(2)
        
        XCTAssertNil(state)
    }

    func test_addStates_whenStateExists_doesNotOverridePreviousValue() {
        let state = State(5)
        machine.addState(state)
        XCTAssertEqual(machine.availableStates.filter { $0.value == 5 }.count, 1)
        machine.addState(State(5))
        XCTAssertEqual(machine.availableStates.filter { $0.value == 5 }.count, 1)
    }
}
