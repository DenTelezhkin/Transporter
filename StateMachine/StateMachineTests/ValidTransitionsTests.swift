//
//  ValidTransitionsTests.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 20.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class ValidTransitionsTests: XCTestCase {

    var machine : StateMachine<Int>!
    
    
    override func setUp() {
        super.setUp()
        
        let initial = State(5)
        machine = StateMachine(initialState: initial)
    }
    
    func testValidTransitionsTurnedOff() {
        var x = 2
        
        let state = State(3)
        state.didEnterState = { state in x = 4 }
        machine.addState(state)
        
        machine.activateState(3)
        
        XCTAssert(x==4)
    }
    
    func testValidTransitionsIsNotValid() {
        var x = 2
        let state = State(3)
        state.didEnterState = { state in x = 4 }
        machine.addState(state)
        machine.allowOnlyValidTransitions = true
        
        machine.activateState(3)
        
        XCTAssert(x==2)
    }
    
    func testTransitionIsValid() {
        var x=2
        let state = State(3)
        state.didEnterState = { state in x = 5 }
        machine.addState(state)
        machine.allowOnlyValidTransitions = true
        machine.addTransitions(5, toStates: [3])
        machine.activate()
        machine.activateState(3)
        
        XCTAssert(x == 5)
    }
}
