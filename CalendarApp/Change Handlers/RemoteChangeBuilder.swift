//
//  RevisionBuilder.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/1/22.
//

import Foundation
import CoreData

@objcMembers
class RemoteChangeBuilder : NSObject, CreateRevisionDelegate {
    private var allChanges = Array<RemoteChange>()
    private var oldEvent: Event?
    private var newEvent: Event?
    private var timestamp: Date
    
    public required init(firstEvent: Event?,
                         updatedEvent: Event?,
                         updateDate: Date) {
        oldEvent = firstEvent
        newEvent = updatedEvent
        timestamp = updateDate
    }
    
    public func buildRemoteChanges() -> Array<RemoteChange> {
        guard let updatedEvent = newEvent else {
            let remoteChange = createRemoteChange()
            remoteChange.changeType = .Delete
            return allChanges
        }
        
        guard let originalEvent = oldEvent else {
            let remoteChange = createRemoteChange()
            remoteChange.changeType = .Create
            return allChanges
        }
        let builder = UpdateBuilder(firstEvent: originalEvent,
                                    updatedEvent: updatedEvent,
                                    inputDelegate: self)
        builder.checkFields()
        
        return allChanges
    }
    
    func createUpdateRevision() -> Revision {
        let newRemoteChange = createRemoteChange()
        newRemoteChange.changeType = .Update
        return newRemoteChange
    }
    
    func createRemoteChange() -> RemoteChange {
        let newRemoteChange = RemoteChange(updatedDate: timestamp)
        newRemoteChange.eventID = oldEvent != nil ? oldEvent?.objectUUID : newEvent?.objectUUID
        allChanges.append(newRemoteChange)
        return newRemoteChange
    }
}
