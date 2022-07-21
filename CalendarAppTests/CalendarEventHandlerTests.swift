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
    var event: Event!
    
    override func setUp() {
        super.setUp()
        
        handler = CalendarEventHandler()
        event = Event()
    }
    
    override func tearDown() {
        handler = nil
    }
    
    func testAddEvent() {
        handler.addEvent(event)
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [event])
    }
    
    func testGetEventsForFutureDateWithEvents() {
        let tomorrow = Date().advanced(by: TimeInterval(86400))
        let event = SampleEvents.makeEvent(on: tomorrow)
        handler.addEvent(event)
        
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [event])
    }
    
    func testGetEventsForFutureDateWithEmptyEvents() {
        
    }
    
    func testGetEventsForPastDate() {
        
    }
    
    func testGetEventsForCurrentDate() {
        
    }
    
    func testGetEventsForDateWithEmptyEvents() {
        
    }
    
    func testGetEventThatStartsOnPreviousDay() {
        
    }
}
