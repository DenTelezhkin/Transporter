//
//  Event.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

enum Transition<StateType:Hashable> {
    
    var successful: Bool {
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

class Event<StateType:Hashable> {
    
    let name : String
    let sourceStates: [StateType]
    let destinationState: StateType
    
    var shouldFireEvent: ( (event : Event) -> Bool )?
    var willFireEvent:   ( (event : Event) -> Void )?
    var didFireEvent:    ( (event : Event) -> Void )?
    
    required init(name: String, sourceStates sources: [StateType], destinationState destination: StateType) {
        self.name = name
        self.sourceStates = sources
        self.destinationState = destination
    }
}

extension Event: Equatable {}

func ==<StateType>(lhs:Event<StateType>,rhs:Event<StateType>) -> Bool {
    return lhs.name == rhs.name
}