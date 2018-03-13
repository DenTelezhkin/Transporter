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

/**
Enum with possible transition errors. These are meant to be used inside fireEvent method on StateMachine. They will be included as status codes inside NSError, that Transition.Error enum returns.
*/
public enum TransitionError: Error {
    /**
        When event's shouldFireEvent closure returns false, `TransitionDeclined` error will be returned as a status code inside NSError object.
    */
    case transitionDeclined
    
    /**
        `UnknownEvent` means there's no such event on `StateMachine`.
    */
    case unknownEvent
    
    /**
        `WrongSourceState` means, that source states for this fired event do not include state, in which StateMachine is currently in.
    */
    case wrongSourceState
    
    /// `WrongType` means, that Event states don't match `StateMachine` or `State` type T.
    case wrongEventType
}

/// This enum contains events, that can happen when adding event to state machine.
public enum EventError: Error {
    
    /// `NoSourceValue` means, that when adding `Event` to `StateMachine` one of source state values of event was not present on state machine
    case noSourceValue
    
    /// `NoDestinationValue` means, that when adding `Event` to `StateMachine` destination state value of event was not present on state machine
    case noDestinationValue
}

/// `StateMachine` is a state machine, obviously =).
open class StateMachine<T:Hashable> {
    
    /// Initial state of state machine.
    var initialState: State<T>
    
    /// Current state of state machine
    open private(set) var currentState : State<T>
    
    /// Available states in state machine
    public private(set) lazy var availableStates : [State<T>] = []
    
    /// Available events in state machine
    private lazy var events : [Event<T>] = []
    
    /// Create `StateMachine` with initialState
    /// - Parameter initialState: initial state of state machine
    required public init(initialState: State<T>)
    {
        self.initialState = initialState
        self.currentState = initialState
        addState(initialState)
    }
    
    /// Create `StateMachine` with initialState value
    /// - Parameter initialStateValue: initial state value.
    convenience public init(initialStateValue: T)
    {
        self.init(initialState:State(initialStateValue))
    }
    
    /// Create `StateMachine` with initialState and array of states
    /// - Parameter initialState: initial state.
    /// - Parameter states: Array of states of state machine
    /// - Discussion: Initial state can be omitted from list of states, because it will already be added from first parameter.
    convenience public init(initialState: State<T>, states: [State<T>])
    {
        self.init(initialState: initialState)
        addStates(states)
    }
    
    /// Activate state, if it's present in `StateMachine`. This method is not tied to events, present in StateMachine.
    /// - Parameter stateValue: value of state to switch to.
    /// - Note: This method basically breaks conditional finite-state machine rules, because it does not check any conditions between states. However, it allows more simple state-machine usage, if you don't need complicated events system.
    open func activateState(_ stateValue: T) {
        if (isStateAvailable(stateValue))
        {
            let oldState = currentState
            let newState = stateWithValue(stateValue)!
            
            newState.willEnterState?(newState)
            oldState.willExitState?(oldState)
            
            currentState = newState
            
            oldState.didExitState?(oldState)
            newState.didEnterState?(currentState)
        }
    }
    
    /// If state is present in available states in `StateMachine`, this method will return true. This method does not check events on `StateMachine`.
    /// - Parameter stateValue: value of state to check availability for.
    open func isStateAvailable(_ stateValue: T) -> Bool {
        let states = availableStates.filter { (element) -> Bool in
            return element.value == stateValue
        }
        if !states.isEmpty {
            return true
        }
        return false
    }
    
    /// Add state to array of available states
    /// - Parameter state: state to add
    open func addState(_ state: State<T>) {
        addStates([state])
    }
    
    /// Add array of states
    /// - Parameter states: states array.
    open func addStates(_ states: [State<T>]) {
        let availableStateNames = Set(availableStates.map { $0.value })
        availableStates.append(contentsOf: states.filter { !availableStateNames.contains($0.value) })
    }
    
    /// Add event to `StateMachine`. This method checks, whether source states and destination state of event are present in `StateMachine`. If not - event will not be added, and this method will throw.
    /// - Parameter event: event to add.
    /// - Throws: `EventError` if event cannot be added.
    open func addEvent(_ event: Event<T>) throws {
        if event.sourceValues.isEmpty
        {
            throw EventError.noSourceValue
        }
        
        for state in event.sourceValues
        {
            if (self.stateWithValue(state) == nil)
            {
                throw EventError.noSourceValue
            }
        }
        if (self.stateWithValue(event.destinationValue) == nil) {
            throw EventError.noDestinationValue
        }
        
        self.events.append(event)
    }
    
    /// Add events to `StateMachine`. This method checks, whether source states and destination state of event are present in `StateMachine`. If not - event will not be added.
    /// - Parameter events: events to add to `StateMachine`.
    open func addEvents(_ events: [Event<T>]) {
        for event in events
        {
            guard let _ = try? self.addEvent(event) else {
                print("failed adding event with name: %@",event.name)
                continue
            }
        }
    }
    
