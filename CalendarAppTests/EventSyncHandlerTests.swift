//
//  EventSyncHandlerTests.swift
//  CalendarAppTests
//
//  Created by Angelina Zhang on 7/27/22.
//

import XCTest
@testable import CalendarApp

class EventSyncHandlerTests: XCTestCase {
    var handler: EventSyncHandler!
    var parseHandler: TestEventHandler!
    
    override func setUp() {
        super.setUp()
        
        handler = EventSyncHandler()
        parseHandler = TestEventHandler()
        handler.parseEventHandler = parseHandler
    }
    
    override func tearDown() {
        handler = nil
        parseHandler = nil
        
        super.tearDown()
    }
    
    func testSyncCreateToParse() {
        handler.syncEvent(toParse: nil, updatedEvent: Event())
        XCTAssertTrue(parseHandler.wasUploadEventsCalled)
    }
}
