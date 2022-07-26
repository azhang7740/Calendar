//
//  SyncConflictHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objcMembers
class SyncConflictHandler : NSObject {
    func resolveConflicts(onlineEvents remoteEvents: [Event],
                          offlineChanges localChanges: [LocalChange]) -> [LocalChange] {
        return localChanges
    }
}
