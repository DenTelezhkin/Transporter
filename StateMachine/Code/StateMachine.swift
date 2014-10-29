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
    
    private var currentState : State<StateType>
    private lazy var availableStates : [State<StateType>] = []
    private lazy var events : [Event<StateType>] = []
    
    required init(initialState: State<StateType>)
    {
        self.initialState = initialState
        self.currentState = initialState
        availableStates.append(initialState)
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
    
    func addEvent(event: Event<StateType>) -> Bool {
        return self._addEvent(event)
    }
    
    func addEvents(events: [Event<StateType>]) {
        for event in events
        {
            let addingEvent = self.addEvent(event)
            if addingEvent == false {
                println("failed adding event with name: %@",event.name)
            }
        }
    }
    
    func fireEventNamed(eventName: StateType) {
        if let event = eventWithName(eventName) {
            if canFireEvent(event) {
                activateState(event.destinationState)
            }
        }
    }
    
    func canFireEvent(event: Event<StateType>) -> Bool{
        return self._canFireEvent(event)
    }
    
    func stateWithValue(value: StateType) -> State<StateType>? {
        return availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
    }
    
    func eventWithName(name: StateType) -> Event<StateType>? {
        return events.filter { (element) -> Bool in
            return element.name == name
        }.first
    }
    
    func isInState(stateValue: StateType) -> Bool {
        return stateValue == currentState.value
    }
}

private extension StateMachine {
    
    func _canFireEvent(event: Event<StateType>) -> Bool {
        if contains(event.sourceStates, currentState.value) {
            return true
        }
        return false
    }
    
    func _printMessage(message: String) {
        println("StateMachine: %@",message)
    }
    
    // private
    func _isStateAvailable(stateValue: StateType) -> Bool {
        let states = availableStates.filter { (element) -> Bool in
            return element.value == stateValue
        }
        if !states.isEmpty {
            return true
        }
        return false
    }
    
    func _activateState(stateValue: StateType) {
        if (isStateAvailable(stateValue))
        {
            let oldState = currentState
            let newState = stateWithValue(stateValue)!
            
            newState.willEnterState?(enteringState: newState)
            oldState.willExitState?(exitingState: oldState)
            
            currentState = newState
            
            oldState.didExitState?(exitingState: oldState)
            newState.didEnterState?(enteringState: currentState)
        }
    }
    
    func _addEvent(event: Event<StateType>) -> Bool {
        if event.sourceStates.isEmpty
        {
            _printMessage("Source states array is empty, when trying to add event.")
            return false
        }
        
        for state in event.sourceStates
        {
            if (self.stateWithValue(state) == nil)
            {
                _printMessage("Source state with value \(state) is not present")
                return false
            }
        }
        if (self.stateWithValue(event.destinationState) == nil) {
            _printMessage("Destination state with value: \(event.destinationState)) does not exist")
            return false
        }
        
        self.events.append(event)
        return true
    }
}
