//
//  Event.swift
//  Transporter
//
//  Created by Denys Telezhkin on 28.10.14.
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
    Instance of enum is returned from fireEvent method on StateMachine. Use it to determine, whether transition was successful.
*/
public enum Transition<T:Hashable> {
    
    /**
        Returns whether transition was successful
    */
    public var successful: Bool {
        switch self {
            case .success(_,_):
                return true
        
            case .error(_):
                return false
        }
    }
    
    /**
        Success case with source state, from which transition happened, and destination state, to which state machine switched
    */
    case success(sourceState: State<T>, destinationState: State<T>)
    
    /**
        Error case, containing error. Error domain and status codes are described in Errors struct.
    */
    case error(TransitionError)
}

/**
    `Event` class encapsulates some event with array of possible source states and one destination state, to which state machine should transition, when this event fires.
*/
public class Event<T:Hashable> {
    
    /// Name of event
    public let name : String
    
    /// Array of source values, in which event can be fired
    public let sourceValues: [T]
    
    /// Destination value for state, to which state machine will switch after firing event.
    public let destinationValue: T
    
    ///  If this closure return value is false, event will not be fired
    public var shouldFireEvent: ( (event : Event) -> Bool )?
    
    /// This closure will be executed before event is fired.
    public var willFireEvent:   ( (event : Event) -> Void )?
    
    /// This closure will be executed after event was fired.
    public var didFireEvent:    ( (event : Event) -> Void )?
    
    /// Initializer for Event.
    /// - Parameter name: name of the event
    /// - Parameter sourceValues: Array of source values, in which event can be fired
    /// - Parameter destinationValue: Destination state value
    required public init(name: String, sourceValues sources: [T], destinationValue destination: T) {
        self.name = name
        self.sourceValues = sources
        self.destinationValue = destination
    }
}

extension Event: Equatable {}

/// Returns true, if events have the same name
public func ==<T>(lhs:Event<T>,rhs:Event<T>) -> Bool {
    return lhs.name == rhs.name
}
