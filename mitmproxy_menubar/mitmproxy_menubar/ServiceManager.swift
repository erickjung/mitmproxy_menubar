//
//  ServiceManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation

enum ServiceState {

    case on
    case off

    var description: String {

        switch self {
            case .on: return "Service - ON"
            case .off: return "Service - OFF"
        }
    }
}

final class ServiceManager {

    static let shared = ServiceManager()

    public var currentState: ServiceState {

        get {
            return self.checkState()
        }
    }

    private let task = TaskManager()

    private init() {

        task.delegate = self
    }

    func touch() {

        switch currentState {

            case .off: self.turnOn()
            case .on:  self.turnOff()
        }
    }
}

private extension ServiceManager {

    func turnOn() {

        if let script = Bundle.main.path(forResource: "mitmweb", ofType: "") {

            task.execute(launch: script, ignoreReturn: true)
        }
    }

    func turnOff() {

        task.execute(launch: "/usr/bin/pkill", arg: ["-f", "mitmweb"])
    }

    func checkState() -> ServiceState {

        if let script = Bundle.main.path(forResource: "service_state", ofType: "sh") {

            let result = task.executeShellSync(arg: script)

            return result.contains("ON") ? .on : .off
        }

        return .off
    }
}

extension ServiceManager: TaskManagerProtocol {

    func result(value: String) {

        MenuManager.shared.update()
        print(result)
    }
}
