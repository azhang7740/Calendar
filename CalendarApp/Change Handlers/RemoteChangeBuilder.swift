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
    private var eventID: UUID?
    
    public required init(firstEvent: Event?,
                         updatedEvent: Event?,
                         updateDate: Date) {
        oldEvent = firstEvent
        newEvent = updatedEvent
        timestamp = updateDate
    }
    
    public required init(eventUUID: UUID,
                         updateDate: Date) {
        timestamp = updateDate
        eventID = eventUUID
    }
    
    public func buildDeleteChangeFromEventID() -> RemoteChange {
        let newRemoteChange = RemoteChange(updatedDate: timestamp)
        newRemoteChange.changeType = .Delete
        newRemoteChange.eventID = eventID
        return newRemoteChange
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
    
    func createUpdateRevision(changeField: ChangeField) -> Revision {
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
