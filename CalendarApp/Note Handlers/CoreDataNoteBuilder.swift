//
//  CoreDataNoteBuilder.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import CoreData

class CoreDataNoteBuilder {
    func getNote(coreDataNote: CoreDataNote) -> Note? {
        guard let createdAt = coreDataNote.createdAt,
              let lastModified = coreDataNote.lastModified,
              let noteID = coreDataNote.noteID,
              let text = coreDataNote.text,
              let title = coreDataNote.title else {
                  return nil
              }
        let newNote = Note(createDate: createdAt,
                           modifiedDate: lastModified,
                           noteUUID: noteID,
                           noteText: text,
                           noteTitle: title)
        return newNote
    }
    
    func getNoteArray(coreDataNotes: [CoreDataNote]) -> [Note] {
        var notes = [Note]()
        for note in coreDataNotes {
            if let newNote = getNote(coreDataNote: note) {
                notes.append(newNote)
            }
        }
        return notes
    }
}
