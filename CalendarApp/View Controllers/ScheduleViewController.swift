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
    func hasEventsForDate(_ date: Date) -> Bool
}

@objcMembers
class ScheduleSubViewController : DayViewController {
    
    var controllerDelegate: ScheduleSubViewControllerDelegate?
    private var calendarKitEvents = [CalendarKit.Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateCalendarEvents() {
        reloadData()
    }
    
    func failedRequest(_ errorMessage: String) {
        // TODO: Error handling
    }
    
    func addCalendarKitEventFromEvents(_ events:[CalendarApp.Event]) {
        let dateIntervalFormatter = DateIntervalFormatter()
        
        for eventModel in events {
            let newEvent = CalendarKit.Event()
            newEvent.dateInterval = DateInterval(start: eventModel.startDate, end: eventModel.endDate)
            
            var info = [eventModel.eventTitle, eventModel.location]
            info.append(dateIntervalFormatter.string(from: newEvent.dateInterval.start, to: newEvent.dateInterval.end))
            newEvent.text = info.reduce("", {$0 + $1 + "\n"})
            newEvent.objectID = eventModel.objectUUID
            calendarKitEvents.append(newEvent)
        }
    }
    
    func fetchCalendarEventsForDate(_ date: Date) {
        controllerDelegate?.fetchEventsForDate(date, callback: { events, errorMessage in
            if let newEvents = events {
                self.addCalendarKitEventFromEvents(newEvents)
                self.reloadData()
            } else if let fetchErrorMessage = errorMessage {
                self.failedRequest(fetchErrorMessage)
            } else {
                self.failedRequest("Something went wrong.")
            }
        })
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        guard let hasEvents = controllerDelegate?.hasEventsForDate(date) else {
            return calendarKitEvents;
        }
        if (!hasEvents) {
            fetchCalendarEventsForDate(date)
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
        self.controllerDelegate?.didTapEvent(objectID)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarKit.Event else {
          return
        }
        guard let objectID = descriptor.objectID else {
            return
        }
        self.controllerDelegate?.didLongPressEvent(objectID)
    }
}
