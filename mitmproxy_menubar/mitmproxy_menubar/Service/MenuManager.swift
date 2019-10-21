//
//  MenuManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Cocoa
import ReSwift

final class MenuManager: NSObject, StoreSubscriber {

    static let shared = MenuManager()

    typealias StoreSubscriberStateType = DataState
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var menuProxy = NSMenuItem()
    private var menuProxyInfo = NSMenuItem()
    private var menuProxyInfoMenu = NSMenuItem()
    private var menuService = NSMenuItem()
    private var menuQuit = NSMenuItem()

    private override init() {}

    func initialize() {

        self.configure()
        
        DataStore.state.subscribe(self)
        DataStore.state.dispatch(ConfigAction())
    }

    func newState(state: DataState) {

        statusItem.button?.alignment = .left
        statusItem.button?.imagePosition = .imageLeft
        statusItem.length = 40
        
        if state.isProxyEnabled && !state.isMitmEnabled {

            statusItem.button?.title = "p"
        }
        else if state.isProxyEnabled && state.isMitmEnabled {

            statusItem.length = 60
            statusItem.button?.title = "p | m"
        }
        else if !state.isProxyEnabled && state.isMitmEnabled {

            statusItem.button?.title = "m"

        } else {

            statusItem.button?.alignment = .center
            statusItem.button?.imagePosition = .imageOnly
            statusItem.button?.title = ""
        }
        
        menuProxy.title = state.isProxyEnabled ? "Disable Proxy" : "Enable Proxy"
        menuService.title = state.isMitmEnabled ? "Disable Mitm" : "Enable Mitm"

        if let action = state.lastAction {

            switch action {

                case let result as TaskResultAction:
                     
                    if result.task == .ipInfo {
                        
                        menuProxyInfoMenu.attributedTitle = NSAttributedString(string: result.data ?? "")
                    }
                    
                default:
                    break
            }
        }
    }
}

private extension MenuManager {

    func configure() {

        statusItem.menu = NSMenu()

        // proxy & network
        self.addItem(item: &self.menuProxy, selector: #selector(didPressProxy))
        self.addItem(item: &self.menuProxyInfo, title: "Network Info")
        statusItem.menu?.addItem(NSMenuItem.separator())

        self.menuProxyInfo.submenu = NSMenu()
        self.menuProxyInfo.submenu?.addItem(self.menuProxyInfoMenu)

        // mitm service
        self.addItem(item: &self.menuService, selector: #selector(didPressMitm))
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

        DataStore.state.dispatch(TouchProxyAction())
    }

    @objc func didPressMitm() {

        DataStore.state.dispatch(TouchMitmAction())
    }

    @objc func didPressQuit() {

        NSApp.terminate(self)
    }
}
