//
//  SyncConflictHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objc
public protocol SyncRemoteChangesDelegate {
    func deletedEventOnRemote(event: Event)
    func updatedEventOnRemote(event: Event)
    func createdEventOnRemote(event: Event)
}

@objcMembers
class SyncConflictHandler : NSObject {
    weak var delegate: SyncRemoteChangesDelegate?
    private var revisionHistories: [[Revision]]
    private let localChangeHandler = LocalChangeHandler()
    private let parseChangeHandler = ParseChangeHandler()
    
    init(histories: [[RemoteChange]]) {
        revisionHistories = histories
    }
    
    func syncChanges() {
        
    }
    
    private func addLocalChanges() {
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
            if eventHistory.count == 1 &&
                eventHistory[0].changeType == .Create {
                // create action
            } else if eventHistory.count == 1 &&
                        eventHistory[0].changeType == .Delete {
                // delete action
            } else {
                processUpdateChanges(eventChanges: eventHistory)
            }
        }
    }
    
    private func processUpdateChanges(eventChanges: [Revision]) {
        var changeFieldMap = [ChangeField: Int]()
        for (index, change) in eventChanges.enumerated() {
            if let previousChangeIndex = changeFieldMap[change.changeField] {
                deletePreviousRevision(change: eventChanges[previousChangeIndex])
                changeFieldMap[change.changeField] = index
            } else {
                changeFieldMap[change.changeField] = index
            }
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
}
