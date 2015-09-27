//
//  Transporter.swift
//  Transporter
//
//  Created by Denys Telezhkin on 14.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public struct Errors {
    public static let stateMachineDomain = "com.DenHeadless.StateMachine"
    
    /**
        Enum with possible transition errors. These are meant to be used inside fireEvent method on StateMachine. They will be included as status codes inside NSError, that Transition.Error enum returns.
    */
    public enum Transition: Int {
        
        /**
            When event's shouldFireEvent closure returns false, `TransitionDeclined` error will be returned as a status code inside NSError object.
        */
        case TransitionDeclined
        
        /**
            `UnknownEvent` means there's no such event on `StateMachine`.
        */
        case UnknownEvent
        
        /**
            `WrongSourceState` means, that source states for this fired event do not include state, in which StateMachine is currently in.
        */
        case WrongSourceState
    }
}

public class StateMachine<T:Hashable> {
    
    var initialState: State<T>?
    
    private var currentState : State<T>
    private lazy var availableStates : [State<T>] = []
    private lazy var events : [Event<T>] = []
    
    required public init(initialState: State<T>)
    {
        self.initialState = initialState
        self.currentState = initialState
        availableStates.append(initialState)
    }
    
    convenience public init(initialStateName: T)
    {
        self.init(initialState:State(initialStateName))
    }
    
    convenience public init(initialState: State<T>, states: [State<T>])
    {
        self.init(initialState: initialState)
        self.availableStates.appendContentsOf(states)
    }
    
    /**
        Activate state, if it's present in `StateMachine`. This method is not tied to events, present in StateMachine.
    */
    public func activateState(stateValue: T) {
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
    
    /**
        If state is present in available states in `StateMachine`, this method will return true. This method does not check events on `StateMachine`.
    */
    public func isStateAvailable(stateValue: T) -> Bool {
        let states = availableStates.filter { (element) -> Bool in
            return element.value == stateValue
        }
        if !states.isEmpty {
            return true
        }
        return false
    }
    
    public func addState(state: State<T>) {
        availableStates.append(state)
    }
    
    public func addStates(states: [State<T>]) {
        availableStates.appendContentsOf(states)
    }
    
    /**
        Add event to `StateMachine`. This method checks, whether source states and destination state of event are present in `StateMachine`. If not - event will not be added, and this method will return false.
    */
    public func addEvent(event: Event<T>) -> Bool {
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
    
    /**
    Add events to `StateMachine`. This method checks, whether source states and destination state of event are present in `StateMachine`. If not - event will not be added.
    */
    public func addEvents(events: [Event<T>]) {
        for event in events
        {
            let addingEvent = self.addEvent(event)
            if addingEvent == false {
                print("failed adding event with name: %@",event.name)
            }
        }
    }
    
    /**
        Fires event. Several checks are made along the way:
    
        1. Event is present in StateMachine. If not - error includes UnknownEvent transition error
        2. Event source states include current StateMachine state. If not - error includes WrongSourceState transition error
        3. Event shouldFireEvent closure is fired. If it returned false - error includes TransitionDeclined transition error.
    
        If all conditions passed, event is fired, all closures are fired, and StateMachine changes it's state to event.destinationState.
    */
    public func fireEvent(event: Event<T>) -> Transition<T> {
        return _fireEventNamed(event.name)
    }
    
    /**
        This method is a convenience shortcut to fireEvent(event: Event<StateType>) method above.
    */
    public func fireEvent(eventName: String) -> Transition<T> {
        return _fireEventNamed(eventName)
    }
    
    public func canFireEvent(event: Event<T>) -> (canFire: Bool, error: Errors.Transition?) {
        if !events.contains(event) {
            return (false,Errors.Transition.UnknownEvent)
        }
        if event.sourceStates.contains(currentState.value) {
            return (true,nil)
        }
        return (false,Errors.Transition.WrongSourceState)
    }
    
    /**
        This method checks all conditions mentioned in fireEvent method, and returns tuple.
    
        If first value of tuple is true, then event can be fired, if false - second parameter will include reason why event cannot be fired.
    */
    public func canFireEvent(eventName: String) -> (canFire: Bool, error: Errors.Transition?) {
        if let event = eventWithName(eventName)
        {
           return canFireEvent(event)
        }
        return (false, Errors.Transition.UnknownEvent)
    }
    
    public func stateWithValue(value: T) -> State<T>? {
        return availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
    }
    
    public func eventWithName(name: String) -> Event<T>? {
        return events.filter { (element) -> Bool in
            return element.name == name
        }.first
    }
    
    public func isInState(stateValue: T) -> Bool {
        return stateValue == currentState.value
    }
}

private extension StateMachine {
    
    func _fireEventNamed(eventName: String) -> Transition<T> {
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
            }
        }
        else {
            return Transition.Error(NSError(domain: Errors.stateMachineDomain,
                code: Errors.Transition.UnknownEvent.rawValue, userInfo: nil))
        }
    }
    
    func _printMessage(message: String) {
        print("StateMachine: %@",message)
    }
}
