// Playground - noun: a place where people can play

import UIKit
import Transporter

// Blake Watters TransitionKit example https://github.com/blakewatters/TransitionKit

func incrementUnreadCount() {
    println("Increment read count")
}

func decrementUnreadCount() {
    println("Decrement read count")
}

func moveMessageToTrash() {
    println("Move to trash")
}

let unread = State("Unread")
unread.didEnterState = { state in incrementUnreadCount() }

let read = State("Read")
read.didExitState = { state in decrementUnreadCount() }

let deleted = State("Deleted")
deleted.didEnterState = { state in moveMessageToTrash() }

let inboxMachine = StateMachine(initialState: unread)
inboxMachine.addStates([read, deleted])

let viewMessage = Event(name: "View message", sourceStates: ["Unread"],
    destinationState: "Read")
let deleteMessage = Event(name: "Delete message", sourceStates: ["Read","Unread"], destinationState: "Deleted")
let markUnread = Event(name: "Mark as unread", sourceStates: ["Read","Deleted"], destinationState: "Unread")

inboxMachine.addEvents([viewMessage,deleteMessage,markUnread])

inboxMachine.isInState("Unread") // Yes

let viewTransition = inboxMachine.fireEvent("View message")
if viewTransition.successful { println("Viewed message") }

let deleteTransition = inboxMachine.fireEvent("Delete message")
if deleteTransition.successful { println("Deleted") }

let markUnreadTransition = inboxMachine.fireEvent("Mark as unread")
if markUnreadTransition.successful { println("Marked as unread") }

inboxMachine.canFireEvent("Mark as unread") // No

let unreadTransition2 = inboxMachine.fireEvent("Mark as unread")
if !unreadTransition2.successful { println("Can't unread already unread message") }
