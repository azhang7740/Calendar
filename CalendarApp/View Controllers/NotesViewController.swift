//
//  NotesViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation
import UIKit

@objcMembers
class NotesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
