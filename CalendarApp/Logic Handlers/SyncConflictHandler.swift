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
    private var revisionHistories: [[Revision]]
    private let localChangeHandler = LocalChangeHandler()
    private let parseChangeHandler = ParseChangeHandler()
    private let coreDataEventHandler = CoreDataEventHandler()
    
    init(histories: [[RemoteChange]]) {
        revisionHistories = histories
    }
    
    func syncChanges() {
        addLocalChanges()
        checkChanges()
        syncLocalCreatesDeletes()
        syncLocalUpdates()
        localChangeHandler.deleteAllLocalChanges()
    }
    
    private func syncLocalUpdates() {
        let changes = localChangeHandler.fetchAllLocalChanges()
        syncChangesToParse(eventChanges: changes)
    }
    
    private func syncLocalCreatesDeletes() {
        let changes = localChangeHandler.fetchAllLocalChanges()
        for change in changes {
            if change.changeType == .Create {
                guard let eventID = change.eventID,
                      let event = coreDataEventHandler.queryEvent(from: eventID) else {
                    break
                }
                delegate?.syncNewEventToParse(event: event, remoteChange: getRemoteChange(localChange: change))
            } else if (change.changeType == .Delete) {
                guard let eventID = change.eventID else {
                    break
                }
                delegate?.syncDeleteToParse(event: eventID.uuidString,
                                            remoteChange: getRemoteChange(localChange: change))
            }
        }
    }
    
    private func addLocalChanges() {
        if (revisionHistories.count == 0) {
            return
        }
        for historyIndex in 0...revisionHistories.count - 1 {
            guard let eventID = revisionHistories[historyIndex][0].eventID else {
                break
            }
            revisionHistories[historyIndex].append(contentsOf: localChangeHandler.fetchLocalChanges(forEvent: eventID))
            revisionHistories[historyIndex].sort(by: { $0.timestamp < $1.timestamp })
        }
    }
    
    private func checkChanges() {
        for eventHistory in revisionHistories {
            if let eventID = eventHistory[0].eventID,
                eventHistory.count == 1 &&
                eventHistory[0].changeType == .Create {
                if coreDataEventHandler.queryEvent(from: eventID) == nil {
                    createNewEvent(change: eventHistory[0])
                }
            } else if let eventID = eventHistory[0].eventID,
                      eventHistory.count == 1 &&
                        eventHistory[0].changeType == .Delete {
                if coreDataEventHandler.queryEvent(from: eventID) != nil {
                    deleteEvent(change: eventHistory[0])
                }
            } else {
                processUpdateChanges(eventChanges: eventHistory)
            }
        }
    }
    
    private func processUpdateChanges(eventChanges: [Revision]) {
        guard let eventID = eventChanges[0].eventID else {
            return
        }
        guard var event = coreDataEventHandler.queryEvent(from: eventID) else {
            delegate?.createdEventOnRemote(eventID: eventID)
            return
        }
        var changeFieldMap = [ChangeField: Int]()
        for (index, change) in eventChanges.enumerated() {
            if let previousChangeIndex = changeFieldMap[change.changeField] {
                deletePreviousRevision(change: eventChanges[previousChangeIndex])
                changeFieldMap[change.changeField] = index
            } else {
                changeFieldMap[change.changeField] = index
            }
            event = applyChange(event: event, change: change)
        }
        delegate?.updatedEventOnRemote(event: event)
        delegate?.syncUpdateToParse(event: event)
        syncChangesToParse(eventChanges: eventChanges)
    }
    
    private func syncChangesToParse(eventChanges: [Revision]) {
        for change in eventChanges {
            if let localChange = change as? LocalChange {
                delegate?.syncRemoteChangeToParse(remoteChange: getRemoteChange(localChange: localChange))
                localChangeHandler.delete(localChange)
            }
        }
    }
    
    private func applyChange(event: Event, change: Revision) -> Event {
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
        }
        
        return newEvent
    }
    
    private func deleteEvent(change: Revision) {
        if let remoteDelete = change as? RemoteChange {
            guard let eventUUID = remoteDelete.eventID else {
                return
            }
            delegate?.deletedEventOnRemote(eventID: eventUUID)
        } else if let localDelete = change as? LocalChange {
            guard let eventID = localDelete.eventID else {
                return
            }
            delegate?.syncDeleteToParse(event: eventID.uuidString,
                                        remoteChange: getRemoteChange(localChange: localDelete))
        }
    }
    
    private func createNewEvent(change: Revision) {
        if let remoteCreate = change as? RemoteChange {
            guard let eventUUID = remoteCreate.eventID else {
                return
            }
            delegate?.createdEventOnRemote(eventID: eventUUID)
        } else if let localCreate = change as? LocalChange {
            guard let eventID = localCreate.eventID,
                  let event = coreDataEventHandler.queryEvent(from: eventID) else {
                return
            }
            delegate?.syncNewEventToParse(event: event, remoteChange: getRemoteChange(localChange: localCreate))
        }
    }
    
    private func deletePreviousRevision(change: Revision) {
        if let remoteChange = change as? RemoteChange {
            guard let parseID = remoteChange.parseID else {
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
