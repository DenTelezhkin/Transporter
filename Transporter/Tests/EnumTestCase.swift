//
//  EnumTestCase.swift
//  Transporter
//
//  Created by Denys Telezhkin on 13.11.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

enum StateEnum {
    case Start
    case Progress
    case Finish
}

struct EnumEvents {
    static let MakeProgress = "MakeProgress"
    static let RaceToFinish = "RaceToFinish"
}

class EnumTestCase: XCTestCase {

    var machine : StateMachine<StateEnum>!
    
    override func setUp() {
        super.setUp()
        
        let initialState = State(StateEnum.Start)
        machine = StateMachine(initialState: initialState)
        
        let progressState = State(StateEnum.Progress)
        let finishState = State(StateEnum.Finish)
        
        machine.addStates([progressState,finishState])
    }
    
    func testStateChange() {
        let state = machine.stateWithValue(.Progress)
        
        var x = 0
        state?.didEnterState = { _ in x = 6 }
        
        machine.activateState(.Progress)
        
        XCTAssertEqual(x, 6)
    }
    
    func testFiringEvent() {
        let array: [StateEnum] = [StateEnum.Start,StateEnum.Progress]
        let event = Event(name: EnumEvents.MakeProgress, sourceStates: [StateEnum.Start,StateEnum.Progress], destinationState: StateEnum.Progress)
        
        machine.addEvent(event)
        machine.fireEventNamed(EnumEvents.MakeProgress)
        
        XCTAssert(machine.isInState(.Progress))
    }
}
