//
//  NetworkHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/25/22.
//

import Foundation
import Network

@objcMembers
class NetworkHandler : NSObject {
    private let monitor = NWPathMonitor()
    private var status : NWPath.Status = .requiresConnection
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            if path.status == .satisfied {
                print("online")
            } else {
                print("offline")
            }
        }
        let queue = DispatchQueue(label: "NewtorkHandler")
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
