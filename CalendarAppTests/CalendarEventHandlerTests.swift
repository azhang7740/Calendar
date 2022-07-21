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
    }
    
    override func tearDown() {
        handler = nil
    }
    
    func testAddEvent() {
        event = Event()
        handler.addEventsFromArray([event], Date())
        
        XCTAssertEqual(handler.getEventsForDate(Date()), [event])
    }
    
    func testGetEventsForFutureDateWithEvents() {
        let tomorrow = Date().advanced(by: TimeInterval(86400))
        let event = SampleEvents.makeEvent(on: tomorrow)
        handler.addEventsFromArray([event], tomorrow)
        
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [event])
    }
    
    func testGetEventsForFutureDateWithEmptyEvents() {
        let tomorrow = Date().advanced(by: TimeInterval(86400))
        XCTAssertEqual(handler.getEventsForDate(tomorrow), [])
    }
    
    func testGetEventsForPastDate() {
        let yesterday = Date().advanced(by: TimeInterval(-86400))
        let event = SampleEvents.makeEvent(on: yesterday)
        handler.addEventsFromArray([event], yesterday)

        XCTAssertEqual(handler.getEventsForDate(yesterday), [event])
    }
    
    func testGetEventsForPastDateWithEmptyEvents() {
        let yesterday = Date().advanced(by: TimeInterval(-86400))
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
    
    func testGetEventThatStartsOnPreviousDay() {
        
    }
}
