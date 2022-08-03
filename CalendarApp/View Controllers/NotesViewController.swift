//
//  NotesViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import UIKit

@objcMembers
class NotesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ComposeNoteDelegate {
    @IBOutlet weak var notesTableView: UITableView!
    private var coreDataNoteHandler = CoreDataNoteHandler()
    private var notes = [Note]()
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notes = coreDataNoteHandler.fetchNotes()
    }
    
    @IBAction func onClickCompose(_ sender: Any) {
        transitionToCompose(note: nil)
    }
    
    func transitionToCompose(note: Note?) {
        let storyboard = UIStoryboard(name: "ComposeNote", bundle: .main)
        guard let composeNavigation = storyboard.instantiateViewController(withIdentifier: "ComposeNoteNavigation") as? UINavigationController else {
            return
        }
        guard let composeView = composeNavigation.topViewController as? ComposeNoteViewController else {
            return
        }
        
        if let selectedNote = note {
            composeView.isNewNote = false
            composeView.note = selectedNote
        } else {
            composeView.isNewNote = true
        }
        composeView.delegate = self
        
        presentTransition = RightToLeftTransition()
        dismissTransition = LeftToRightTransition()
        
        composeNavigation.modalPresentationStyle = .custom
        composeNavigation.transitioningDelegate = self
        
        present(composeNavigation, animated: true, completion: { [weak self] in
            self?.presentTransition = nil
        })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < notes.count {
            transitionToCompose(note: notes[indexPath.row])
        }
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
    
    func didTapBack(note: Note) {
        dismiss(animated: true) { [weak self] in
            self?.dismissTransition = nil
        }
    }
    
    func didUpdateNote(note: Note) {
        
    }
    
    func didDelete(noteID: UUID) {
        
    }
    
    func didCreateNewNote(note: Note) {
        
    }
}

extension NotesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
