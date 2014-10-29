//
//  Event.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 28.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class Event<StateType:Hashable> {
    
    let name : StateType
    let sourceStates: [StateType]
    let destinationState: StateType
    
    var shouldFireEvent: ( (event : Event) -> Bool )?
    var willFireEvent:   ( (event : Event) -> Void )?
    var didFireEvent:    ( (event : Event) -> Void )?
    
    required init(name: StateType, sourceStates sources: [StateType], destinationState destination: StateType) {
        self.name = name
        self.sourceStates = sources
        self.destinationState = destination
    }
    
}
