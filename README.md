Transporter 
==================

Transporter is a modern finite-state machine implemented in pure Swift. 

### Features

* Simple mode, allowing to manually switch states
* Strict mode, allowing switching states only with Events and proper Transition
* Closure(block)-based callbacks on states and events
* Generic implementation allows using any State values you need
* Unit-tested and reliable

### Classic turnstile example

```swift
enum TurnStile {
    case Locked
    case Unlocked
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
```

### States

Due to generic implementation, you can have StateMachine of any type you want. The only requirement for state values is they should be `Hashable`. So, you can have State<Int>, or State<String> etc. Or have value of enum, like it's shown in example.

```swift
let intState = State(0)
let stringState = State("foo")
let enumState = State(Turnstile.Locked)
```

Getting states 

```swift
  let state = machine.stateWithValue(4)
```

Adding states

```swift
  machine.addState(state)
  machine.addStates([state1,state2])
```

You can also use convenience constructor:

```swift
  let machine = StateMachine(initialState: initialState, states: [state1,state2])
```

### Events

Adding events implicitly checks, whether event source states and destination state are present in `StateMachine`. If states are not present, event will not be added to `StateMachine`.

```swift
  machine.addEvent(event)
  machine.addevents([event1,event2]
```

Can event be fired?

```swift
  if machine.canFireEvent("foo").0 {
    println("Fire it!")
  }
```

### Transitions

When event is fired, `StateMachine` returns Transition object, that you can react to

```swift
  let transition = machine.fireEvent("Coin")
  switch transition {
  case .Success(let sourceState, let destinationState):
    println("Successful transition from state: \(sourceState) to state: \(destinationState)")
  case .Error(let error)
    println("Failed to transition with error: \(error)")
  }
```

### Switching states manually

Transporter supports canonic finite state machine principle, that disallows transitions, if they are not defined in events `StateMachine` has, but sometimes you would want something simpler. Transporter gives you ability to switch states manually without actually creating any events.

```swift
  let initial = State("Initial")
  let machine = StateMachine(initialState: initial)
  machine.addState(State("Finished"))
  
  machine.activateState("Finished")
  machine.isInState("Finished") // true
```

### Objective-C

Due to generic implementation of Transporter, it will not support Objective-C. If you are looking for state machine, written in Objective-C, i recommend great [TransitionKit](https://github.com/blakewatters/TransitionKit) library by Blake Watters. 

### Requirements

* iOS 7,8 or Mac OS X Mavericks and higher
* Swift
* XCode 6.1

### Installation

Transporter will be distributed using CocoaPods, when support for Swift libraries [will be added](https://github.com/CocoaPods/CocoaPods/issues/2272)

For the next two options using git submodule is preferable:

* iOS 7 and higher - consider adding source files directly to the project, because XCode does not support using embedded frameworks for iOS 7
* iOS 8 and higher - you can use embedded Transporter.framework, that builds from Transporter.xcodeproj. It also builds Mac OS X framework.

