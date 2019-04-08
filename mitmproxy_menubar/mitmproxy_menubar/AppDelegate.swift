//
//  AppDelegate.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        MenuManager.shared.initialize()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

