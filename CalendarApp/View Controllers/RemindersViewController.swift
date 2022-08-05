//
//  RemindersViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/4/22.
//

import Foundation

class RemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ReceivedNotificationDelegate {
    @IBOutlet weak var reminderTableView: UITableView!
    private var receiveHandler: NotificationReceiveHandler?
    private var reminders = [Reminder]()
    private let notificationHandler = NotificationHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewController = self.navigationController?.tabBarController?.viewControllers?[0] as? ScheduleViewController else {
            return
        }
        receiveHandler = viewController.receiveHandler
        receiveHandler?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllReminders()
        reminderTableView.reloadData()
    }
    
    func fetchAllReminders() {
        reminders = notificationHandler.fetchReminderInfo()
        reminders.sort(by: { $0.reminderDate ?? Date() < $1.reminderDate ?? Date() })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reminderTableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
        cell.selectionStyle = .none
        guard let reminderCell = cell as? ReminderCell,
              indexPath.row < reminders.count else {
            return cell
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy, h:mm a"
        if let date = reminders[indexPath.row].reminderDate {
            reminderCell.dateLabel.text = dateFormatter.string(from:date)
            if date.compare(Date()) == .orderedAscending {
                reminderCell.dateLabel.textColor = .systemRed
            }
        }
        reminderCell.titleLabel.text = reminders[indexPath.row].title
        reminderCell.descriptionLabel.text = reminders[indexPath.row].reminderDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteReminder(indexPath.row)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editReminder(indexPath.row)
        }
        edit.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func deleteReminder(_ index: Int) {
        guard index < reminders.count,
                let reminderID = reminders[index].reminderID else {
            return
        }
        notificationHandler.deleteReminderWithID(reminderID)
        reminders.remove(at: index)
        reminderTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func editReminder(_ index: Int) {
        
    }
    
    func didReceiveNotification(_ notification: UNNotification) {
        reminderTableView.reloadData()
    }
}
