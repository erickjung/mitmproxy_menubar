//
//  MenuManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Cocoa

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

            let proxyState = NetworkManager.shared.currentState
            let serviceState = ServiceManager.shared.currentState

            statusItem.button?.alignment = .left
            statusItem.button?.imagePosition = .imageLeft
            statusItem.length = 60

            if proxyState == .proxyOn && serviceState == .off {

                statusItem.length = 40
                button.title = "p"
            }
            else if proxyState == .proxyOn && serviceState == .on {

                button.title = "p | s"
            }
            else if proxyState == .proxyOff && serviceState == .on {

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

        NetworkManager.shared.touch()
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
        
        menuProxy.title = NetworkManager.shared.currentState.description
        menuService.title = ServiceManager.shared.currentState.description

        menuProxyInfoMenu.attributedTitle = NSAttributedString(string: NetworkManager.shared.ipInfo)
    }
}
