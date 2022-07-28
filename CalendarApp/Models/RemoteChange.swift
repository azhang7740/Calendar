//
//  RemoteChange.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

import Foundation

@objc public enum ChangeType: Int32 {
    case Delete = 0
    case Create = 1
    case Update = 2
}

@objcMembers
public class RemoteChange : NSObject {
    public var parseID: String?
    public var oldEvent: Event?
    public var updatedEvent: Event?
    public var timestamp: Date?
}

@objc extension RemoteChange {
    public var changeType : ChangeType {
        if (oldEvent == nil) {
            return ChangeType.Create
        } else if (updatedEvent == nil) {
            return ChangeType.Delete
        } else {
            return ChangeType.Update
        }
    }
    
    public var objectUUID : UUID? {
        if let event = oldEvent {
            return event.objectUUID
        }
        
        if let event = updatedEvent {
            return event.objectUUID
        }
        
        return nil
    }
}
