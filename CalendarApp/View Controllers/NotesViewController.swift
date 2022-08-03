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
        transitionToCompose(note: nil, index: nil)
    }
    
    func transitionToCompose(note: Note?, index: Int?) {
        let storyboard = UIStoryboard(name: "ComposeNote", bundle: .main)
        guard let composeNavigation = storyboard.instantiateViewController(withIdentifier: "ComposeNoteNavigation") as? UINavigationController else {
            return
        }
        guard let composeView = composeNavigation.topViewController as? ComposeNoteViewController else {
            return
        }
        
        if let selectedNote = note,
           let selectedIndex = index{
            composeView.isNewNote = false
            composeView.note = selectedNote
            composeView.selectedIndex = selectedIndex
        } else {
            composeView.isNewNote = true
            composeView.selectedIndex = 0
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
            transitionToCompose(note: notes[indexPath.row], index: indexPath.row)
        }
    }
    
    func getDateString(modifiedDate: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        
        let difference = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: notes[0].lastModified)
        let dateFormatter = DateFormatter()
        if let dayDifference = difference.day,
           dayDifference < 1 && dayDifference > 0 {
            dateFormatter.dateFormat = "H:mm"
        } else {
            dateFormatter.dateFormat = "M/d/yyyy"
        }
        return dateFormatter.string(from: modifiedDate)
    }
    
    func didTapBack(note: Note, index: Int) {
        dismiss(animated: true) { [weak self] in
            self?.dismissTransition = nil
            DispatchQueue.main.async {
                if index != 0 {
                    self?.notesTableView.moveRow(at: IndexPath(row: index, section: 0),
                                                 to: IndexPath(row: 0, section: 0))
                    guard let note = self?.notes.remove(at: index) else {
                        return
                    }
                    self?.notes.insert(note, at: 0)
                }
            }
        }
    }
    
    func didUpdateNote(note: Note, index: Int) {
        coreDataNoteHandler.update(note: note)
        let indexPaths = [IndexPath(row: index, section: 0)]
        notesTableView.reloadRows(at: indexPaths,
                                  with: .none)
    }
    
    func didDelete(noteID: UUID) {
        coreDataNoteHandler.deleteNote(noteID: noteID)
    }
    
    func didCreateNewNote(note: Note) {
        coreDataNoteHandler.saveNewNote(note: note)
        notes.insert(note, at: 0)
        notesTableView.reloadData()
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
