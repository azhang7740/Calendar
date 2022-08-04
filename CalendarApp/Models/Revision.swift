//
//  Revision.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/29/22.
//

import Foundation

@objc public enum ChangeType: Int32 {
    case NoChange = 0
    case Delete = 1
    case Create = 2
    case Update = 3
}

@objc public enum ChangeField: Int32, CaseIterable {
    case None = 0
    case Title = 1
    case Description = 2
    case Location = 3
    case StartDate = 4
    case EndDate = 5
    case isAllDay = 6
}

@objc
public protocol Revision {
    var timestamp: Date { get set }
    var changeType: ChangeType { get set }
    var eventID: UUID? { get set }
    var changeField: ChangeField { get set }
    var updatedField: String? { get set }
}
