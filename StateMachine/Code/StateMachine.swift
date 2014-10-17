//
//  StateMachine.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class StateMachine<StateType:Equatable> {
    
    var initialState: State<StateType>?
    
    private var currentState : State<StateType>?
    private lazy var availableStates : [State<StateType>] = []
    
    convenience init(initialState: State<StateType>)
    {
        self.init()
        availableStates.append(initialState)
        self.initialState = initialState
        currentState = initialState
    }
    
    func activate() {
        if let initial = initialState {
            currentState = initialState
        }
    }
    
    func activateState(stateValue: StateType) {
        if (isStateAvailable(stateValue))
        {
            let nextState = stateWithValue(stateValue)!
            if nextState.willEnterState != nil {
               nextState.willEnterState!(previousState: currentState!)
            }
            
            currentState = nextState
            
            if nextState.didEnterState != nil {
                nextState.didEnterState!()
            }
        }
    }
    
    func addState(state: State<StateType>) {
        availableStates.append(state)
    }
    
    func addStates(states: [State<StateType>])
    {
        availableStates.extend(states)
    }
    
    func stateWithValue(value: StateType) -> State<StateType>? {
        let state = availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
        
        return state
    }
    
    func isStateAvailable(state: StateType) -> Bool {
        let states = availableStates.filter { (element) -> Bool in
            return element.value == state
        }
        if !states.isEmpty {
            return true
        }
        return false
    }
    
    func isInState(stateValue: StateType) -> Bool {
        return stateValue == currentState?.value
    }
}
