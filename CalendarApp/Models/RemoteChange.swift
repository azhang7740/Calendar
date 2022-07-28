//
//  RemoteChange.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

import Foundation

@objcMembers
public class RemoteChange : NSObject {
    public var parseID: String?
    public var oldEvent: Event?
    public var updatedEvent: Event?
    public var timestamp: Date?
}
