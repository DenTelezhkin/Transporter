//
//  Event.swift
//  Transporter
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation

public enum Transition<StateType:Hashable> {
    
    public var successful: Bool {
        switch self {
            case .Success(_,_):
                return true
        
            case .Error(_):
                return false
        }
    }
    
    case Success(State<StateType>, State<StateType>)
    case Error(NSError)
}

public class Event<StateType:Hashable> {
    
    public let name : String
    public let sourceStates: [StateType]
    public let destinationState: StateType
    
    public var shouldFireEvent: ( (event : Event) -> Bool )?
    public var willFireEvent:   ( (event : Event) -> Void )?
    public var didFireEvent:    ( (event : Event) -> Void )?
    
    required public init(name: String, sourceStates sources: [StateType], destinationState destination: StateType) {
        self.name = name
        self.sourceStates = sources
        self.destinationState = destination
    }
}

extension Event: Equatable {}

public func ==<StateType>(lhs:Event<StateType>,rhs:Event<StateType>) -> Bool {
    return lhs.name == rhs.name
}