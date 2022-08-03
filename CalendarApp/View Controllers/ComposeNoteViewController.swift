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
        let isEmpty = textView.textColor == UIColor.lightGray
        if isEmpty {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.didTapBack(note: note)
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        view.endEditing(true)
    }
}
