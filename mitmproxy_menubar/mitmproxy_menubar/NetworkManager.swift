//
//  ProxyManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation

enum NetworkState {

    case proxyOn
    case proxyOff

    var description: String {

        switch self {
            case .proxyOn: return "Disable Proxy"
            case .proxyOff: return "Enable Proxy"
        }
    }
}

final class NetworkManager {

    enum NetworkScript {

        case turnOn
        case turnOff
        case state
        case ipInfo

        var name: String {

            switch self {
                case .turnOn: return "proxy_on"
                case .turnOff: return "proxy_off"
                case .state: return "proxy_state"
                case .ipInfo: return "ip_info"
            }
        }
    }

    static let shared = NetworkManager()

    public var currentState: NetworkState {

        get {
            return self.checkState()
        }
    }

    public var ipInfo: String {

        get {
            return self.checkIpInfo()
        }
    }

    private let task = TaskManager()

    private init() {

        self.task.delegate = self
    }

    func touch() {

        switch currentState {

            case .proxyOff: self.turnState(script: .turnOn)
            case .proxyOn:  self.turnState(script: .turnOff)
        }
    }
}

private extension NetworkManager {

    func turnState(script: NetworkScript) {

        if let script = Bundle.main.path(forResource: script.name, ofType: "sh") {

            task.executeShell(arg: script)
        }
    }

    func getState(script: NetworkScript) -> String {

        if let script = Bundle.main.path(forResource: script.name, ofType: "sh") {

            return task.executeShellSync(arg: script)
        }

        return ""
    }

    func checkState() -> NetworkState {

        return self.getState(script: .state).contains("Yes") ? .proxyOn : .proxyOff
    }

    func checkIpInfo() -> String {

        return self.getState(script: .ipInfo)
    }
}

extension NetworkManager: TaskManagerProtocol {

    func result(value: String) {

        MenuManager.shared.update()
    }
}
