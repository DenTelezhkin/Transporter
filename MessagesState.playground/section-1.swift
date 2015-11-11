// Playground - noun: a place where people can play

import Transporter

// Blake Watters TransitionKit example https://github.com/blakewatters/TransitionKit

func incrementUnreadCount() {
    print("Increment read count")
}

func decrementUnreadCount() {
    print("Decrement read count")
}

func moveMessageToTrash() {
    print("Move to trash")
}

let unread = State("Unread")
unread.didEnterState = { state in incrementUnreadCount() }

let read = State("Read")
read.didExitState = { state in decrementUnreadCount() }

let deleted = State("Deleted")
deleted.didEnterState = { state in moveMessageToTrash() }

let inboxMachine = StateMachine(initialState: unread, states: [read,deleted])

let viewMessage = Event(name: "View message", sourceStates: ["Unread"],
    destinationState: "Read")
let deleteMessage = Event(name: "Delete message", sourceStates: ["Read","Unread"], destinationState: "Deleted")
let markUnread = Event(name: "Mark as unread", sourceStates: ["Read","Deleted"], destinationState: "Unread")

inboxMachine.addEvents([viewMessage,deleteMessage,markUnread])

inboxMachine.isInState("Unread") // Yes

let viewTransition = inboxMachine.fireEvent("View message")
if viewTransition.successful { print("Viewed message") }

let deleteTransition = inboxMachine.fireEvent("Delete message")
if deleteTransition.successful { print("Deleted") }

let markUnreadTransition = inboxMachine.fireEvent("Mark as unread")
if markUnreadTransition.successful { print("Marked as unread") }

inboxMachine.canFireEvent("Mark as unread") // No

let unreadTransition2 = inboxMachine.fireEvent("Mark as unread")
if !unreadTransition2.successful { print("Can't unread already unread message") }
