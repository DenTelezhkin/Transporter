//
//  Transporter.swift
//  Transporter
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation

public struct Errors {
    public static let stateMachineDomain = "com.DenHeadless.StateMachine"
    
    public enum Transition: Int {
        case TransitionDeclined
        case UnknownEvent
        case WrongSourceState
    }
}

public class StateMachine<StateType:Hashable> {
    
    var initialState: State<StateType>?
    
    private var currentState : State<StateType>
    private lazy var availableStates : [State<StateType>] = []
    private lazy var events : [Event<StateType>] = []
    
    required public init(initialState: State<StateType>)
    {
        self.initialState = initialState
        self.currentState = initialState
        availableStates.append(initialState)
    }
    
    convenience public init(initialStateName: StateType)
    {
        self.init(initialState:State(initialStateName))
    }
    
    convenience public init(initialState: State<StateType>, states: [State<StateType>])
    {
        self.init(initialState: initialState)
        self.availableStates.extend(states)
    }
    
    public func activateState(stateValue: StateType) {
        self._activateState(stateValue)
    }
    
    public func isStateAvailable(stateValue: StateType) -> Bool {
        return _isStateAvailable(stateValue)
    }
    
    public func addState(state: State<StateType>) {
        availableStates.append(state)
    }
    
    public func addStates(states: [State<StateType>]) {
        availableStates.extend(states)
    }
    
    public func addEvent(event: Event<StateType>) -> Bool {
        return self._addEvent(event)
    }
    
    public func addEvents(events: [Event<StateType>]) {
        for event in events
        {
            let addingEvent = self.addEvent(event)
            if addingEvent == false {
                println("failed adding event with name: %@",event.name)
            }
        }
    }
    
    public func fireEvent(event: Event<StateType>) -> Transition<StateType> {
        return _fireEventNamed(event.name)
    }
    
    public func fireEvent(eventName: String) -> Transition<StateType> {
        return _fireEventNamed(eventName)
    }
    
    public func canFireEvent(event: Event<StateType>) -> (canFire: Bool, error: Errors.Transition?) {
        return _canFireEvent(event)
    }
    
    public func canFireEvent(eventName: String) -> (canFire: Bool, error: Errors.Transition?) {
        if let event = eventWithName(eventName)
        {
           return _canFireEvent(event)
        }
        return (false, Errors.Transition.UnknownEvent)
    }
    
    public func stateWithValue(value: StateType) -> State<StateType>? {
        return availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
    }
    
    public func eventWithName(name: String) -> Event<StateType>? {
        return events.filter { (element) -> Bool in
            return element.name == name
        }.first
    }
    
    public func isInState(stateValue: StateType) -> Bool {
        return stateValue == currentState.value
    }
}

private extension StateMachine {
    
    func _canFireEvent(event: Event<StateType>) -> (canFire: Bool, error: Errors.Transition?) {
        if !contains(events, event) {
            return (false,Errors.Transition.UnknownEvent)
        }
        if contains(event.sourceStates, currentState.value) {
                return (true,nil)
        }
        return (false,Errors.Transition.WrongSourceState)
    }
    
    func _fireEventNamed(eventName: String) -> Transition<StateType> {
        if let event = eventWithName(eventName) {
            let possibleTransition = canFireEvent(event)
            switch possibleTransition {
            case (true, _):
                if let shouldBlock = event.shouldFireEvent {
                    if shouldBlock(event: event) {
                        let sourceState = self.currentState
                        event.willFireEvent?(event: event)
                        activateState(event.destinationState)
                        event.didFireEvent?(event: event)
                        return Transition.Success(sourceState: sourceState, destinationState: self.currentState)
                    }
                    else {
                        return Transition.Error(NSError(domain: Errors.stateMachineDomain,
                            code: Errors.Transition.TransitionDeclined.rawValue, userInfo: nil))
                    }
                }
                else {
                    let sourceState = self.currentState
                    event.willFireEvent?(event: event)
                    activateState(event.destinationState)
                    event.didFireEvent?(event: event)
                    return Transition.Success(sourceState: sourceState, destinationState: self.currentState)
                }
            case (false, let error):
                return Transition.Error(NSError(domain: Errors.stateMachineDomain,
                    code:error!.rawValue,userInfo: nil))
            default:
                fatalError("Unknown transition error")
            }
        }
        else {
            return Transition.Error(NSError(domain: Errors.stateMachineDomain,
                code: Errors.Transition.UnknownEvent.rawValue, userInfo: nil))
        }
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
