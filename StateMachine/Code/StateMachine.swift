//
//  StateMachine.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class StateMachine<StateType:Equatable> {
    
    private var currentState : State<StateType>?
    private var availableStates : [State<StateType>]
    
    init()
    {
        self.availableStates = []
    }
    
    convenience init(initialState: State<StateType>)
    {
        self.init()
        self.availableStates.append(initialState)
        self.currentState = initialState
    }
    
    func activateState(stateValue: StateType) {
        if (self.isStateAvailable(stateValue))
        {
            self.currentState = State(stateValue)
        }
    }
    
    func addState(state: State<StateType>) {
        self.availableStates.append(state)
    }
    
    func addStates(states: [State<StateType>])
    {
        self.availableStates.extend(states)
    }
    
    func isStateAvailable(state: StateType) -> Bool {
        if contains(self.availableStates,State(state)) {
            return true
        }
        return false
    }
    
    func isInState(state: StateType) -> Bool {
        return State(state) == currentState
    }
}
