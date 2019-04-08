//
//  MenuManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Cocoa

enum MenuServiceColorType {

    case red
    case green
    case blue

    var color: (NSColor, NSColor) {

        switch self {

            case .red:

                return (NSColor(red: 243.0/255.0, green: 96.0/255.0 , blue: 99.0/255.0 , alpha: 1.0),
                        NSColor(red: 242.0/255.0, green: 184.0/255.0, blue: 194.0/255.0, alpha: 1.0))

            case .green:

                return (NSColor(red: 67.0/255.0, green: 206.0/255.0, blue: 162.0/255.0, alpha: 1.0),
                        NSColor(red: 24.0/255.0, green: 90.0/255.0 , blue: 157.0/255.0 , alpha: 1.0))

            case .blue:

                return (NSColor(red: 31.0/255.0, green: 28.0/255.0, blue: 44.0/255.0, alpha: 1.0),
                        NSColor(red: 146.0/255.0, green: 141.0/255.0 , blue: 171.0/255.0 , alpha: 1.0))
        }
    }
}

final class MenuManager: NSObject {

    static let shared = MenuManager()

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var menuProxy = NSMenuItem()
    private var menuProxyInfo = NSMenuItem()
    private var menuProxyInfoMenu = NSMenuItem()
    private var menuService = NSMenuItem()
    private var menuQuit = NSMenuItem()

    private override init() {}

    func initialize() {

        self.configure()
        self.update()
    }

    func update() {

        if let button = statusItem.button {

            let proxyState = ProxyManager.shared.currentState
            let serviceState = ServiceManager.shared.currentState

            statusItem.button?.alignment = .left
            statusItem.button?.imagePosition = .imageLeft
            statusItem.length = 60

            if proxyState == .on && serviceState == .off {

                statusItem.length = 40
                button.title = "p"
            }
            else if proxyState == .on && serviceState == .on {

                button.title = "p | s"
            }
            else if proxyState == .off && serviceState == .on {

                statusItem.length = 40
                button.title = "s"

            } else {

                statusItem.length = NSStatusItem.squareLength
                button.title = ""
            }
        }
    }
}

private extension MenuManager {

    func configure() {

        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self

        // proxy & network
        self.addItem(item: &self.menuProxy, selector: #selector(didPressProxy))
        self.addItem(item: &self.menuProxyInfo, title: "Network Info")
        statusItem.menu?.addItem(NSMenuItem.separator())

        self.menuProxyInfo.submenu = NSMenu()
        self.menuProxyInfo.submenu?.addItem(self.menuProxyInfoMenu)

        // mitm service
        self.addItem(item: &self.menuService, selector: #selector(didPressService))
        statusItem.menu?.addItem(NSMenuItem.separator())

        // quit
        self.addItem(item: &self.menuQuit, selector: #selector(didPressQuit), title: "Quit")

        if let button = statusItem.button {
            button.image = NSImage(named: "logo")
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
        }
    }

    func addItem(item: inout NSMenuItem, selector: Selector? = nil, title: String = "") {

        item.title = title

        if let selector = selector {

            item.action = selector
            item.target = self
        }

        self.statusItem.menu?.addItem(item)
    }

    @objc func didPressProxy() {

        ProxyManager.shared.touch()
    }

    @objc func didPressService() {

        ServiceManager.shared.touch()
    }

    @objc func didPressQuit() {

        NSApp.terminate(self)
    }
}

extension MenuManager: NSMenuDelegate {

    func menuWillOpen(_ menu: NSMenu) {
        
        menuProxy.title = ProxyManager.shared.currentState.description
        menuService.title = ServiceManager.shared.currentState.description

        menuProxyInfoMenu.attributedTitle = NSAttributedString(string: ProxyManager.shared.ipInfo)
    }
}
