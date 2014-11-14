// Playground - noun: a place where people can play

import UIKit
import Transporter

enum TurnStile {
    case Locked
    case Unlocked
}

func lockEntrance()
{
    println("locked")
}

func unlockEntrance()
{
    println("unlocked")
}

let locked = State(TurnStile.Locked)
let unlocked = State(TurnStile.Unlocked)

locked.didEnterState = { _ in lockEntrance() }
unlocked.didEnterState = { _ in unlockEntrance() }

let coinEvent = Event(name: "Coin", sourceStates: [TurnStile.Locked], destinationState: TurnStile.Unlocked)
let pushEvent = Event(name: "Push", sourceStates: [TurnStile.Unlocked], destinationState: TurnStile.Locked)

let turnstile = StateMachine(initialState: locked, states: unlocked)
turnstile.addEvents([coinEvent,pushEvent])

turnstile.fireEvent("Coin")
turnstile.isInState(.Unlocked)
