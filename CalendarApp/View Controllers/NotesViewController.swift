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
    
    @IBAction func onClickCompose(_ sender: Any) {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        guard let noteCell = cell as? NoteCell else {
            return cell
        }
        noteCell.selectionStyle = .none
        if indexPath.row < notes.count {
            noteCell.titleLabel.text = notes[indexPath.row].title
            noteCell.descriptionLabel.text = notes[indexPath.row].text
            noteCell.lastModifiedLabel.text = getDateString(modifiedDate: notes[indexPath.row].lastModified)
        }
        return noteCell
    }
    
    func getDateString(modifiedDate: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        
        let difference = calendar.dateComponents([.month], from: notes[0].lastModified, to: calendar.startOfDay(for: Date()))
        let dateFormatter = DateFormatter()
        if let dayDifference = difference.day,
           dayDifference < 1{
            dateFormatter.dateFormat = "H:mm"
        } else {
            dateFormatter.dateFormat = "M/d/yyyy"
        }
        return dateFormatter.string(from: modifiedDate)
    }
}
