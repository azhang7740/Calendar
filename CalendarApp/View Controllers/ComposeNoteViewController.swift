//
//  ComposeNoteViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation

protocol ComposeNoteDelegate: NSObject {
    func didTapBack(note: Note, index: Int?)
    func didUpdateNote(note: Note, index: Int)
    func didDelete(noteID: UUID)
    func didCreateNewNote(note: Note)
    func didTapBackWithEmptyNote(_ note: Note, index: Int?)
}

class ComposeNoteViewController : UIViewController, UITextViewDelegate, UITextFieldDelegate {
    public var isNewNote = false
    public var noteDidChange = false
    public var note = Note()
    public var selectedIndex = 0
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
            showPlaceholderText(textView: titleTextView)
        }
        if descriptionTextView.text == "" {
            showPlaceholderText(textView: descriptionTextView)
        }
    }
    
    func showPlaceholderText(textView: UITextView) {
        if textView == titleTextView {
            textView.text = "Title"
        } else {
            textView.text = "Type here..."
        }
        textView.textColor = UIColor.lightGray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            showPlaceholderText(textView: textView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteDidChange = true
        let isEmpty = textView.textColor == UIColor.lightGray
        if isEmpty {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func updateNoteWithView() {
        note.lastModified = Date()
        if titleTextView.textColor == UIColor.lightGray {
            note.title = ""
        } else {
            note.title = titleTextView.text
        }
        
        if descriptionTextView.textColor == UIColor.lightGray {
            note.text = ""
        } else {
            note.text = descriptionTextView.text
        }
    }
    
    func updateNote() {
        updateNoteWithView()
        if isNewNote && (note.title != "" || note.text != "") {
            delegate?.didCreateNewNote(note: note)
            isNewNote = false
        } else if note.title != "" || note.text != "" {
            delegate?.didUpdateNote(note: note, index: selectedIndex)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        if noteDidChange {
            updateNote()
            if note.title == "" && note.text == "" {
                delegate?.didTapBackWithEmptyNote(note, index: selectedIndex)
            } else {
                delegate?.didTapBack(note: note, index: selectedIndex)
            }
        } else {
            delegate?.didTapBack(note: note, index: nil)
        }
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        view.endEditing(true)
        updateNote()
    }
}
