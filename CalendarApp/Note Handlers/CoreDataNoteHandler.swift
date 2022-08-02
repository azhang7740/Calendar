//
//  CoreDataNoteHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import CoreData

@objcMembers
class CoreDataNoteHandler : NSObject {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let noteBuilder = CoreDataNoteBuilder()
    
    func fetchNotes() -> [Note] {
        do {
            let fetchedNotes = try context.fetch(CoreDataNote.fetchRequest())
            let notes = noteBuilder.getNoteArray(coreDataNotes: fetchedNotes)
            return notes.sorted(by: { $0.lastModified < $1.lastModified })
        } catch {
            // TODO: error handling
        }
        return [Note]()
    }
    
    func deleteNote(noteID: UUID) {
        guard let deletingNote = fetchNote(noteID: noteID) else {
            return
        }
        context.delete(deletingNote)
    }
    
    func update(note: Note) {
        guard let coreDataNote = fetchNote(noteID: note.noteID) else {
            return
        }
        coreDataNote.title = note.title
        coreDataNote.createdAt = note.createdAt
        coreDataNote.lastModified = note.lastModified
        coreDataNote.text = note.text
        coreDataNote.noteID = note.noteID
        
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    func saveNewNote(note: Note) {
        let newNote = CoreDataNote(context: context)
        newNote.title = note.title
        newNote.createdAt = note.createdAt
        newNote.lastModified = note.lastModified
        newNote.text = note.text
        newNote.noteID = note.noteID
        
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    private func fetchNote(noteID: UUID) -> CoreDataNote? {
        do {
            let request = CoreDataNote.fetchRequest()
            request.predicate = NSPredicate(format: "noteID == %@", noteID as CVarArg)
            let fetchedNote = try context.fetch(request)
            if fetchedNote.count == 1 {
                return fetchedNote[0]
            }
        } catch {
            // TODO: error handling
        }
        return nil
    }
}
