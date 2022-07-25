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

    @objc public enum ChangeType: Int32 {
        case Delete = 0
        case Create = 1
        case Update = 2
        case NoChange = 3
    }
    
    @NSManaged public var changeType: ChangeType
    @NSManaged public var eventUUID: UUID?
    @NSManaged public var eventParseID: String?

}
