//
//  SyncConflictHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objc
public protocol SyncRemoteChangesDelegate {
    func deletedEventOnRemote()
    func updatedEventOnRemote()
    func createdEventOnRemote()
}

@objcMembers
class SyncConflictHandler : NSObject {
    weak var delegate: SyncRemoteChangesDelegate?
    private var keptChanges = [LocalChange]()
    private var revisionHistories: [RecentRevisionHistory]
    
    init(histories: [RecentRevisionHistory]) {
        revisionHistories = histories
    }
    
    func getChangesToSync(revisionHistories: [RecentRevisionHistory],
                          localChanges: [LocalChange]) -> [LocalChange] {
        for change in localChanges {
            if change.oldEvent == nil {
                createEvent(localChange: change)
            } else if change.updatedEvent == nil {
                deleteEvent(localChange: change)
            } else {
                addUpdate(localChange: change)
            }
        }
        
        resolveConflicts()
        
        return keptChanges
    }
    
    private func resolveConflicts() {
        for history in revisionHistories {
            if history.remoteChanges.isEmpty {
                addAllLocalChanges(localChanges: history.localChanges)
            } else if history.localChanges.isEmpty {
                syncMostRecentRemote(remoteChanges: history.remoteChanges)
            } else {
                resolveUpdateConflicts()
            }
        }
    }
    
    private func resolveUpdateConflicts() {
        
    }
    
    private func addAllLocalChanges(localChanges: [LocalChange]) {
        for change in localChanges {
            keptChanges.append(change)
        }
    }
    
    private func syncMostRecentRemote(remoteChanges: [RemoteChange]) {
        guard let mostRecentChange = remoteChanges.max(by: { $0.timestamp < $1.timestamp }) else {
            return
        }
        if (mostRecentChange.oldEvent == nil) {
            delegate?.createdEventOnRemote()
        } else if (mostRecentChange.updatedEvent == nil) {
            delegate?.deletedEventOnRemote()
        } else {
            delegate?.updatedEventOnRemote()
        }
    }
    
    private func addUpdate(localChange: LocalChange) {
        guard let oldEvent = localChange.oldEvent,
              let index = getIndex(eventID: oldEvent.objectUUID) else {
            return
        }
        revisionHistories[index].localChanges.append(localChange)
    }
    
    private func deleteEvent(localChange: LocalChange) {
        guard let oldEvent = localChange.oldEvent,
              let index = getIndex(eventID: oldEvent.objectUUID) else {
            return
        }
        revisionHistories.remove(at: index)
        keptChanges.append(localChange)
    }
    
    private func createEvent(localChange: LocalChange) {
        keptChanges.append(localChange)
    }
    
    private func getIndex(eventID: UUID) -> Int? {
        revisionHistories.enumerated().first { element in
            element.element.objectUUID == eventID
        }?.offset
    }
}
