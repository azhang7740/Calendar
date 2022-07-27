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
    
    func getChangesToSync(onlineEvents remoteEvents: [Event],
                          offlineChanges localChanges: [LocalChange]) -> [LocalChange] {
        keptChanges = localChanges
        return keptChanges
    }
}
