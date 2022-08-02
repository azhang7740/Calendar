//
//  NotesViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import UIKit

@objcMembers
class NotesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var notesTableView: UITableView!
    private var coreDataNoteHandler = CoreDataNoteHandler()
    private var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notes = coreDataNoteHandler.fetchNotes()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        return cell
    }
}
