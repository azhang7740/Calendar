//
//  RemoteChange.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

import Foundation

@objcMembers
public class RemoteChange : NSObject, Revision {
    public var eventID: UUID?
    public var timestamp: Date
    public var changeType = ChangeType.NoChange
    public var changeField = ChangeField.None
    public var updatedField: String?
    public var parseID: String?
    
    public init(updatedDate: Date) {
        timestamp = updatedDate
    }
}
