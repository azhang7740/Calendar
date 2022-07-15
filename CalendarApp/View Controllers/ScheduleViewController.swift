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
    func didTapEvent(_ event: CalendarApp.Event);
    func didLongPressEvent(_ event: CalendarApp.Event);
}

@objcMembers
class ScheduleSubViewController : DayViewController {
    
    public var controllerDelegate: ScheduleSubViewControllerDelegate?
    private let parseEventHandler = ParseEventHandler()
    private var eventModels = [CalendarApp.Event]()
    private var alreadyFetchedDates = Set<Date>()
    private var eventDictionary = [UUID: CalendarApp.Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchEventsForDate(_ date: Date) {
        parseEventHandler.queryUserEvents(on: date) { [self] events, date, errorMessage in
            if errorMessage != nil {
                failedRequest(errorMessage ?? "")
            } else {
                for event in events ?? [] {
                    eventModels.append(event as? CalendarApp.Event ?? CalendarApp.Event())
                }
                reloadData()
            }
        }
    }
    
    func failedRequest(_ errorMessage: String) {
        
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        if (!alreadyFetchedDates.contains(date)) {
            alreadyFetchedDates.insert(date)
            fetchEventsForDate(date)
        }
        var calendarKitEvents = [CalendarKit.Event]()
        let dateIntervalFormatter = DateIntervalFormatter()

        for eventModel in eventModels {
            let event = CalendarKit.Event()
            event.dateInterval = DateInterval(start: eventModel.startDate, end: eventModel.endDate)
            
            var info = [eventModel.eventTitle, eventModel.location]
            info.append(dateIntervalFormatter.string(from: event.dateInterval.start, to: event.dateInterval.end))
            event.text = info.reduce("", {$0 + $1 + "\n"})
            event.objectID = eventModel.objectUUID
            eventDictionary[eventModel.objectUUID] = eventModel
            calendarKitEvents.append(event)
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
        self.controllerDelegate?.didTapEvent(eventDictionary[objectID]!)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? CalendarKit.Event else {
          return
        }
        guard let objectID = descriptor.objectID else {
            return
        }
        self.controllerDelegate?.didLongPressEvent(eventDictionary[objectID]!)
    }
}
