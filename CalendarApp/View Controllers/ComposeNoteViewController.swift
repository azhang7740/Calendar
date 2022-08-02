//
//  ComposeNoteViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation

protocol ComposeNoteDelegate: NSObject {
    func didTapBack(note: Note);
    func didUpdateNote(note: Note);
    func didDelete(noteID: UUID);
    func didCreateNewNote(note: Note);
}

class ComposeNoteViewController : UIViewController, UITextViewDelegate, UITextFieldDelegate {
    public var note: Note?
    public weak var delegate: ComposeNoteDelegate?
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.didTapBack(note: note ?? Note())
    }
}
