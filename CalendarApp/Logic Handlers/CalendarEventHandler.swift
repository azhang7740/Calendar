//
//  CalendarEventHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

class CalendarEventHandler {
    private var dateToCalendarKitEvents = [Date: [CalendarKit.Event]]()
    private var calendar = Calendar(identifier: .gregorian)
    
    init() {
        calendar.timeZone = TimeZone.current
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarKit.Event]? {
        let midnight = calendar.startOfDay(for: date)
        return dateToCalendarKitEvents[midnight]
    }
    
    func addEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarKit.Event]()
        calendarEvents.append(makeCalendarEvent(event))
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func addEventsFromArray(_ events:[CalendarApp.Event], _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarKit.Event]()
        for eventModel in events {
            calendarEvents.append(makeCalendarEvent(eventModel))
        }
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func deleteEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        guard var calendarKitEvents = dateToCalendarKitEvents[midnight] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        if (eventIndex == -1) {
            // TODO: Error handling
        } else {
            calendarKitEvents.remove(at: eventIndex)
        }
        dateToCalendarKitEvents[midnight] = calendarKitEvents;
    }
    
    func updateEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        guard var calendarKitEvents = dateToCalendarKitEvents[midnight] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        if (eventIndex == -1) {
            // TODO: error handling
        } else {
            calendarKitEvents[eventIndex] = makeCalendarEvent(event)
        }
        dateToCalendarKitEvents[midnight] = calendarKitEvents
    }
    
    private func getEventIndex(_ eventID: UUID, _ calendarKitEvents: [CalendarKit.Event]) -> Int {
        for eventIndex in 0...calendarKitEvents.count - 1 {
            if calendarKitEvents[eventIndex].objectID == eventID {
                return eventIndex
            }
        }
        return -1
    }
    
    private func makeCalendarEvent(_ eventModel: CalendarApp.Event) -> CalendarKit.Event {
        let dateIntervalFormatter = DateIntervalFormatter()
        let newEvent = CalendarKit.Event()
        newEvent.dateInterval = DateInterval(start: eventModel.startDate, end: eventModel.endDate)
        
        var info = [eventModel.eventTitle, eventModel.location]
        info.append(dateIntervalFormatter.string(from: newEvent.dateInterval.start, to: newEvent.dateInterval.end))
        newEvent.text = info.reduce("", {$0 + $1 + "\n"})
        newEvent.objectID = eventModel.objectUUID
        return newEvent
    }
}
