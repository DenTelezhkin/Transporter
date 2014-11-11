//
//  State.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

class State <StateType:Hashable>  {
    
    let value : StateType
    
    var willEnterState: ( (enteringState : State<StateType> ) -> Void)?
    var didEnterState:  ( (enteringState : State<StateType> ) -> Void)?
    var willExitState:  ( (exitingState  : State<StateType> ) -> Void)?
    var didExitState:   ( (exitingState  : State<StateType> ) -> Void)?
    
    init(_ value: StateType) {
        self.value = value
    }
}
