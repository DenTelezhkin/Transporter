//
//  EnumTestCase.swift
//  Transporter
//
//  Created by Denys Telezhkin on 13.11.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import XCTest
import Transporter

enum StateEnum {
    case start
    case progress
    case finish
}

struct EnumEvents {
    static let MakeProgress = "MakeProgress"
    static let RaceToFinish = "RaceToFinish"
}

class EnumTestCase: XCTestCase {

    var machine : StateMachine<StateEnum>!
    
    override func setUp() {
        super.setUp()
        
        let initialState = State(StateEnum.start)
        machine = StateMachine(initialState: initialState)
        
        let progressState = State(StateEnum.progress)
        let finishState = State(StateEnum.finish)
        
        machine.addStates([progressState,finishState])
    }
    
    func testStateChange() {
        let state = machine.stateWithValue(.progress)
        
        var x = 0
        state?.didEnterState = { _ in x = 6 }
        
        machine.activateState(.progress)
        
        XCTAssertEqual(x, 6)
    }
    
    func testFiringEvent() {
        let event = Event(name: EnumEvents.MakeProgress, sourceValues: [StateEnum.start], destinationValue: StateEnum.progress)
        
        _ = try? machine.addEvent(event)
        machine.fireEvent(EnumEvents.MakeProgress)
        
        XCTAssert(machine.isInState(.progress))
    }
}
