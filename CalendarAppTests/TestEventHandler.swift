//
//  TestEventHandler.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 7/27/22.
//

import Foundation
@testable import CalendarApp

class TestEventHandler: EventHandler {
    var wasQueryEventsCalled = false
    var wasUploadEventsCalled = false
    var wasUpdateEventsCalled = false
    var wasDeleteEventsCalled = false
    
    func queryEvents(on date: Date, completion: @escaping EventQueryCompletion) {
        wasQueryEventsCalled = true
    }
    
    func upload(with newEvent: Event, completion: @escaping RemoteEventChangeCompletion) {
        wasUploadEventsCalled = true
    }
    
    func update(_ event: Event, completion: @escaping RemoteEventChangeCompletion) {
        wasUpdateEventsCalled = true
    }
    
    func delete(_ event: Event, completion: @escaping RemoteEventChangeCompletion) {
        wasDeleteEventsCalled = true
    }
}
