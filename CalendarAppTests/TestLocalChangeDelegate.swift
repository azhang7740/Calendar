//
//  TestLocalChangeDelegate.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
@testable import CalendarApp

class TestLocalChangeDelegate: LocalChangeSyncDelegate {
    func didDelete(_ event: Event) {
        
    }
    
    func didUpdate(_ oldEvent: Event, newEvent updatedEvent: Event) {
        
    }
    
    func didCreateEvent(_ newEvent: Event) {
        
    }
    
    func displayMessage(_ message: String) {
        
    }
}
