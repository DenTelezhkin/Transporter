//
//  State.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

class State<StateType:Equatable>: Equatable {
    
    let value : StateType
    
    var willEnterState: ((previousState : State<StateType>!)->Void)?
    
    init(_ value: StateType) {
        self.value = value
    }
}

func ==<StateType>(left: State<StateType>, right: State<StateType>) -> Bool {
    return left.value == right.value
}
