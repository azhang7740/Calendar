//
//  Note.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import UIKit

class NoteCell : UITableViewCell {
    public var noteID: UUID?
    public var lastModified: Date?
    public var title: String?
    public var displayText: String?
}
