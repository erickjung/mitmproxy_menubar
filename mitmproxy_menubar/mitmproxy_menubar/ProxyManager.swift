//
//  ProxyManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation

enum ProxyState {

    case on
    case off

    var description: String {

        switch self {
            case .on: return "Proxy - ON"
            case .off: return "Proxy - OFF"
        }
    }
}

final class ProxyManager {

    static let shared = ProxyManager()

    public var currentState: ProxyState {

        get {
            return self.checkState()
        }
    }

    private let task = TaskManager()

    private init() {

        self.task.delegate = self
    }

    func touch() {

        switch currentState {

            case .off: self.turnOn()
            case .on:  self.turnOff()
        }
    }
}

private extension ProxyManager {

    func turnOn() {

        if let script = Bundle.main.path(forResource: "proxy_on", ofType: "sh") {

            task.executeShell(arg: script)
        }
    }

    func turnOff() {

        if let script = Bundle.main.path(forResource: "proxy_off", ofType: "sh") {

            task.executeShell(arg: script)
        }
    }

    func checkState() -> ProxyState {

        if let script = Bundle.main.path(forResource: "proxy_state", ofType: "sh") {

            let result = task.executeShellSync(arg: script)

            return result.contains("Yes") ? .on : .off
        }

        return .off
    }
}

extension ProxyManager: TaskManagerProtocol {

    func result(value: String) {

        MenuManager.shared.update()
    }
}
