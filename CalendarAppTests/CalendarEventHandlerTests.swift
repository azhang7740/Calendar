//
//  CalendarEventHandlerTests.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 7/20/22.
//

import XCTest
@testable import CalendarApp

class CalendarEventHandlerTests: XCTestCase {
    var handler: CalendarEventHandler!
    var earlyEvent: Event!
    var laterEvent: Event!
    var currentEvent: Event!
    var yesterday: Date!
    var tomorrow: Date!
    
    override func setUp() {
        super.setUp()
        
        handler = CalendarEventHandler()
        yesterday = Date().advanced(by: TimeInterval(-86400))
        tomorrow = Date().advanced(by: TimeInterval(86400))
        
        earlyEvent = SampleEvents.makeEvent(on: yesterday)
        laterEvent = SampleEvents.makeEvent(on: tomorrow)
        currentEvent = SampleEvents.makeEvent(on: Date())
    }
    
    override func tearDown() {
        handler = nil
    }
    
    func testAddEventsFromArray() {
        handler.addEventsFromArray([currentEvent], Date())
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [currentEvent])
    }
    
    func testGetEventsForFutureDateWithEvents() {
        let event = SampleEvents.makeEvent(on: tomorrow)
        handler.addEventsFromArray([event], tomorrow)
        
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [event])
    }
    
    func testGetEventsForFutureDateWithEmptyEvents() {
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
    }
    
    func testGetEventsForPastDate() {
        let event = SampleEvents.makeEvent(on: yesterday)
        handler.addEventsFromArray([event], yesterday)

        XCTAssertEqual(handler.getEventsForDate(yesterday), [event])
    }
    
    func testGetEventsForPastDateWithEmptyEvents() {
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
    }
    
    func testGetEventsForCurrentDate() {
        let event = SampleEvents.makeEvent(on: Date())
        handler.addEventsFromArray([event], Date())

        XCTAssertEqual(handler.getEventsForDate(Date()), [event])
    }
    
    func testGetEventsForDateWithEmptyEvents() {
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
    }
    
    func testGetEventsWithMultipleDates() {
        handler.addEventsFromArray([earlyEvent], yesterday)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
        
        handler.addEventsFromArray([laterEvent], tomorrow)

        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [laterEvent])
    }
    
    func testGetEventThatStartsOnPreviousDay() {
        let longEvent = SampleEvents.makeEvent(on: yesterday, withDays: 2, withHours: 3)
        handler.addNewEvent(longEvent)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
        
        handler.addEventsFromArray([longEvent], Date())
        XCTAssertEqual(handler.getEventsForDate(Date()), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
    }
    
    func testAddEventSpanningMultipleDays() {
        let longEvent = SampleEvents.makeEvent(on: yesterday, withDays: 2, withHours: 3)
        handler.addEventsFromArray([currentEvent], Date())
        handler.addEventsFromArray([earlyEvent], yesterday)
        handler.addEventsFromArray([], tomorrow)
        handler.addNewEvent(longEvent)
        
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent, longEvent])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(Date()), [currentEvent, longEvent])
    }
    
    func testAddNewEventToNewDate() {
        handler.addEventsFromArray([currentEvent], Date())
        handler.addNewEvent(earlyEvent)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [currentEvent])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
    }
    
    func testAddNewEventToExistingDate() {
        let secondEarlyEvent = SampleEvents.makeEvent(on: yesterday)
        let thirdEarlyEvent = SampleEvents.makeEvent(on: yesterday)
        handler.addEventsFromArray([earlyEvent, secondEarlyEvent], yesterday)
        handler.addNewEvent(thirdEarlyEvent)
        
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent, secondEarlyEvent, thirdEarlyEvent])
    }
    
    func testDeleteNonExistingEvent() {
        let event = Event()
        handler.addEventsFromArray([], yesterday)
        handler.addEventsFromArray([currentEvent], Date())
        handler.deleteEvent(event)
        handler.deleteEvent(earlyEvent)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [currentEvent])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
    }
    
    func testDeleteExistingEvent() {
        handler.addEventsFromArray([currentEvent], Date())
        handler.deleteEvent(currentEvent)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
    }
    
    func testDeleteEventTwice() {
        handler.addEventsFromArray([currentEvent], Date())
        handler.deleteEvent(currentEvent)
        
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
        
        handler.deleteEvent(currentEvent)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
    }
    
    func testDeleteEventSpanningMultipleDays() {
        let longEvent = SampleEvents.makeEvent(on: yesterday, withDays: 2, withHours: 3)
        handler.addEventsFromArray([], yesterday)
        handler.addEventsFromArray([], Date())
        handler.addEventsFromArray([], tomorrow)
        
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
        
        handler.addNewEvent(longEvent)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(Date()), [longEvent])
        
        handler.deleteEvent(longEvent)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
    }
    
    func testDeleteLongEventWithUnfetchedDates() {
        let longEvent = SampleEvents.makeEvent(on: yesterday, withDays: 2, withHours: 3)
        handler.addEventsFromArray([], Date())
        handler.addEventsFromArray([], tomorrow)
        handler.addNewEvent(longEvent)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(Date()), [longEvent])
        
        handler.deleteEvent(longEvent)
        XCTAssertEqual(handler.getEventsForDate(yesterday), [])
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
    }
    
    func testDeleteMultipleEvents() {
        let longEvent = SampleEvents.makeEvent(on: yesterday, withDays: 2, withHours: 3)
        handler.addEventsFromArray([currentEvent, longEvent], Date())
        handler.addEventsFromArray([earlyEvent, longEvent], yesterday)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [currentEvent, longEvent])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent, longEvent])
        
        handler.deleteEvent(currentEvent)
        XCTAssertEqual(handler.getEventsForDate(Date()), [longEvent])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent, longEvent])
        
        handler.deleteEvent(longEvent)
        XCTAssertEqual(handler.getEventsForDate(Date()), [])
        XCTAssertEqual(handler.getEventsForDate(yesterday), [earlyEvent])
    }
    
    func testAddEventAfterDelete() {
        
    }
}
