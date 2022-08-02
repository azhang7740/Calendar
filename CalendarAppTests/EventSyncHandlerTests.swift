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
    var changeHandler: TestRemoteChangeHandler!
    var localChangeDelegate:LocalChangeSyncDelegate!
    
    override func setUp() {
        super.setUp()
        
        localChangeDelegate = TestLocalChangeDelegate()
        handler = EventSyncHandler(localChangeDelegate)
        parseHandler = TestEventHandler()
        handler.parseEventHandler = parseHandler
        
        changeHandler = TestRemoteChangeHandler()
        handler.parseChangeHandler = changeHandler
    }
    
    override func tearDown() {
        localChangeDelegate = nil
        handler = nil
        parseHandler = nil
        changeHandler = nil
        
        super.tearDown()
    }
    
    func testSyncCreateToParse() {
        handler.syncEvent(toParse: nil, updatedEvent: Event())
        XCTAssertTrue(parseHandler.wasUploadEventsCalled)
    }
}