    /**
        Fires event. Several checks are made along the way:
    
        1. Event is present in StateMachine. If not - error includes UnknownEvent transition error
        2. Event source states include current StateMachine state. If not - error includes WrongSourceState transition error
        3. Event shouldFireEvent closure is fired. If it returned false - error includes TransitionDeclined transition error.
    
        If all conditions passed, event is fired, all closures are fired, and StateMachine changes it's state to event.destinationState.
     
     - parameter event: event to fire
     - returns: `Transition` object.
    */
    @discardableResult
    open func fireEvent(_ event: Event<T>) -> Transition<T> {
        return _fireEventNamed(event.name)
    }
    
    /// This method is a convenience shortcut to fireEvent(event: Event<StateType>) method above.
    /// - Parameter eventName: name of event to fire.
    /// - Returns: `Transition` object.
    @discardableResult
    open func fireEvent(_ eventName: String) -> Transition<T> {
        return _fireEventNamed(eventName)
    }
    
    /// Returns, whether event can be fired (event is present on state machine, current state is in list of available states)
    /// - Parameter event: Event
    /// - Returns: whether event can be fired
    open func canFireEvent(_ event: Event<T>) -> Bool {
        let possibleTransition = possibleTransitionForEvent(event)
        if case .error(_) = possibleTransition {
            return false
        }
        return true
    }
    
    /** 
     This method checks all conditions mentioned in fireEvent method, and returns Bool.
     
     - Parameter eventName: name of event that could be fired
     - Returns: true, if event can be fired, false if don't
    */
    open func canFireEvent(_ eventName: String) -> Bool {
        let events = eventsWithName(eventName)
        return events.contains { (event) -> Bool in
            return canFireEvent(event)
        }
    }
    
    /**
        Retrieve possible transition for event. This transition is a representation of transition, that will happen, if event will be fired. `StateMachine` does not change it's state when this method is called.
     - Parameter event: event that could be fired.
     - Returns: `Transition` object.
     */
    open func possibleTransitionForEvent(_ event: Event<T>) -> Transition<T> {
        if !events.contains(event) {
            return .error(.unknownEvent)
        }
        if event.sourceValues.contains(currentState.value) {
            return Transition.success(sourceState: currentState, destinationState: State(event.destinationValue))
        }
        return .error(.wrongSourceState)
    }
    
    /**
        Retrieve state with specific value.
     
     - Parameter value: value of state to search for
     - Returns: state, if found.
     */
    open func stateWithValue(_ value: T) -> State<T>? {
        return availableStates.filter { (element) -> Bool in
            return element.value == value
        }.first
    }
    
    /// Retrieve events with specific name
    /// - Parameter name: Name of the event
    /// - Returns: events with specified name, if found.
    open func eventsWithName(_ name: String) -> [Event<T>] {
        return events.filter { element in
            return element.name == name
        }
    }
    
    /// Retrieve event with specific name
    /// - Parameter name: Name of the event
    /// - Returns: event, if found.
    open func eventWithName(_ name: String) -> Event<T>? {
        return eventsWithName(name).first
    }
    
    /// Check, whether state machine is in concrete state
    /// - Parameter stateValue: value of state to check for
    /// - Returns: whether state machine is in this state.
    open func isInState(_ stateValue: T) -> Bool {
        return stateValue == currentState.value
    }
}

private extension StateMachine {
    
    /**
     Fire event with name. Several checks are made along the way.
     
     1. If no event found with this name, .UnknownEvent error is returned
     2. possibleTransitionForEvent(_:) method is calledm of it errors, it is immediately returned
     3. shouldFireEvent block is run, if it fails, .TransitionDeclined error is returned.
     4. Event is fired, triggering willFireEvent and didFireEvent closures. All state enter and exit closures are also run.
     
     - Parameter eventName: name of event to fire
     - Returns: `Transition` object.
     */
    ///
    func _fireEventNamed(_ eventName: String) -> Transition<T> {
        let events = eventsWithName(eventName)
        guard !events.isEmpty else { return .error(.unknownEvent) }

        for event in events {
            let possibleTransition = possibleTransitionForEvent(event)
            switch possibleTransition {
            case .success(let sourceState, let destinationState):
                let processState = { () -> Transition<T> in
                    event.willFireEvent?(event)
                    self.activateState(event.destinationValue)
                    event.didFireEvent?(event)
                    return .success(sourceState: sourceState, destinationState: destinationState)
                }

                if let shouldBlock = event.shouldFireEvent {
                    if shouldBlock(event) {
                        return processState()
                    }
                    else {
                        return .error(.transitionDeclined)
                    }
                }
                else {
                    return processState()
                }
            default:
                break
            }
        }

        return .error(.wrongSourceState)
    }
}
