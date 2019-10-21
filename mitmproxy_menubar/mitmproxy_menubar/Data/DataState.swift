//
//  State.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 21/10/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation
import ReSwift

struct DataState: StateType {

    var lastAction: Action?
    
    var ipInfo: String = ""
    var isMitmEnabled: Bool = false
    var isProxyEnabled: Bool = false
}
