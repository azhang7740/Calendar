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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewController = self.navigationController?.tabBarController?.viewControllers?[0] as? ScheduleViewController else {
            return
        }
        receiveHandler = viewController.receiveHandler
        receiveHandler?.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reminderTableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
        cell.selectionStyle = .none
        guard let reminderCell = cell as? ReminderCell else {
            return cell
        }
        
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
        
    }
    
    func editReminder(_ index: Int) {
        
    }
    
    func didReceiveNotification(_ notification: UNNotification) {
        
    }
}
