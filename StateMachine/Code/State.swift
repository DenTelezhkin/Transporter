//
//  State.swift
//  StateMachine
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import Foundation

func == (left:State,right:State) -> Bool {
    return left.value == right.value
}

class State<T:Equatable> : Equatable{
    
    let backingVar: T[]
    
    var value: T {
        get {
            return backingVar[0]
        }
    
        set(newValue) {
            backingVar[0] = newValue
        }
    }
    
    init(_ value: T) {
        self.backingVar = [value]
    }
}
