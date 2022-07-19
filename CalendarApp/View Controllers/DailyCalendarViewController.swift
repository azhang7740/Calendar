//
//  ScheduleViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

import Foundation
import CalendarKit

@objc
public protocol EventInteraction {
    func didTapEvent(_ eventID: UUID)
    func didLongPressEvent(_ eventID: UUID)
    func didLongPressTimeline(_ date: Date)
    func fetchEventsForDate(_ date: Date, callback: @escaping(_ events:[CalendarApp.Event]?, _ errorMessage: String?) -> Void)
}

@objcMembers
class DailyCalendarViewController : DayViewController {
    
    var controllerDelegate: EventInteraction?
    private let calendarEventHandler = CalendarEventHandler()
    private var fetchedDates = Set<Date>()
    
    func updateCalendarEvent(_ event: CalendarApp.Event, _ date: Date) {
        calendarEventHandler.updateEvent(event, date)
        reloadData()
    }
    
    func deleteCalendarEvent(_ event: CalendarApp.Event, _ date: Date) {
        calendarEventHandler.deleteEvent(event, date)
        reloadData()
    }
    
    func failedRequest(_ errorMessage: String) {
        // TODO: Error handling
    }
    
    func addEvent(_ eventModel: CalendarApp.Event, _ date: Date) {
        calendarEventHandler.addEvent(eventModel, date)
        reloadData()
    }
    
    func fetchCalendarEventsForDate(_ date: Date) {
        controllerDelegate?.fetchEventsForDate(date, callback: { events, errorMessage in
            if let newEvents = events {
                self.calendarEventHandler.addEventsFromArray(newEvents, date)
                DispatchQueue.main.async {
                    self.reloadData()
                }
            } else if let fetchErrorMessage = errorMessage {
                self.failedRequest(fetchErrorMessage)
            } else {
                self.failedRequest("Something went wrong.")
            }
        })
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard let calendarKitEvents = calendarEventHandler.getEventsForDate(date) else {
            if (!fetchedDates.contains(date)) {
                fetchedDates.insert(date)
                fetchCalendarEventsForDate(date)
            }
            return calendarEventHandler.getEventsForDate(date) ?? []
        }
        return calendarKitEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarApp.Event else {
          return
        }
        controllerDelegate?.didTapEvent(descriptor.objectUUID)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarApp.Event else {
          return
        }
        controllerDelegate?.didLongPressEvent(descriptor.objectUUID)
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        controllerDelegate?.didLongPressTimeline(date)
    }
}
