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
    
    func getChangesToSync(revisionHistory: RecentRevisionHistory,
                          localChanges: [LocalChange]) -> [LocalChange] {
        keptChanges = localChanges
        return keptChanges
    }
}
