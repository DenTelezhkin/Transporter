//
//  StateMachine.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class StateMachine<StateType:Equatable> {
    
    private var currentState : State<StateType>
    
    init(initialState: State <StateType>)
    {
        self.currentState = initialState
    }
    
    func activateState(state: State<StateType>) {
        self.currentState = state
    }
    
    func isInState(state: State<StateType>) -> Bool {
        return state == currentState
    }
}
