//
//  SyncConflictHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objcMembers
class SyncConflictHandler : NSObject {
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
        
        return keptChanges
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
