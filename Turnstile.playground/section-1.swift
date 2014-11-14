// Playground - noun: a place where people can play

import UIKit
import Transporter

enum Turnstile {
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

let locked = State(Turnstile.Locked)
let unlocked = State(Turnstile.Unlocked)

locked.didEnterState = { _ in lockEntrance() }
unlocked.didEnterState = { _ in unlockEntrance() }

let coinEvent = Event(name: "Coin", sourceStates: [Turnstile.Locked], destinationState: Turnstile.Unlocked)
let pushEvent = Event(name: "Push", sourceStates: [Turnstile.Unlocked], destinationState: Turnstile.Locked)

let turnstile = StateMachine(initialState: locked, states: unlocked)
turnstile.addEvents([coinEvent,pushEvent])

turnstile.fireEvent("Coin")
turnstile.isInState(.Unlocked)
