//
//  StateEventsTestCase.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 15.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class StateEventsTestCase: XCTestCase {

    let initial = State(4)
    var machine : StateMachine<Int>!
    
    override func setUp() {
        super.setUp()
        
        machine = StateMachine(initialState: initial)
    }

    func testWillEnterBlock() {
        let state = State(5)
        var x = 5
        state.willEnterState = { (fromState) in
            x = 6
        }
        
        machine.addState(state)
        machine.activateState(5)
        
        XCTAssert(x==6)
    }

}
