//
//  State.swift
//  Transporter
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation

public class State <StateType:Hashable>  {
    
    public let value : StateType
    
    public var willEnterState: ( (enteringState : State<StateType> ) -> Void)?
    public var didEnterState:  ( (enteringState : State<StateType> ) -> Void)?
    public var willExitState:  ( (exitingState  : State<StateType> ) -> Void)?
    public var didExitState:   ( (exitingState  : State<StateType> ) -> Void)?
    
    public init(_ value: StateType) {
        self.value = value
    }
}
