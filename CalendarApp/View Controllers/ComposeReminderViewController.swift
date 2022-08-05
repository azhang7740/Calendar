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

class ComposeReminderViewController: UIViewController {
    public var reminder: Reminder?
    private let notificationHandler = NotificationHandler()
    public var selectedIndex: Int?
    public weak var delegate: ComposeReminderDelegate?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func onTapCancel(_ sender: Any) {
        delegate?.didTapCancel()
    }
    
    @IBAction func onTapDone(_ sender: Any) {
        
    }
    
    func createReminderFromView() -> Reminder {
        let newReminder = Reminder(context: context)
        
        return newReminder
    }
    
    func updateReminderFromView() -> Reminder {
        guard let updatedReminder = reminder else {
            return createReminderFromView()
        }
        
        return updatedReminder
    }
}
