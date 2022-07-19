//
//  CalendarEventHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

class CalendarEventHandler {
    private var dateToCalendarKitEvents = [Date: [CalendarApp.Event]]()
    private var calendar = Calendar(identifier: .gregorian)
    
    init() {
        calendar.timeZone = TimeZone.current
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarApp.Event]? {
        let midnight = calendar.startOfDay(for: date)
        return dateToCalendarKitEvents[midnight]
    }
    
    func addEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarApp.Event]()
        calendarEvents.append(event)
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func addEventsFromArray(_ events:[CalendarApp.Event], _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarApp.Event]()
        for eventModel in events {
            calendarEvents.append(eventModel)
        }
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func deleteEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        guard var calendarKitEvents = dateToCalendarKitEvents[midnight] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        guard let newEventIndex = eventIndex else {
            return
        }
        calendarKitEvents.remove(at: newEventIndex)
        dateToCalendarKitEvents[midnight] = calendarKitEvents;
    }
    
    func updateEvent(_ event: CalendarApp.Event, _ originalStart: Date, _ newStart: Date) {
        let originalMidnight = calendar.startOfDay(for: originalStart)
        let newMidnight = calendar.startOfDay(for: newStart)
        deleteEvent(event, originalMidnight)
        addEvent(event, newMidnight)
    }
    
    private func getEventIndex(_ eventID: UUID, _ calendarEvents: [CalendarApp.Event]) -> Int? {
        calendarEvents.enumerated().first { element in
            element.element.objectUUID == eventID
        }?.offset
    }
}
