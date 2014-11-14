//
//  AppDelegate.swift
//  Transporter
//
//  Created by Denys Telezhkin on 06.07.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import Transporter

enum TurnStile {
    case Locked
    case Unlocked
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        // Turnstile example
        
        let locked = State(TurnStile.Locked)
        let unlocked = State(TurnStile.Unlocked)
        
        locked.didEnterState = { _ in self.lockEntrance() }
        unlocked.didEnterState = { _ in self.unlockEntrance() }
        
        let turnstile = StateMachine(initialState: locked)
        turnstile.addState(unlocked)
        
        let coinEvent = Event(name: "Coin", sourceStates: [TurnStile.Locked], destinationState: TurnStile.Unlocked)
        let pushEvent = Event(name: "Push", sourceStates: [TurnStile.Unlocked], destinationState: TurnStile.Locked)
        
        turnstile.addEvents([coinEvent,pushEvent])
        
        // Blake Watters TransitionKit example https://github.com/blakewatters/TransitionKit
        
        let unread = State("Unread")
        unread.didEnterState = { state in self.incrementUnreadCount() }
        
        let read = State("Read")
        read.didExitState = { state in self.decrementUnreadCount() }
        
        let deleted = State("Deleted")
        deleted.didEnterState = { state in self.moveMessageToTrash() }
        
        let inboxMachine = StateMachine(initialState: unread)
        inboxMachine.addStates([read, deleted])
        
        let viewMessage = Event(name: "View message", sourceStates: ["Unread"],
            destinationState: "Read")
        let deleteMessage = Event(name: "Delete message", sourceStates: ["Read","Unread"], destinationState: "Deleted")
        let markUnread = Event(name: "Mark as unread", sourceStates: ["Read","Deleted"], destinationState: "Unread")
        
        inboxMachine.addEvents([viewMessage,deleteMessage,markUnread])
        
        inboxMachine.isInState("Unread") // Yes
    
        let viewTransition = inboxMachine.fireEventNamed("View message")
        if viewTransition.successful { println("Viewed message") }
        
        let deleteTransition = inboxMachine.fireEventNamed("Delete message")
        if deleteTransition.successful { println("Deleted") }
        
        let markUnreadTransition = inboxMachine.fireEventNamed("Mark as unread")
        if markUnreadTransition.successful { println("Marked as unread") }
        
        inboxMachine.canFireEvent("Mark as unread") // No
        
        let unreadTransition2 = inboxMachine.fireEventNamed("Mark as unread")
        if !unreadTransition2.successful { println("Can't unread already unread message") }
        
        return true
    }
    
    func lockEntrance() {
        println("locked")
    }
    
    func unlockEntrance() {
        println("unlocked")
    }
    
    func incrementUnreadCount() {
        println("Increment read count")
    }
    
    func decrementUnreadCount() {
        println("Decrement read count")
    }
    
    func moveMessageToTrash() {
        println("Move to trash")
    }

}

