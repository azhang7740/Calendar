//
//  RecentRevisionHistory.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

import Foundation
import CoreData

@objcMembers
class RecentRevisionHistory: NSObject {
    public var objectUUID: UUID?
    public var remoteChanges = [RemoteChange]()
    public var localChanges = [LocalChange]()
}
