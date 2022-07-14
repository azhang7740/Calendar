//
//  ScheduleViewController.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

import Foundation
import CalendarKit

@objcMembers
class ScheduleViewController : DayViewController {
    let event : Event
    
    required init? (coder aDecoder: NSCoder) {
        self.event = Event()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
    }
}
