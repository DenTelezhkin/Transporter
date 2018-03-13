# Change Log
All notable changes to this project will be documented in this file.

# Next

* Events can now trigger different transitions, even if they have the same name.
* State values are now required to be unique.
* `StateMachine.availableStates` property is now public.

## [3.0.1](https://github.com/DenHeadless/Transporter/releases/tag/3.0.1)

* Added SPM integration

## [3.0.0](https://github.com/DenHeadless/Transporter/releases/tag/3.0.0)

Swift 3 release. No API additions.

## [2.0.0](https://github.com/DenHeadless/Transporter/releases/tag/2.0.0)

Transporter 2.0 is a truly cross-platform release. Supported platforms:

* iOS
* OS X
* tvOS
* watchOS
* Linux in the future

## Changed

* Dropped Foundation dependency, NSError usage is replaced by Swift native ErrorType
* Transition .Error case now contains ErrorType
* `addEvent` method will now throw `EventError`, if conditions were not met.
* `canFireEvent(_:)` method now returns Bool instead of tuple.

## Added

* `possibleTransitionForEvent(_:)` method, that returns `Transition` object, identical to transition, that will happen if `fireEvent(_:)` method is called
* Proper documentation for all methods and properties.
