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
    public var isNewNote = false
    public var note = Note()
    public weak var delegate: ComposeNoteDelegate?
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNewNote {
            note.title = ""
        }
        titleTextView.text = note.title
        descriptionTextView.text = note.text
        if titleTextView.text == "" {
            showPlaceholderText(textView: titleTextView, text: "Title")
        }
        if descriptionTextView.text == "" {
            showPlaceholderText(textView: descriptionTextView, text: "Type here...")
        }
    }
    
    func showPlaceholderText(textView: UITextView, text: String) {
        textView.text = text
        textView.textColor = UIColor.lightGray
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.didTapBack(note: note)
    }
}
