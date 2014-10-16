//
//  AddingStatesTestCase.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

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
}
