//
//  Note.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation

class Note : NSObject {
    public var createdAt = Date()
    public var lastModified = Date()
    public var noteID = UUID()
    public var text = ""
    public var title = "No title"
    
    public required init(note: Note) {
        createdAt = note.createdAt
        lastModified = note.lastModified
        noteID = note.noteID
        text = note.text
        title = note.title
    }
}
