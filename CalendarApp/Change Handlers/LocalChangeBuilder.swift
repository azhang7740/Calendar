//
//  RevisionBuilder.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/1/22.
//

import Foundation
import CoreData

@objcMembers
class LocalChangeBuilder : NSObject, CreateRevisionDelegate {
    private var allChanges = [LocalChange]()
    private var oldEvent: Event?
    private var newEvent: Event?
    private var timestamp: Date
    private var context: NSManagedObjectContext
    
    public required init(firstEvent: Event?,
                         updatedEvent: Event?,
                         updateDate: Date,
                         managedContext: NSManagedObjectContext) {
        oldEvent = firstEvent
        newEvent = updatedEvent
        timestamp = updateDate
        context = managedContext
    }
    
    public func saveLocalChanges() {
        guard let updatedEvent = newEvent else {
            let localChange = createLocalChange()
            localChange.changeType = .Delete
            do {
                try context.save()
            } catch {
                // TODO: error handling
            }
            return
        }
        
        guard let originalEvent = oldEvent else {
            let localChange = createLocalChange()
            localChange.changeType = .Create
            do {
                try context.save()
            } catch {
                // TODO: error handling
            }
            return
        }
        let builder = UpdateBuilder(firstEvent: originalEvent,
                                    updatedEvent: updatedEvent,
                                    inputDelegate: self)
        builder.checkFields()
        
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    func createUpdateRevision() -> Revision {
        let newLocalChange = createLocalChange()
        newLocalChange.changeType = .Update
        return newLocalChange
    }
    
    func createLocalChange() -> LocalChange {
        let newLocalChange = LocalChange(context: context)
        newLocalChange.eventID = oldEvent != nil ? oldEvent?.objectUUID : newEvent?.objectUUID
        return newLocalChange
    }
}
