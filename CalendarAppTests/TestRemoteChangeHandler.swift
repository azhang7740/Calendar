//
//  TestEventChangeHandler.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 7/29/22.
//

import Foundation
@testable import CalendarApp

class TestRemoteChangeHandler: RemoteChangeHandler {
    var wasQueryChangesCalled = false
    var wasDeleteRevisionCalled = false
    var wasDeleteChangeCalled = false
    var wasCreateRevisionCalled = false
    var wasCreateChangeCalled = false
    var wasPartialDeleteCalled = false;
    
    func queryChanges(afterUpdate date: Date, completion: @escaping ChangeQueryCompletion) {
        wasQueryChangesCalled = true
    }

    func deleteRevisionHistory(_ eventID: UUID, completion: @escaping ChangeActionCompletion) {
        wasDeleteRevisionCalled = true
    }
    
    func deleteParseChange(_ changeID: String, completion: @escaping ChangeActionCompletion) {
        wasDeleteChangeCalled = true
    }
    
    func addNewRevisionHistory(_ eventID: UUID, change: RemoteChange, completion: @escaping ChangeActionCompletion) {
        wasCreateRevisionCalled = true
    }
    
    func addNewParseChange(_ remoteChange: RemoteChange, completion: @escaping ChangeActionCompletion) {
        wasCreateChangeCalled = true
    }
    
    func partiallyDeleteRevisionHistory(_ eventID: UUID, remoteChange change: RemoteChange, completion: @escaping ChangeActionCompletion) {
        wasPartialDeleteCalled = true
    }
}
