//
//  CalendarEventHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

class CalendarEventHandler {
    public var fetchedDates = Set<Date>()
    private var dateToCalendarKitEvents = [Date: [CalendarApp.Event]]()
    private var calendar = Calendar(identifier: .gregorian)
    
    init() {
        calendar.timeZone = TimeZone.current
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarApp.Event] {
        let midnight = calendar.startOfDay(for: date)
        return dateToCalendarKitEvents[midnight] ?? []
    }
    
    func addEvent(_ event: CalendarApp.Event) {
        var midnight = calendar.startOfDay(for: event.startDate)
        let endMidnight = calendar.startOfDay(for: event.endDate)
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        while (midnight <= endMidnight) {
            guard var calendarEvents = dateToCalendarKitEvents[midnight] else {
                return
            }
            calendarEvents.append(event)
            dateToCalendarKitEvents[midnight] = calendarEvents
            guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: midnight) else {
                return
            }
            midnight = nextMidnight
        }
    }
    
    func addEventsFromArray(_ events:[CalendarApp.Event], _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        let calendarEvents = dateToCalendarKitEvents[midnight] ?? []
        dateToCalendarKitEvents[midnight] = calendarEvents
        events.forEach { addEvent($0) }
    }
    
    func deleteEvent(_ event: CalendarApp.Event, _ date: Date) {
        var midnight = calendar.startOfDay(for: date)
        let endMidnight = calendar.startOfDay(for: event.endDate)
        var dateComponents = DateComponents()
        dateComponents.day = 1
        while (midnight <= endMidnight) {
            guard var calendarKitEvents = dateToCalendarKitEvents[midnight],
            let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents) else {
                return
            }
            calendarKitEvents.remove(at: eventIndex)
            dateToCalendarKitEvents[midnight] = calendarKitEvents;
            guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: midnight) else {
                return
            }
            midnight = nextMidnight
        }
        
    }
    
    func updateEvent(_ event: CalendarApp.Event, _ originalStart: Date, _ newStart: Date) {
        let originalMidnight = calendar.startOfDay(for: originalStart)
        deleteEvent(event, originalMidnight)
        addEvent(event)
    }
    
    private func getEventIndex(_ eventID: UUID, _ calendarEvents: [CalendarApp.Event]) -> Int? {
        calendarEvents.enumerated().first { element in
            element.element.objectUUID == eventID
        }?.offset
    }
}
