//
//  StateMachine.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class StateMachine<StateType:Hashable> {
    
    var initialState: State<StateType>?
    
    var allowOnlyValidTransitions = false
    
    private var currentState : State<StateType>?
    private lazy var availableStates : [State<StateType>] = []
    private lazy var validTransitions : [ [StateType:[StateType]] ] = []
    
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
        self._activateState(stateValue)
    }
    
    func isStateAvailable(stateValue: StateType) -> Bool {
        return _isStateAvailable(stateValue)
    }
    
    func addState(state: State<StateType>) {
        availableStates.append(state)
    }
    
    func addStates(states: [State<StateType>]) {
        availableStates.extend(states)
    }
    
    func addTransitions(fromState: StateType, toStates:[StateType]) {
        self.validTransitions.append([fromState:toStates])
    }
    
    func stateWithValue(value: StateType) -> State<StateType>? {
        let state = availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
        
        return state
    }
    
    func isInState(stateValue: StateType) -> Bool {
        return stateValue == currentState?.value
    }
}

private extension StateMachine {
    
    // private
    func _isStateAvailable(stateValue: StateType) -> Bool {
        let states = availableStates.filter { (element) -> Bool in
            return element.value == stateValue
        }
        if !states.isEmpty {
            
            if !allowOnlyValidTransitions { return true }
            
            let state = states.first
            
            let transitions = self.validTransitions.filter({ (transition) -> Bool in
                if let sourceState = transition.keys.first {
                    let destinationStates = transition[sourceState]
                    return contains(destinationStates!, state!.value)
                }
                return false
            })
            if (!transitions.isEmpty) { return true }
            
            return false
        }
        return false
    }
    
    func _activateState(stateValue: StateType) {
        if (isStateAvailable(stateValue))
        {
            let oldState = currentState
            let newState = stateWithValue(stateValue)!
            
            newState.willEnterState?(enteringState: newState)
            
            if oldState != nil {
                oldState!.willExitState?(exitingState: oldState)
            }
            
            currentState = newState
            
            if oldState != nil {
                oldState!.didExitState?(exitingState: oldState)
            }
            
            newState.didEnterState?(enteringState: currentState)
        }
    }
}
