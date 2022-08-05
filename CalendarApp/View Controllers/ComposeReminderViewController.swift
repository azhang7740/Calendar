//
//  ComposeReminderViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/5/22.
//

import Foundation

protocol ComposeReminderDelegate: NSObject {
    func didTapDone(reminder: Reminder, index: Int?);
    func didTapCancel();
}

class ComposeReminderViewController: UIViewController, UITextViewDelegate {
    public var reminder: Reminder?
    public var selectedIndex: Int?
    public weak var delegate: ComposeReminderDelegate?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var reminderTitle: UITextView!
    @IBOutlet weak var reminderText: UITextView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reminderTitle.text = reminder?.title ?? ""
        reminderText.text = reminder?.reminderDescription ?? ""
        reminderDatePicker.date = reminder?.reminderDate ?? Date()
        
        if reminderTitle.text == "" {
            showPlaceholderText(textView: reminderTitle)
        }
        if reminderText.text == "" {
            showPlaceholderText(textView: reminderText)
        }
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        delegate?.didTapCancel()
    }
    
    @IBAction func onTapDone(_ sender: Any) {
        if !checkValidInputs() {
            return
        }
        let newReminder = updateReminderFromView()
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
        delegate?.didTapDone(reminder: newReminder, index: selectedIndex)
    }
    
    func checkValidInputs() -> Bool {
        if reminderTitle.textColor == UIColor.lightGray {
            displayErrorMessage("Title shouldn't be empty.")
            return false
        }
        return true
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = errorMessage
    }
    
    func createReminderFromView() -> Reminder {
        let newReminder = Reminder(context: context)
        newReminder.reminderID = UUID()
        newReminder.title = reminderTitle.text
        newReminder.reminderDescription = reminderText.textColor == UIColor.lightGray ? "" : reminderText.text
        newReminder.reminderDate = reminderDatePicker.date
        newReminder.archived = false
        
        return newReminder
    }
    
    func updateReminderFromView() -> Reminder {
        guard let updatedReminder = reminder else {
            return createReminderFromView()
        }
        updatedReminder.title = reminderTitle.text
        updatedReminder.reminderDescription = reminderText.textColor == UIColor.lightGray ? "" : reminderText.text
        updatedReminder.reminderDate = reminderDatePicker.date
        
        return updatedReminder
    }
    
    func showPlaceholderText(textView: UITextView) {
        if textView == reminderTitle {
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
}
