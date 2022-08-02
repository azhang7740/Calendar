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
    
    func fetchNotes() -> [CoreDataNote] {
        do {
            let fetchedNotes = try context.fetch(CoreDataNote.fetchRequest())
            return fetchedNotes
        } catch {
            // TODO: error handling
        }
        return [CoreDataNote]()
    }
    
    func deleteNote(noteID: UUID) {
        do {
            let request = CoreDataNote.fetchRequest()
            request.predicate = NSPredicate(format: "noteID == %@", noteID as CVarArg)
            let fetchedNote = try context.fetch(request)
            if (fetchedNote.count == 1) {
                context.delete(fetchedNote[0])
            }
        } catch {
            // TODO: error handling
        }
    }
    
    func updateNote(note: Note) {
        
    }
}
