//
//  SampleEvents.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 7/20/22.
//

import Foundation
@testable import CalendarApp

enum SampleEvents {
    static let valid = Event()
    private static let oneHourInSeconds = TimeInterval(3600)
    
    static func makeEvent(on date: Date) -> Event {
        let event = Event()
        event.startDate = date
        event.endDate = date.advanced(by: oneHourInSeconds)
        return event
    }
}
