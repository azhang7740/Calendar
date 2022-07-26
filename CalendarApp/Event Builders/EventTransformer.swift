//
//  EventTransformer.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/26/22.
//

import Foundation

@objc(EventTransformer)
class EventTransformer : NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: EventTransformer.self))
    
    override static var allowedTopLevelClasses: [AnyClass] {
        return [Event.self]
    }
    
    /// Registers the transformer.
    public static func register() {
        let transformer = EventTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
