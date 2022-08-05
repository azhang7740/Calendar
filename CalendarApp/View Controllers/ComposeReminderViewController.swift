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
    
    
}
