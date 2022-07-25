//
//  NetworkHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/25/22.
//

import Foundation
import Network

@objc
public protocol NetworkChangeDelegate {
    func didChangeOnline();
    func didChangeOffline();
}

@objcMembers
class NetworkHandler : NSObject {
    public var delegate : NetworkChangeDelegate?
    private let monitor = NWPathMonitor()
    private var status : NWPath.Status = .requiresConnection
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            if path.status == .satisfied {
                self?.delegate?.didChangeOnline()
            } else {
                self?.delegate?.didChangeOffline()
            }
        }
        let queue = DispatchQueue(label: "NewtorkHandler")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
