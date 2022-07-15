//
//  ScheduleViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

import Foundation
import CalendarKit

@objc
public protocol ScheduleSubViewControllerDelegate {
    func didTapEvent(_ eventID: UUID)
    func didLongPressEvent(_ eventID: UUID)
    func fetchEventsForDate(_ date: Date, callback: @escaping(_ events:[CalendarApp.Event]?, _ errorMessage: String?) -> Void)
}

@objcMembers
class ScheduleSubViewController : DayViewController {
    
    var controllerDelegate: ScheduleSubViewControllerDelegate?
    private var dateToCalendarKitEvents = [Date: [CalendarKit.Event]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateCalendarEvent(_ event: CalendarApp.Event, _ date: Date) {
        guard var calendarKitEvents = dateToCalendarKitEvents[date] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        calendarKitEvents[eventIndex] = getCalendarKitEvent(event)
        reloadData()
        reloadInputViews()
    }
    
    func deleteCalendarEvent(_ event: CalendarApp.Event, _ date: Date) {
        guard var calendarKitEvents = dateToCalendarKitEvents[date] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        calendarKitEvents.remove(at: eventIndex)
        reloadData()
        reloadInputViews()
    }
    
    func getEventIndex(_ eventID: UUID, _ calendarKitEvents: [CalendarKit.Event]) -> Int {
        for eventIndex in 0...calendarKitEvents.count - 1 {
            if calendarKitEvents[eventIndex].objectID {
                return eventIndex
            }
        }
        return -1
    }
    
    func failedRequest(_ errorMessage: String) {
        // TODO: Error handling
    }
    
    func addCalendarKitEventFromEvents(_ events:[CalendarApp.Event], _ date: Date) {
        for eventModel in events {
            dateToCalendarKitEvents[date]?.append(getCalendarKitEvent(eventModel))
        }
    }
    
    func getCalendarKitEvent(_ eventModel: CalendarApp.Event) -> CalendarKit.Event {
        let dateIntervalFormatter = DateIntervalFormatter()
        let newEvent = CalendarKit.Event()
        newEvent.dateInterval = DateInterval(start: eventModel.startDate, end: eventModel.endDate)
        
        var info = [eventModel.eventTitle, eventModel.location]
        info.append(dateIntervalFormatter.string(from: newEvent.dateInterval.start, to: newEvent.dateInterval.end))
        newEvent.text = info.reduce("", {$0 + $1 + "\n"})
        newEvent.objectID = eventModel.objectUUID
        return newEvent
    }
    
    func fetchCalendarEventsForDate(_ date: Date) {
        controllerDelegate?.fetchEventsForDate(date, callback: { events, errorMessage in
            if let newEvents = events {
                self.addCalendarKitEventFromEvents(newEvents, date)
                self.reloadData()
            } else if let fetchErrorMessage = errorMessage {
                self.failedRequest(fetchErrorMessage)
            } else {
                self.failedRequest("Something went wrong.")
            }
        })
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard let calendarKitEvents = dateToCalendarKitEvents[date] else {
            dateToCalendarKitEvents[date] = [CalendarKit.Event]()
            fetchCalendarEventsForDate(date)
            return dateToCalendarKitEvents[date] ?? [CalendarKit.Event]()
        }
        return calendarKitEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarKit.Event else {
          return
        }
        guard let objectID = descriptor.objectID else {
            return
        }
        controllerDelegate?.didTapEvent(objectID)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarKit.Event else {
          return
        }
        guard let objectID = descriptor.objectID else {
            return
        }
        controllerDelegate?.didLongPressEvent(objectID)
    }
}
