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
    private var revisionHistories: [RecentRevisionHistory]
    
    init(histories: [RecentRevisionHistory]) {
        revisionHistories = histories
    }
    
    func getChangesToSync(revisionHistories: [RecentRevisionHistory],
                          localChanges: [LocalChange]) {
        for change in localChanges {
            switch (change.changeType) {
            case .Delete:
                deleteEvent(localChange: change)
                break;
            case .Create:
                createEvent(localChange: change)
                break;
            case .Update:
                addUpdate(localChange: change)
                break;
            case .NoChange:
                break;
            }
        }
        
        resolveConflicts()
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
        
    }
    
    private func syncMostRecentRemote(remoteChanges: [RemoteChange]) {

    }
    
    private func addUpdate(localChange: LocalChange) {
        
    }
    
    private func deleteEvent(localChange: LocalChange) {
        
    }
    
    private func createEvent(localChange: LocalChange) {

    }
    
    private func getIndex(eventID: UUID) -> Int? {
        revisionHistories.enumerated().first { element in
            element.element.objectUUID == eventID
        }?.offset
    }
}
