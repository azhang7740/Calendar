//
//  RevisionBuilder.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/1/22.
//

import Foundation
import CoreData

@objc protocol LocalChangeBuildDelegate {
    func didOfflineDelete(event: Event)
    func wasAlreadyCreated(event: Event) -> Bool
}

@objcMembers
class LocalChangeBuilder : NSObject, CreateRevisionDelegate {
    private var updateLocalChanges = [LocalChange]()
    private var oldEvent: Event?
    private var newEvent: Event?
    private var timestamp: Date
    private var context: NSManagedObjectContext
    private var delegate: LocalChangeBuildDelegate
    private var eventID: UUID?
    
    public required init(firstEvent: Event?,
                         updatedEvent: Event?,
                         updateDate: Date,
                         managedContext: NSManagedObjectContext,
                         localChangeDelegate: LocalChangeBuildDelegate) {
        oldEvent = firstEvent
        newEvent = updatedEvent
        timestamp = updateDate
        context = managedContext
        delegate = localChangeDelegate
    }
    
    public func saveLocalChanges() {
        guard let updatedEvent = newEvent else {
            guard let originalEvent = oldEvent else {
                return
            }
            if !delegate.wasAlreadyCreated(event: originalEvent) {
                delegate.didOfflineDelete(event: originalEvent)
                let localChange = createLocalChange()
                localChange.changeType = .Delete
                do {
                    try context.save()
                } catch {
                    // TODO: error handling
                }
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
        localChangesWithUpdate(originalEvent: originalEvent,
                               updatedEvent: updatedEvent)
        
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    private func localChangesWithUpdate(originalEvent: Event,
                                        updatedEvent: Event) {
        if delegate.wasAlreadyCreated(event: updatedEvent) {
            let localChange = createLocalChange()
            localChange.changeType = .Create
        } else {
            let builder = UpdateBuilder(firstEvent: originalEvent,
                                        updatedEvent: updatedEvent,
                                        inputDelegate: self)
            builder.checkFields()
        }
    }
    
    func createUpdateRevision(changeField: ChangeField) -> Revision {
        let request = LocalChange.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@ AND changeField == %@",
                                        newEvent!.objectUUID as CVarArg,
                                        NSNumber(value: Int(changeField.rawValue)))
        do {
            let matchingChanges = try context.fetch(request)
            for change in matchingChanges {
                context.delete(change)
            }
        }  catch {
            // TODO: error handling
        }
        let newLocalChange = createLocalChange()
        newLocalChange.changeType = .Update
        updateLocalChanges.append(newLocalChange)
        return newLocalChange
    }
    
    func createLocalChange() -> LocalChange {
        let newLocalChange = LocalChange(context: context)
        newLocalChange.eventID = oldEvent != nil ? oldEvent?.objectUUID : newEvent?.objectUUID
        newLocalChange.timestamp = Date()
        return newLocalChange
    }
}

