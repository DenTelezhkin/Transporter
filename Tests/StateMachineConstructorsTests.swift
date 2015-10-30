//
//  StateMachineConstructorsTests.swift
//  Transporter
//
//  Created by Denys Telezhkin on 14.11.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Transporter
import XCTest

class StateMachineConstructorsTests: XCTestCase {

    func testStateConvenienceConstructor() {
        let state = State(3)
        let state2 = State(5)
        let state3 = State(7)
        
        let machine = StateMachine(initialState: state, states: [state2,state3])
        
        XCTAssertTrue(machine.isStateAvailable(3))
        XCTAssertTrue(machine.isStateAvailable(5))
        XCTAssertTrue(machine.isStateAvailable(7))
    }
    
    func testConvenienceInit()
    {
        let machine = StateMachine(initialStateName: 0)
        XCTAssert(machine.isStateAvailable(0))
    }
}
