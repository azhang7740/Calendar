//
//  SyncConflictHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objc
public protocol SyncChangesDelegate {
    func deletedEventOnRemote(eventID: UUID)
    func updatedEventOnRemote(event: Event)
    func createdEventOnRemote(eventID: UUID)
    
    func syncNewEventToParse(event: Event, remoteChange: RemoteChange)
    func syncDeleteToParse(event: String, remoteChange: RemoteChange)
    func syncUpdateToParse(event: Event)
    func syncRemoteChangeToParse(remoteChange: RemoteChange)
}

@objcMembers
class SyncConflictHandler : NSObject {
    weak var delegate: SyncChangesDelegate?
    private let localChangeHandler = LocalChangeHandler()
    private let parseChangeHandler = ParseChangeHandler()
    private let coreDataEventHandler = CoreDataEventHandler()
    
    func syncChanges(remoteChanges: [[RemoteChange]]) {
        let allChanges = getChangesForEvents(with: remoteChanges)
        applyAllLocalRemoteChanges(with: allChanges)
        
        syncLocalCreatesDeletes()
        syncLocalUpdates()
        localChangeHandler.deleteAllLocalChanges()
    }
    
    private func getChangesForEvents(with remoteChanges: [[RemoteChange]]) -> [[Revision]] {
        var changes = remoteChanges as [[Revision]]
        remoteChanges.forEach { eventChanges in
            if eventChanges.count > 0,
               let eventID = eventChanges.first?.eventID {
                var combinedEventChanges = eventChanges as [Revision]
                let localChanges = localChangeHandler.fetchLocalChanges(forEvent: eventID)
                if localChanges.count > 0,
                   localChanges.first?.changeType == .Delete {
                    combinedEventChanges.append(contentsOf: localChanges)
                    combinedEventChanges.sort(by: { $0.timestamp < $1.timestamp })
                    changes.append(combinedEventChanges)
                }
            }
        }
        return changes
    }
    
    private func applyAllLocalRemoteChanges(with changes: [[Revision]]) {
        changes.forEach { change in
            applyChanges(with: change)
        }
    }
    
    private func applyChanges(with changes: [Revision]) {
        guard changes.count == 1,
              let change = changes.first,
              let eventID = change.eventID,
              coreDataEventHandler.queryEvent(from: eventID) != nil
        else {
            applyLocalRemoteUpdates(with: changes)
            return
        }
        
        if change.changeType == .Create {
            createNewEvent(change: change)
        } else if change.changeType == .Delete {
            deleteEvent(change: change)
        }
    }
    
    private func applyLocalRemoteUpdates(with changes: [Revision]) {
        guard changes.count == 0,
              let change = changes.first,
              let eventID = change.eventID
        else {
            return
        }
        
        guard var event = coreDataEventHandler.queryEvent(from: eventID)
        else {
            delegate?.createdEventOnRemote(eventID: eventID)
            return
        }
        
        var changeFieldMap = [ChangeField: Revision]()
        changes.forEach { change in
            if let previousChange = changeFieldMap[change.changeField] {
                deletePreviousRevision(change: previousChange)
            }
            changeFieldMap[change.changeField] = change
            event = getChangedEvent(with: event, change: change)
        }
        
        delegate?.updatedEventOnRemote(event: event)
        delegate?.syncUpdateToParse(event: event)
        syncChangesToParse(eventChanges: changes)
    }
    
    private func getChangedEvent(with event: Event, change: Revision) -> Event {
        let newEvent = Event(originalEvent: event)
        guard let updatedField = change.updatedField else {
            return newEvent
        }
        
        switch change.changeField {
        case .None:
            break
        case .Title:
            newEvent.eventTitle = updatedField
            break
        case .Description:
            newEvent.eventDescription = updatedField
            break
        case .Location:
            newEvent.location = updatedField
            break
        case .StartDate:
            let formatter = ISO8601DateFormatter()
            newEvent.startDate = formatter.date(from: updatedField) ?? newEvent.startDate
            break
        case .EndDate:
            let formatter = ISO8601DateFormatter()
            newEvent.endDate = formatter.date(from: updatedField) ?? newEvent.endDate
            break
        case .isAllDay:
            let formatter = ISO8601DateFormatter()
            newEvent.startDate = formatter.date(from: updatedField) ?? newEvent.startDate
            newEvent.endDate = formatter.date(from: updatedField) ?? newEvent.endDate
            newEvent.isAllDay = updatedField == "1";
            break
        }
        
        return newEvent
    }
    
    private func syncLocalCreatesDeletes() {
        let changes = localChangeHandler.fetchAllLocalChanges()
        for change in changes {
            if change.changeType == .Create {
                guard let eventID = change.eventID,
                      let event = coreDataEventHandler.queryEvent(from: eventID)
                else {
                    break
                }
                delegate?.syncNewEventToParse(
                    event: event,
                    remoteChange: getRemoteChange(localChange: change)
                )
            } else if (change.changeType == .Delete) {
                guard let eventID = change.eventID
                else {
                    break
                }
                delegate?.syncDeleteToParse(
                    event: eventID.uuidString,
                    remoteChange: getRemoteChange(localChange: change)
                )
            }
        }
    }
    
    private func syncLocalUpdates() {
        let changes = localChangeHandler.fetchAllLocalChanges()
        syncChangesToParse(eventChanges: changes)
    }
    
    private func syncChangesToParse(eventChanges: [Revision]) {
        for change in eventChanges {
            if let localChange = change as? LocalChange {
                delegate?.syncRemoteChangeToParse(remoteChange: getRemoteChange(localChange: localChange))
                localChangeHandler.delete(localChange)
            }
        }
    }
    
    private func deleteEvent(change: Revision) {
        if let remoteDelete = change as? RemoteChange {
            guard let eventUUID = remoteDelete.eventID
            else {
                return
            }
            delegate?.deletedEventOnRemote(eventID: eventUUID)
        } else if let localDelete = change as? LocalChange {
            guard let eventID = localDelete.eventID
            else {
                return
            }
            delegate?.syncDeleteToParse(
                event: eventID.uuidString,
                remoteChange: getRemoteChange(localChange: localDelete)
            )
        }
    }
    
    private func createNewEvent(change: Revision) {
        if let remoteCreate = change as? RemoteChange {
            guard let eventUUID = remoteCreate.eventID
            else {
                return
            }
            delegate?.createdEventOnRemote(eventID: eventUUID)
        } else if let localCreate = change as? LocalChange {
            guard let eventID = localCreate.eventID,
                  let event = coreDataEventHandler.queryEvent(from: eventID)
            else {
                return
            }
            delegate?.syncNewEventToParse(
                event: event,
                remoteChange: getRemoteChange(localChange: localCreate)
            )
        }
    }
    
    private func deletePreviousRevision(change: Revision) {
        if let remoteChange = change as? RemoteChange {
            guard let parseID = remoteChange.parseID
            else {
                return
            }
            parseChangeHandler.deleteParseChange(parseID) { success, error in
                if (!success) {
                    // TODO: error handling
                }
            }
        } else if let localChange = change as? LocalChange {
            localChangeHandler.delete(localChange)
        }
    }
    
    private func getRemoteChange(localChange: LocalChange) -> RemoteChange {
        let remoteChange = RemoteChange(updatedDate: localChange.timestamp)
        remoteChange.eventID = localChange.eventID
        remoteChange.changeType = localChange.changeType
        remoteChange.changeField = localChange.changeField
        remoteChange.updatedField = localChange.updatedField
        
        return remoteChange
    }
}
