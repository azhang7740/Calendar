//
//  LocalChange+CoreDataProperties.swift
//  
//
//  Created by Angelina Zhang on 7/25/22.
//
//

import Foundation
import CoreData


extension LocalChange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalChange> {
        return NSFetchRequest<LocalChange>(entityName: "LocalChange")
    }

    @NSManaged public var oldEvent: Event?
    @NSManaged public var updatedEvent: Event?
    @NSManaged public var timestamp: Date?
}
